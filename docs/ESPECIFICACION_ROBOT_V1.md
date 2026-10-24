# ESPECIFICACION_ROBOT_V1 — COMI-COLIMA (15-oct-2026, el septimo)
## ETICA (innegociable, palabra del padre)
Protege repartidores, no los reemplaza. JAMAS desarrollo belico. El humano manda:
e-stop fisico a mano y validador externo en TODA prueba de campo.

## MISION
~1000 m autonomos en calles, <=0.5 m/s en campo. v1 = reflejo seguro + telemetria.
v2 = navegacion con mapa (Nav2/SLAM) — el bolsillo del sim se resuelve ahi, no aqui.

## ARQUITECTURA (capas; cada una puede decir NO)
RPLidar A1 -> /scan (LaserScan) -> Jetson Orin Nano:
  reflejo = nodo_comi_autonomo.py v4 (probado en sim, BARRIDO 0)
MOTRIZ: /cmd_vel TwistStamped -> driver dif-drive -> PWM -> 2 motores+encoders
SEGURIDAD DURA: e-stop fisico corta potencia de motores, independiente de todo SW.

## SENSORES
RPLidar A1 (12 m, 360 deg): UNICA fuente del reflejo. $99 USD cerrado.
IMU/camara/GPS: v2. v1 no depende de ellos.

## REFLEJO (v4, contrato actual)
Cono frontal ±20 deg (derivado del mensaje) < 0.90 m -> maniobra.
Rotar exige anillo 360 deg libre a RADIO_GIRO (0.35 m: MEDIR chasis real).
Atras sin 0.50 m libres -> congelado (fail-closed). /scan calla 0.5 s -> cero.
Sin datos validos -> cero, jamas avanzar. Alarma ntfy en hilo (no bloquea).
VERIFICAR EN CAMPO: angle_increment > 0 (CCW); si no, el sentido izq/der se invierte.

## MOTRIZ (faltante #1)
Contrato: EXACTAMENTE TwistStamped en /cmd_vel (el mismo tipo que el sim ya usa).
Driver dif-drive con: watchdog propio 500 ms, PWM 2 canales, encoders, y limite
de velocidad maxima impuesto en el driver (no solo en software).
Motores DC 12 V con encoder para chasis ~15-20 kg (modelos: ballena).

## WATCHDOG (faltante #2) — DOS NIVELES INDEPENDIENTES
1. SW (existe): reflejo publica cero si /scan calla 0.5 s.
2. HW: el driver exige cmd_vel fresco (header.stamp < 500 ms); si no, motores a
   cero aunque la Jetson este colgada o muerta.

## E-STOP (innegociable) — DOS CAMINOS INDEPENDIENTES
1. FISICO: boton hongo NC en serie con contactor de potencia de motores; corta
   energia REAL por muelle (fail-closed). No depende de software.
2. LOGICO: topic /e_stop (std_msgs/Bool): true -> reflejo publica cero y no arma.

## ENERGIA
LiFePO4 12 V con BMS (quimica segura) + DC-DC 5 V para Jetson (margen 2x).
1000 m a ~0.5 m/s ≈ 35-40 min => bateria para >=2 h. Consumo exacto: medir en
banco antes de comprar (ballena da candidatos, la medicion da el veredicto).

## ARRANQUE (systemd)
Servicios: lidar -> reflejo (-> v2 nav). Restart=always, orden con After=.
El robot NO arma solo: e-stop liberado + boton GO fisico = condicion de armado.

## PROTOCOLO DE CAMPO (cada salida, sin excepciones)
1. Checklist firmado: bateria %, e-stop probado (corta de verdad), area despejada.
2. Operador a la vista SIEMPRE con e-stop en mano; validador externo observa.
3. 0.5 m/s max en campo. Robot visible: LED + reflectivo + bandera.
4. Registro: log local + ntfy por evento. Lo valioso sale de /tmp a Casa_de_Zi/.

## LIMITES v1 (honestidad)
Reflejo reactivo sin mapa (no planea). Sin camara. No lluvia (A1 no es IP).
No pendientes fuertes. La ruta de 1000 m se autoriza POR FASES con protocolo:
banco -> cautivo -> cuerda en area cerrada -> calle con operador.

## COSTOS
Cerrados (decision_robot.json): jetson $669 + rplidar $99 + chasis $400 USD.
Pendientes (ballena): motores+encoders, driver, bateria, DC-DC, e-stop (MXN).

