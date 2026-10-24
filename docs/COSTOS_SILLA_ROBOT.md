# COSTOS - SILLA DE RUEDAS ROBOT (comi-colima / el Noveno)
Fecha: 13-oct-2026. Estado: ESQUELETO - precios por verificar (MercadoLibre/aliexpress HOY).
Regla: nada existe hasta que la terminal lo confirma. Moneda: MXN.

## COMPONENTES EXTRA (lista ballena 12-oct; fila 7 = resto pendiente del JSON)
| # | Componente     | Modelo     | Uso                          | Precio MXN | Estado    |
|---|----------------|------------|------------------------------|------------|-----------|
| 1 | Lidar 2D       | RPLidar A1 | navegacion/evitar obstaculos | PENDIENTE  | VERIFICAR |
| 2 | GPS            | NEO-M9N    | telemetria + dispatch        | PENDIENTE  | VERIFICAR |
| 3 | IMU 6 ejes     | MPU6050    | orientacion                  | PENDIENTE  | VERIFICAR |
| 4 | Barometro      | BMP280     | presion/altura               | PENDIENTE  | VERIFICAR |
| 5 | Microfono MEMS | INMP441    | comando de voz               | PENDIENTE  | VERIFICAR |
| 6 | Buzzer         | 110 dB     | alertas audibles (se OYE)    | PENDIENTE  | VERIFICAR |
| 7 | DEMAS DEL JSON | ballena    | por pegar                    | PENDIENTE  | VERIFICAR |

## MANO DE OBRA (regla: el que ayuda, cobra)
| Concepto        | Monto  |
|-----------------|--------|
| Ayudantes extra | $5,000 |

## FALTAN POR DECIDIR (Omar + JSON ballena)
- Motores + drivers, bateria, SBC (RPi?), cableado, conectores, tornilleria, impresion 3D.

## FODA (regla 12-oct)
- Fortalezas: base donada (INCODIS), equipo local, diseno para gente comun (se OYE, no se lee).
- Oportunidades: NLnet/financiamiento, replicable para mas discapacitados de Colima.
- Debilidades: componentes importados, tiempos de envio, dependencia de donaciones.
- Amenazas: aduanas/impuestos, pieza defectuosa, temporada de huracanes.

## PROXIMOS PASOS
1. Omar pega JSON ballena 12-oct -> llenar estimados reales.
2. Verificar precios hoy en MercadoLibre/aliexpress -> actualizar tabla.
3. Suma total = presupuesto del Noveno (componentes + $5,000 mano de obra).

## TREN MOTRIZ (JSON ballena 2-oct, flota_trenmotriz_2oct.json)
| Concepto                          | Costo MXN      |
|-----------------------------------|----------------|
| A) Silla electrica usada COMPLETA (motores 24V 200-400W + controladora + bateria + ruedas) | 2,700-7,200 |
| B) Compra minima: 2x motor 24V 150RPM (267 c/u Amazon) + IBT-2 (300-500) + LiFePO4 12V 9Ah (936 Etech) + chasis 4WD (450-600) | ~2,600-3,400 |
| Scooter movilidad usado (todo completo) | 15,000-22,000 |
| Energia: panel 200-400W solar (3-6k) / burger 50-100W (1.2-2.7k) | opcional |
| Carga util a disenar: 10-15 kg (4-8 pedidos) | diseno |
| ROS2: sin driver IBT-2 -> micro-ROS/Arduino intermediario | nota tecnica |

## SENSORES (JSON ballena 12-oct -> silla_sensores_12oct.json)
| Sensor | Modelo | USD | MXN (TC 18.5) |
|--------|--------|-----|----------------|
| RPLidar A1 | A1M8-R6 | 103.12 | ~1,908 |
| NEO-M9N GPS | SparkFun Qwiic | 76.50 | ~1,415 |
| MPU6050 IMU | GY-521 | 8.55 | ~158 |
| BMP280 barometro | Zio Qwiic | 7.99 | ~148 |
| INMP441 mic I2S | MEMS | 5.00 | ~93 |
| Buzzer 110dB | x2 IP67 12V | 410 MXN el par | 410 |
| SUBTOTAL SENSORES | | ~223.32 | ~4,130 |

ERROR BALLENA CORREGIDO: puso $205 USD por buzzer; su propia nota dice $410 MXN/2uds.
Total ballena $406 USD -> real ~$223 USD / ~$4,130 MXN.

## PRESUPUESTO PRELIMINAR (13-oct)
- Sensores: ~$4,130
- Tren motriz: $2,600-7,200 (opcion A usada o B nueva)
- Ayudantes (el que ayuda, cobra): $5,000
- TOTAL: ~$11,730-16,330 MXN (FALTA sumar: SBC/RPi, cableado, tornilleria, impresion 3D)
