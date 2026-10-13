<!-- CANARIO RVCQ0960 | nacido 2026-10-13 | repo OmarAbdielAlvarado/comi-colima -->
# COMI-COLIMA 🤖🇲🇽
*Reparto con robots en Colima — antes conocido como "Doña Chávez"*

Robots repartidores de comida con seguimiento GPS en vivo para el dueño y
operación pensada para personas con discapacidad: el software se opera desde
un escritorio accesible y la flota avisa por voz.

**Estado:** demo autónoma en simulación validada (Gazebo + ROS 2) · voz real
en español mexicano · prototipo físico en preparación (plataforma sobre
silla de ruedas reacondicionada).

## Demo en simulación (lo que ya corre)
- Robot de 6 ruedas `nodos/flota_6.sdf` en Gazebo (gz-sim 10): chasis
  0.6 × 0.4 × 0.25 m, 15 kg, control por velocidad (VelocityControl).
- Navegación autónoma con LiDAR: detección de obstáculo (~0.9 m) →
  maniobra retro + giro + enfriamiento; ruta demo con ~4 m netos.
- Voz simultánea: Piper es-MX en la PC + canal ntfy → Android
  (Termux TTS, "Jorge"). Ver `1_scripts_core/nodo_voz_ntfy.py`.
- Bridge ROS 2 ↔ Gazebo (`nodos/bridge_flota.yaml`): `TwistStamped` →
  `/model/flota_6/cmd_vel` + scan LiDAR GZ→ROS.

Mapa de demo: `3_mapa/mapa_donachavez.html` — clientes ficticios
(teléfonos 555) + toggle SPRINGFIELD ON/OFF (ON = capa ficción para demo,
OFF = anclas reales de Colima para revisión técnica).

Instrucciones: `nodos/README_DEMO.md` (scripts `iniciar_sim.sh` /
`detener_sim.sh`).

## Stack
ROS 2 · Gazebo (gz-sim 10) · Python · Piper TTS (es-MX) · ntfy · HTML/JS

## Estructura
- `1_scripts_core/` — capa de voz (nodo local + ntfy)
- `2_datos_demo/` — clientes demo, capa real (OSM), overlay Springfield
- `3_mapa/` — mapa HTML interactivo
- `nodos/` — simulación (SDF, bridges, scripts) y nodo autónomo
- `docs/` — ROADMAP, convención de nombres, decisión de robot
- `archivados/` — versiones previas

## Roadmap
- FASE A — dirección del cliente → coordenada (geocoding sobre CSV)
- FASE B — pedido → robot → GPS en vivo visible por el dueño
- FASE C — aviso al cliente "2 min antes" con ubicación del robot
- FASE D (compromiso social) — el operador que despacha los robots es una
  PERSONA CON DISCAPACIDAD: empleo real usando nuestro software

## Accesibilidad y reuso (e-waste)
Los celulares Android descartados se reacondicionan como puente de voz y
control de los robots. Menos desechos, más empleo accesible:
*trabajo con lo que tengo*.

## Licencia
MIT
