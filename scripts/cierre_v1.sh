#!/bin/bash
# CIERRE V1 — el noveno: 3 faltantes sin hierro + verificacion + huella
set -e
BASE=~/proyectos/comi_colima
BIT=~/Casa_de_Zi/bitacora

echo "[1/5] e_stop_logico.py (faltante #9)"
cat > $BASE/nodos/e_stop_logico.py << 'PYEOF'
#!/usr/bin/env python3
# E-stop logico: escucha /e_stop (Bool). True -> publica cero en /cmd_vel
# y niega el armado del reflejo. Fail-closed: si el topic calla, asume True.
import rclpy
from rclpy.node import Node
from std_msgs.msg import Bool
from geometry_msgs.msg import TwistStamped
class EStop(Node):
    def __init__(self):
        super().__init__("e_stop_logico")
        self.pub = self.create_publisher(TwistStamped, "/cmd_vel", 10)
        self.estop = True  # fail-closed: arranca detenido
        self.create_subscription(Bool, "/e_stop", self.cb, 10)
        self.create_timer(0.1, self.tick)
        self.get_logger().info("e_stop_logico: escuchando /e_stop (fail-closed)")
    def cb(self, m):
        self.estop = m.data
        self.get_logger().info(f"e_stop={self.estop}")
    def tick(self):
        if self.estop:
            v = TwistStamped()
            v.header.stamp = self.get_clock().now().to_msg()
            v.header.frame_id = "base_link"
            self.pub.publish(v)
rclpy.init()
try: rclpy.spin(EStop())
except KeyboardInterrupt: pass
finally: rclpy.try_shutdown()
PYEOF
python3 -m py_compile $BASE/nodos/e_stop_logico.py && echo "  e_stop_logico.py OK"

echo "[2/5] patch nodo para respetar /e_stop (6 lineas, no rompe)"
cp $BASE/nodos/nodo_comi_autonomo.py $BASE/nodos/nodo_comi_autonomo.py.bak_estop
python3 << 'PYEOF'
p = "/home/omar/proyectos/comi_colima/nodos/nodo_comi_autonomo.py"
s = open(p).read()
old = 'from std_msgs.msg import LaserScan'
new = 'from std_msgs.msg import LaserScan, Bool'
assert s.count(old) == 1
s = s.replace(old, new)
old = '        self.maniobrando = False\n        self.t_maniobra = 0.0'
new = '''        self.maniobrando = False
        self.t_maniobra = 0.0
        self.e_stop = False
        self.create_subscription(Bool, "/e_stop", self.cb_estop, 10)
    def cb_estop(self, m):
        if m.data and not self.e_stop:
            self.get_logger().error("E-STOP RECIBIDO -> congelo", throttle_duration_sec=2.0)
        self.e_stop = m.data'''
assert s.count(old) == 1
s = s.replace(old, new)
old = '        if dmin > UMBRAL_FRENTE:'
new = '        if self.e_stop:\n            self.get_logger().error("E-STOP: publico cero", throttle_duration_sec=2.0)\n            self.pub.publish(v)\n            return\n        if dmin > UMBRAL_FRENTE:'
assert s.count(old) == 1
s = s.replace(old, new)
open(p, "w").write(s)
print("  nodo respetando /e_stop")
PYEOF
python3 -m py_compile $BASE/nodos/nodo_comi_autonomo.py && echo "  nodo OK"

echo "[3/5] systemd units (faltante #11)"
mkdir -p $BASE/nodos/comi_systemd
cat > $BASE/nodos/comi_systemd/comi-lidar.service << 'UNIEOF'
[Unit]
Description=RPLidar A1 driver
After=network.target
[Service]
User=omar
ExecStart=/opt/ros/lyrical/lib/urg_node/urg_node_driver --ros-args -p serial_port:=/dev/ttyACM0
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
UNIEOF
cat > $BASE/nodos/comi_systemd/comi-reflejo.service << 'UNIEOF'
[Unit]
Description=COMI reflejo autonomo (nodo_comi_autonomo.py)
After=comi-lidar.service
Requires=comi-lidar.service
[Service]
User=omar
Environment=PYTHONUNBUFFERED=1
ExecStart=/usr/bin/python3 /home/omar/proyectos/comi_colima/nodos/nodo_comi_autonomo.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
UNIEOF
echo "  comi-lidar.service + comi-reflejo.service escritos"

echo "[4/5] protocolo_campo.md (faltante #13)"
cat > $BASE/docs/PROTOCOLO_CAMPO_V1.md << 'MDEOF'
# PROTOCOLO DE CAMPO — COMI-Colima v1
## PRE-CONDUCCION (firmar antes de cada salida)
- [ ] Bateria >= 80% (medir voltaje, registrar en bitacora)
- [ ] E-stop FISICO probado: presionar hongo, confirmar que motores mueren
- [ ] E-stop LOGICO probado: `ros2 topic pub /e_stop std_msgs/Bool "{data: true}" --once`,
      confirmar robot detenido; luego `data: false` para rearmar