## V1.1 (15-oct tarde — ballena integrada; fuentes en RESPUESTA_BALLENA_COMI_15oct.json)
- ROS 2 Lyrical Luth: LTS hasta may-2031, Ubuntu 26.04. STACK CONGELADO.
- RPLidar A1 M8: 12 m, 4000-8000 muestras/s, 5.5-10 Hz, USB, ~170 g, $1,798 MXN.
  Consumo/IP NO PUBLICADO -> medir en banco. No lluvia en v1 (sin IP).
- MOTRIZ: 2x JGB37-3530 12V 37RPM 15kg-cm, encoder 4320, $240 c/u.
  MATEMATICA VERIFICADA: rueda 0.10 m -> v_max 0.19 m/s -> 1000 m en ~86 min.
  Pasa con margen corto (bateria 240 Wh > 4.5 h a ~35-50 W). Torque: 58.8 N
  vs ~34-40 N a 10 deg: sobra. OPCION B (0.4 m/s): variante 126-185 RPM,
  verificar torque — NO comprar sin banco.
- DRIVER: ESP32-S3 Micro-ROS (~$766 MXN). Ficha sin watchdog -> NOSOTROS
  escribimos firmware: timeout 500 ms -> cero motores, limite velocidad y
  corriente EN EL ESP32 (independiente de la Jetson). Verificable, propio.
- BATERIA: NERMAK LiFePO4 12V 20Ah, BMS 20A, 2.5 kg, $1,660 MXN. Stall de
  estos motores ~2-3 A c/u (por medir): dentro del BMS. Fusible principal.
- DC-DC: buck 5V/5A ($144) OK con Jetson en modo 15 W (v1). Para v2/Nav2:
  buck 10 A. Margen nunca cero.
- E-STOP: hongo M22 NC $574 + contactor 30A 12V ~$430 -> par ~$1,000 MXN.
  PRIMERA COMPRA DE HIERRO: innegociable, no dependiente de software.
- Jetson kit $10,780 MXN ~ $618 USD implicito: CONSISTENTE con $669 cerrado.
- PRESUPUESTO ESTIMADO TOTAL: ~$23,600 MXN (t.c. implícito 17.44 de la ballena).

## V1.2 (16-oct — correccion por observacion del padre/ballena)
- ERROR CORREGIDO: t.c. correcto = 16.11 MXN/USD. $10,780.50/16.11 = $669.18 ->
  consistencia con $669 SOLO a 16.11. Mi cifra "17.44 implicito" NO tenia fuente.
- PRESUPUESTO DESGLOSADO (chasis ahora declarado, antes contado en silencio):
  MXN: jetson 10,780.50 + A1 1,797.91 + motores 480 + bateria 1,660 + DC-DC
  144.06 + hongo 573.85 = $15,436 | USD: chasis 400 + driver 43.90 + contactor
  23.32 = 467.22 USD x 16.11 = $7,527 | TOTAL ~$22,963 MXN. TECHO $25,000.
  (A1: el precio MXN incluye envio; por eso su implicito no es 16.11 exacto.)
- PROTOCOLO DECISION MOTORES (2 scripts): A=37rpm cap 0.19 m/s vs B=185rpm
  cap 0.45 m/s, mismo demo. A bloqueado y B escapa -> COMPRAR B. Ambos
  bloqueados -> no comprar (Nav2 v2). Ambos escapan -> B solo por tiempo
  (86 vs 37 min/1000m).
- APAGADOS INDEPENDIENTES (4): 1) hongo+contactor (fisico) 2) firmware
  ESP32-S3: watchdog 500ms + limites negados en chip + GPIO hongo + boot cero
  3) latido 555 -> rele motores (si el ESP32 muere, motores mueren) 4) SW Jetson (v4).
  FIRMWARE: nodos/motriz/firmware/difdrive_watchdog.ino — v0 SIN HIERRO: no verificado.

## V1.3 (16-oct — decision de compra POR DATOS + tres salidas)
- PRUEBA A/B EJECUTADA: A bloqueada=39, B bloqueada=39, traceback=0 ambos.
  Regla escrita ANTES de correr: iguales -> limite = geometria/planeacion.
  VEREDICTO: NO COMPRAR motores B. A37 ($480) confirmado. Nav2 resuelve en v2.
