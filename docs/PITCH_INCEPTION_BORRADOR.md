# SOLICITUD NVIDIA INCEPTION — BORRADOR v1 (3-oct-2026)
Estado: en espanol para validar contenido. Traduccion al ingles despues del OK.
Etapa que se declara: PROTOTIPO (simulacion validada + fisico en construccion).

## Descripcion del proyecto
COMI-COLIMA (por Vemos) construye robots repartidores de comida de bajo costo
para ciudades medianas de Mexico, operados remotamente desde un escritorio
accesible por personas con discapacidad. Nuestro software (ROS 2, open source)
convierte plataformas reacondicionadas — sillas de ruedas en desuso, celulares
Android descartados como puentes de voz — en flota de ultima milla con
navegacion autonoma por LiDAR y supervision por voz en espanol mexicano.

El problema es medible: 2,885 motociclistas fallecidos en Mexico en 2023
(maximo historico, INEGI). El colectivo Ni Un Repartidor Menos documenta 453
repartidores atropellados en servicio entre 2020 y 2024 (~90/ano). En Colima,
el 48.5% de las muertes viales son motociclistas (tercer lugar nacional).
El reparto no va a desaparecer: nuestro objetivo es que el trabajo deje la
calle peligrosa y se mude al escritorio seguro, creando empleo accesible
en lugar de destruirlo.

Modelo de negocio: venta de equipo + configuracion a negocios locales;
operacion remota como servicio. Cada robot puede ser operado desde casa
por una persona con discapacidad: empleo tecnologico accesible real.

## Uso de tecnologia NVIDIA
- Entrenamiento local en CUDA (RTX existente): vision para deteccion de
  obstaculos y peatones, complementando el LiDAR 2D.
- Despliegue en Jetson Orin Nano: cerebro de cada robot (navegacion + voz).
- Ruta a Isaac Sim: migrar la validacion actual (Gazebo gz-sim 10) a
  simulacion fotorrealista y generacion de datos sinteticos.

## Traccion actual
- Simulacion autonoma completa PUBLICADA (GitHub): robot de 6 ruedas,
  evasion de obstaculos por LiDAR, voz simultanea local (Piper es-MX)
  y remota (ntfy -> Android).
- Prototipo fisico en construccion sobre silla de ruedas reacondicionada
  (gestion en curso con instituto estatal de discapacidad).
- Presupuesto de hardware definido con costos verificados (~$3,500 USD:
  2 robots + GPU usada + RAM, propiedad total del proyecto).
- Filosofia e-waste: hardware descartado reacondicionado como parte
  operativa (angulo de sostenibilidad para marcas).

## Peticion
- 2x Jetson Orin Nano para los 2 primeros prototipos fisicos.
- Creditos GPU para entrenamiento de vision.
- Mentoría Inception para escalar via incubadoras estatales (en curso).

## Equipo
Omar Abdiel Alvarado — Administrador de Organizaciones; Ingenieria (en
proceso); Maestria en Calidad (en proceso). Usuario con discapacidad visual
desarrollando herramientas accesibles para su comunidad (proyectos open
source publicos en GitHub).
