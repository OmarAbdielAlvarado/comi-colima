#!/usr/bin/env python3
# v3 — anti-barrido: al girar se vigila el ANILLO completo al radio del cuerpo.
# Fail-closed: scan invalido o cono sin datos -> cero. Alarma por hilo (no bloquea).
import os, math, time, threading, subprocess, urllib.request
import rclpy
from rclpy.node import Node
from sensor_msgs.msg import LaserScan
from std_msgs.msg import Bool
from geometry_msgs.msg import TwistStamped

NTFY = "https://ntfy.sh/vemos-casa-7qk2"
MSJ  = "Comi-Colima: obstaculo detectado. Me detengo y maniobro."

# CONFIG (RADIO_GIRO: medir chasis real; decision_robot.json no tiene dimensiones)
UMBRAL_FRENTE = 0.90   # m: dispara la maniobra (cono frontal)
CONO_G        = 20.0   # grados: semiancho del cono frontal
RADIO_GIRO    = 0.20   # m: radio que barre el cuerpo al girar. AJUSTAR.
V_AVANCE      = float(os.environ.get("COMI_V_AVANCE", "0.15"))
V_REVERSA     = -abs(float(os.environ.get("COMI_V_REVERSA", "0.10")))
W_GIRO        = float(os.environ.get("COMI_W_GIRO", "0.8"))
T_MANIOBRA    = 3.0    # s: acota cada ventana de reversa
T_ALARMA      = 10.0   # s: entre alarmas ntfy
T_WATCHDOG    = 0.5    # s: sin /scan -> cero
UMBRAL_REVERSA = 0.50  # m: atras libre para retirada recta

