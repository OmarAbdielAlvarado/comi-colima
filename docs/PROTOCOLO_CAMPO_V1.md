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