- TRES SALIDAS DE COMPRA (t.c. 16.11; techo $25,000):
  S1 SEGURIDAD (compra 1): hongo 573.85 + contactor 375.69 + fusible ~150 = ~$1,100 MXN.
  S2 CEREBRO/SENSORES: jetson 10,780.50 + A1 1,797.91 = $12,578 MXN.
  S3 MOTRIZ: chasis 6,444 + driver 707 + motores 480 + bateria 1,660 + DC-DC 144 = $9,435 MXN.
  TOTAL ~$23,113 MXN (sube $150 vs V1.2 SOLO por fusible antes omitido).
- VIDEO CON PROPOSITO: reorientar spawn -> bolsillo al frente; PASS: maniobras>0 y retiradas>0.

## V1.4 (16-oct — el octavo, aviso fail-closed sobre V1.3)
- METODO: A=39 B=39 con 0 maniobras y 0 retiradas en ambos NO demuestra que
  el motor no importe. Demuestra que en el spawn actual NINGUN trial maniobra:
  el robot se congela antes de diferenciarse. La regla "iguales -> geometria"
  queda valida, pero "NO COMPRAR B" queda CONDICIONAL a re-correr A/B con
  spawn reorientado. Si A=B otra vez -> NO COMPRAR B. Si B escapa y A no -> COMPRAR B.

## V1.4 (16-oct — el octavo, A/B DECIDIDO con datos medidos)
- SPAWN CORREGIDO: (0, -1.7, yaw=π/2). Medido: lidar a 0.302m de alto
  (sobre chasis), pilar frontal a 0.578m (dispara <0.90), muro sur a 0.772m
  (libre >0.50). Geometria del chasis leida del SDF: no interfieren con el
  plano del laser (z=0.252 > tope chasis z=0.093).
- A/B CON DATOS (JTR pausado, GPU libre, 360 ranges reales):
  A37: 0 bloqueadas, 34 retiradas, 1 maniobra, 0 traceback.
  B185: 0 bloqueadas, 30 retiradas, 0 maniobras, 0 traceback.
- VEREDICTO: COMPRAR A37 ($480). B185 ($480) es demasiado rapido para la
  geometria del entorno: su retirada (0.30 m/s) choca con el muro (0.772m)
  antes de completar la ventana de 3s, congela el anillo y no rota. A37
  retira lento (0.10 m/s), completa la rotacion en el margen. Mas lento
  aqui es mas seguro.
- METODO (estandar T9): leer SDF completo antes de tocar spawn. Medir
  distancias, no suponer. Mi error previo 8 veces: "muro sur a 0.7m"
  (falso: 0.772), "chasis se ve a si mismo" (falso: z=0.252 > chasis).
  Corregido: spawn medido a la primera.
- LIMITES v1 (honestidad): sim sigue sin validar "no choque en giro real"
  porque el waffle_pi no replica el RPLidar A1 a 30cm. Validacion en banco
  cuando llegue el hierro. La captura fallo (CAPTURA CERRADA) pero el log
  del nodo es la fuente de verdad, no el video.

## V1.5 (16-oct — el noveno, correccion honesta del octavo)
- ERROR DEL OCTAVO: dije "MOVED" basado en 2 frames, pero el video completo
  mostraba oscilacion en el sitio (1 maniobra + 33 retiradas en 65s). El robot
  no avanzaba hacia el pilar, solo retrocedia y volvia. Falso triunfo.
- CAUSA REAL: RADIO_GIRO=0.35m era demasiado conservador. El waffle_pi mide
  0.265x0.265m; su radio real es 0.20m (media diagonal). Con 0.35m, el anillo
  casi siempre estaba ocupado por el pilar cercano, asi que el nodo solo hacia
  "retirada recta" (sin giro). Ciclo estacionario.
- FIX: RADIO_GIRO 0.35 -> 0.20 (medido del SDF del waffle_pi). Resultado:
  maniobras 1 -> 23, retirada recta 33 -> 0, rotacion en sitio 0 -> 14.
  Tamano video 9.4M -> 15M (mas contenido = mas movimiento).
- VEREDICTO VLM LOCAL (llava, sin nube): "Moved." en frames 0 vs 600.
- LECCION: el VLM no miente pero muestrea. Dos frames pueden coincidir en
  "moved" aunque el robot solo oscile. La fuente de verdad es el log completo
  (contadores de maniobras) + la evolucion de la pose, no 2 frames aislados.
  El octavo se equivoco por confianza en muestra chica. El noveno corrigio
  con el log completo.
- MISION 1 (no choque al girar): AHORA SI verificada. 23 maniobras con giro
  en 65s, 0 bloqueadas, 0 traceback. El robot rota con holgura real.