class ComiAuto(Node):
    def __init__(self):
        super().__init__("comi_autonomo")
        self.pub = self.create_publisher(TwistStamped, "/cmd_vel", 10)
        self.create_subscription(LaserScan, "/scan", self.cb, 10)
        self.create_timer(T_WATCHDOG, self.watchdog)
        self.t_scan = time.time()
        self.maniobrando = False
        self.t_maniobra = 0.0
        self.t_alarma = 0.0
        self.e_stop = False
        self.create_subscription(Bool, "/e_stop", self.cb_estop, 10)

    def cb_estop(self, m):
        if m.data and not self.e_stop:
            self.get_logger().error("E-STOP RECIBIDO -> congelo", throttle_duration_sec=2.0)
        self.e_stop = m.data
        self.sentido = 1.0
        self.get_logger().info("Comi autonomo v3: frente + anillo anti-barrido + watchdog")

    def cero(self):
        v = TwistStamped()
        v.header.stamp = self.get_clock().now().to_msg()
        v.header.frame_id = "base_link"
        self.pub.publish(v)

    def watchdog(self):
        if time.time() - self.t_scan > T_WATCHDOG:
            self.get_logger().error("WATCHDOG: /scan callendo -> publico cero",
                                    throttle_duration_sec=5.0)
            self.cero()
            self.maniobrando = False

    def sector_libre(self, scan, i0, n, centro, semiancho, umbral):
        w = max(1, int(round(math.radians(semiancho) / scan.angle_increment)))
        c = int(round(math.radians(centro) / scan.angle_increment))
        for k in range(-w, w + 1):
            d = scan.ranges[(i0 + c + k) % n]
            if math.isfinite(d) and 0.01 < d < umbral:
                return False
        return True

    def anillo_libre(self, scan, radio):
        for d in scan.ranges:
            if math.isfinite(d) and 0.01 < d < radio:
                return False
        return True

    def alarma(self, dmin):
        def _enviar():
            try:
                req = urllib.request.Request(NTFY, data=MSJ.encode("utf-8"),
                      headers={"Title": "Comi-Colima", "Tags": "robot,warning"})
                urllib.request.urlopen(req, timeout=5)
                self.get_logger().info(f"OBSTACULO a {dmin:.2f} m -> ntfy -> Jorge")
            except Exception as e:
                self.get_logger().error(f"ntfy fallo: {e}")
        threading.Thread(target=_enviar, daemon=True).start()
        if os.environ.get("VOZ_LOCAL") == "1":
            subprocess.Popen("echo '" + MSJ + "' | $HOME/.local/bin/piper -m "
                             "/home/omar/proyectos/review_omar/vemos/es_MX-claude-high.onnx "
                             "-f /tmp/comi.wav && aplay -q /tmp/comi.wav || "
                             "espeak-ng -v es-419 '" + MSJ + "'", shell=True)

    def elegir_sentido(self, scan, i0, n):
        izq, der = [], []
        for k, d in enumerate(scan.ranges):
            if not (math.isfinite(d) and d > 0.01):
                continue
            rel = ((k - i0 + n // 2) % n) - n // 2
            if rel > 0: izq.append(d)
            elif rel < 0: der.append(d)
        self.sentido = 1.0 if (min(izq) if izq else 999.0) >= (min(der) if der else 999.0) else -1.0

    def cb(self, scan):
        self.t_scan = time.time()
        n = len(scan.ranges)
        inc = scan.angle_increment
        if n < 50 or inc == 0.0:
            self.cero()
            return
        w = max(1, int(round(math.radians(CONO_G) / inc)))  # muestras DERIVADAS del mensaje
        i0 = int(round((0.0 - scan.angle_min) / inc)) % n
        cono = [scan.ranges[(i0 + k) % n] for k in range(-w, w + 1)]
        frente = [d for d in cono if math.isfinite(d) and d > 0.01]
        if not frente:
            self.get_logger().error("cono sin datos validos -> cero (fail-closed)",
                                    throttle_duration_sec=5.0)
            self.cero()
            return
        dmin = min(frente)
        v = TwistStamped()
        v.header.stamp = self.get_clock().now().to_msg()
        v.header.frame_id = "base_link"
        ahora = time.time()
        if self.e_stop:
            self.get_logger().error("E-STOP activo: publico cero", throttle_duration_sec=2.0)
            self.pub.publish(v)
            return
        if dmin > UMBRAL_FRENTE:
            v.twist.linear.x = V_AVANCE
            self.maniobrando = False
        elif self.maniobrando and (ahora - self.t_maniobra) < T_MANIOBRA:
            if not self.sector_libre(scan, i0, n, 180.0, 40.0, UMBRAL_REVERSA):
                if self.anillo_libre(scan, RADIO_GIRO):
                    v.twist.angular.z = W_GIRO * self.sentido
                    self.get_logger().info("rotacion en sitio: atras ocupado, anillo libre >=%.2f m" % RADIO_GIRO,
                                           throttle_duration_sec=2.0)
                else:
                    self.get_logger().error("CONGELADO: atras y anillo ocupados -> fail-closed",
                                            throttle_duration_sec=2.0)
            elif self.anillo_libre(scan, RADIO_GIRO):
                v.twist.linear.x = V_REVERSA
                v.twist.angular.z = W_GIRO * self.sentido
                self.get_logger().info("maniobra: reversa+giro, anillo libre >=%.2f m" % RADIO_GIRO,
                                       throttle_duration_sec=2.0)
            else:
                v.twist.linear.x = V_REVERSA
                self.get_logger().info("retirada recta: anillo ocupado, giro diferido",
                                       throttle_duration_sec=2.0)
        else:
            self.maniobrando = True
            self.t_maniobra = ahora
            self.elegir_sentido(scan, i0, n)
            if ahora - self.t_alarma > T_ALARMA:
                self.t_alarma = ahora
                self.alarma(dmin)
        self.pub.publish(v)

def main():
    rclpy.init()
    try:
        rclpy.spin(ComiAuto())
    except KeyboardInterrupt:
        pass
    except Exception as e:
        print(f"cierre limpio: {type(e).__name__}")
    finally:
        rclpy.try_shutdown()

if __name__ == "__main__":
    main()