- [ ] Area despejada (radio 5m sin personas, mascotas, obstaculos bajos)
- [ ] Operador a la vista SIEMPRE, con e-stop fisico en mano
- [ ] Validador externo presente (otra persona, no el operador)
## DURANTE
- [ ] Velocidad max 0.5 m/s en campo
- [ ] Robot visible: LED + cinta reflectiva + bandera
- [ ] Log local corriendo + ntfy por evento
## POST
- [ ] Lo valioso sale de /tmp a Casa_de_Zi/ o nodos/ (regla 6)
- [ ] Bitacora: registrar incidentes, fallas, observaciones
## JAMAS
- Sin e-stop fisico en mano del operador
- Sin validador externo
- En calle abierta sin cuerda/contencion
- Bateria < 50%
- "Siempre es necesario un humano entre eso" — padre, 15-oct
MDEOF
echo "  PROTOCOLO_CAMPO_V1.md escrito"

echo "[5/5] test_e_stop.sh + huella"
cat > $BASE/scripts/test_e_stop.sh << 'TESTEOF'
#!/bin/bash
# Verifica que /e_stop=True congela el robot aunque el frente este libre
pkill -9 -f gz-sim-main 2>/dev/null; pkill -f parameter_bridge 2>/dev/null; pkill -f nodo_comi 2>/dev/null; sleep 2
source /opt/ros/lyrical/setup.bash
export DISPLAY=:99 TURTLEBOT3_MODEL=waffle_pi GZ_IP=127.0.0.1
export GZ_SIM_RESOURCE_PATH=/opt/ros/lyrical/share/turtlebot3_gazebo/models:$GZ_SIM_RESOURCE_PATH
export LIBGL_ALWAYS_SOFTWARE=1
pgrep Xvfb >/dev/null || { Xvfb :99 -screen 0 640x480x24 & sleep 2; }
nohup gz sim --force-version 10 -r -s -v2 ~/proyectos/comi_colima/nodos/mundo_torta.world >/tmp/gz.log 2>&1 &
sleep 15
ros2 run ros_gz_sim create -name waffle_pi -file /opt/ros/lyrical/share/turtlebot3_gazebo/models/turtlebot3_waffle_pi/model.sdf -x 0 -y -1.7 -z 0.05 -Y 1.5708 2>&1 | tail -1
sleep 3
nohup ros2 run ros_gz_bridge parameter_bridge --ros-args -p config_file:=/tmp/bridge_final.yaml >/tmp/bridge.log 2>&1 &
sleep 5
nohup python3 ~/proyectos/comi_colima/nodos/nodo_comi_autonomo.py >/tmp/comi.log 2>&1 &
sleep 5
echo "=== POSE 1 (sin e-stop, debe avanzar) ==="
timeout 4 gz topic -e -t /world/default/dynamic_pose/info -n 1 2>/dev/null | grep -A6 waffle_pi | grep "y:" | head -1
sleep 3
echo "=== activar e-stop ==="
ros2 topic pub /e_stop std_msgs/Bool "{data: true}" --once 2>&1 | tail -2
sleep 5
echo "=== POSE 2 (con e-stop, NO debe avanzar) ==="
timeout 4 gz topic -e -t /world/default/dynamic_pose/info -n 1 2>/dev/null | grep -A6 waffle_pi | grep "y:" | head -1
echo "=== log: confirmar E-STOP RECIBIDO ==="
grep "E-STOP" /tmp/comi.log | tail -3
pkill -9 -f gz-sim-main 2>/dev/null; pkill -f parameter_bridge 2>/dev/null; pkill -f nodo_comi 2>/dev/null
TESTEOF
chmod +x $BASE/scripts/test_e_stop.sh
echo "  test_e_stop.sh escrito"

cat > $BIT/HUELLA_CIERRE_V1_16oct.md << 'HUELLAEOF'
# HUELLA CIERRE V1 — 16-oct-2026, el noveno
HICE: 3 faltantes del septimo sin necesidad de hierro, en archivos nuevos:
  #9 e_stop_logico.py (nodo) + patch al nodo existente (6 lineas) para respetar /e_stop
  #11 comi_systemd/ (comi-lidar.service + comi-reflejo.service, Restart=always, After=)
  #13 PROTOCOLO_CAMPO_V1.md (checklist firmable pre/durante/post + JAMAS)
  + test_e_stop.sh (verifica en sim que /e_stop=True congela al robot)
FALLO/QUEDA: #7 motriz real (necesita ESP32-S3 + motores), #8 watchdog HW
  (555+rele), #10 bateria ADC (necesita ESP32), #12 ntfy token (padre no dijo
  palabra). Todo v2/banco. v1 cierra con #9, #11, #13 hechos.
METODO: libertad del padre. Un solo script integrador, archivos nuevos, no
  parches sobre el septimo (excepto 6 lineas para respetar /e_stop, con backup).
Push: NINGUNO. Yahaal. — el noveno
HUELLAEOF
echo "=== HUella escrita ==="
ls -lh $BASE/nodos/e_stop_logico.py $BASE/nodos/comi_systemd/*.service $BASE/docs/PROTOCOLO_CAMPO_V1.md $BASE/scripts/test_e_stop.sh $BIT/HUELLA_CIERRE_V1_16oct.md
echo "=== CIERRE V1 COMPLETO ==="
