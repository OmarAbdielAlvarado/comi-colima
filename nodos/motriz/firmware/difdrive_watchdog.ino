// difdrive_watchdog.ino — ESP32-S3 (micro-ROS) — v0 SIN HIERRO: NO VERIFICADO
// Regla de casa: nada existe hasta que el hardware lo confirma. Este archivo
// se compila y prueba CUANDO llegue el driver. Capa 2 de apagado: aun con la
// Jetson viva y loca, los motores mueren solos. (Capa 1: hongo + contactor.)
#include <micro_ros_arduino.h>
#include <rcl/rcl.h>
#include <rclc/rclc.h>
#include <rclc/executor.h>
#include <geometry_msgs/msg/twist_stamped.h>

// ---- LIMITES DUROS EN FIRMWARE: la Jetson pide mas, AQUI se niega ----
static const float MAX_V = 0.50f;         // m/s (A=0.19 | B=0.97: ajustar por variante)
static const float MAX_W = 1.50f;         // rad/s
static const uint32_t WATCHDOG_MS = 500;  // sin cmd_vel fresco -> cero
static const int PIN_ESTOP = 4;  // hongo NC a GND + pullup: reposo=LOW (OK),
                                 // presionado/corte=HIGH (paro). Igual que el contactor.
// Pines AJUSTAR al hierro real (L298/DRV8833): PWM por LEDC, DIR digital,
// encoders cuadratura por interrupcion.
static const int PIN_PWML=5, PIN_DIRL=6, PIN_PWMR=7, PIN_DIRR=15;
static const int PIN_ENCL_A=16, PIN_ENCR_A=17;
static const int PIN_LATIDO = 18; // toggle cada 100ms: alimenta monoestable 555
                                 // que mantiene el rele de motores (capa 3).

rclc_support_t sup; rcl_node_t nodo; rclc_executor_t exe;
rcl_subscription_t sub_cmd; rcl_timer_t timer;
geometry_msgs__msg__TwistStamped cmd;
volatile long encL=0, encR=0;
uint32_t t_ultimo_cmd=0, t_latido=0; bool armado=false;

void aplicar(float vl, float vr){ // TODO(banco): LEDC duty + DIR segun signo
  (void)vl; (void)vr; }

void cb_cmd(const void *msgin){
  const geometry_msgs__msg__TwistStamped *m=(const geometry_msgs__msg__TwistStamped*)msgin;
  float v=m->twist.linear.x, w=m->twist.angular.z;
  if(v> MAX_V) v= MAX_V; if(v<-MAX_V) v=-MAX_V;   // techo en el chip
  if(w> MAX_W) w= MAX_W; if(w<-MAX_W) w=-MAX_W;
  // TODO(banco): v,w -> vl,vr con geometria real (L,R) + PID contra encoders
  aplicar(v-w, v+w);   // placeholder dif-drive; reemplazar con PID real
  t_ultimo_cmd=millis(); armado=true;
}

void cb_timer(rcl_timer_t *t, int64_t last){
  uint32_t ahora=millis();
  if(ahora-t_latido>100){ t_latido=ahora; digitalWrite(PIN_LATIDO,
      digitalRead(PIN_LATIDO)==HIGH?LOW:HIGH); }   // latido para el 555
  bool vivo = armado && (ahora-t_ultimo_cmd)<WATCHDOG_MS;
  bool estop_ok = (digitalRead(PIN_ESTOP)==LOW);
  if(!vivo || !estop_ok){ aplicar(0,0); armado=false; }  // FAIL-CLOSED
}

void setup(){
  pinMode(PIN_ESTOP,INPUT_PULLUP);
  pinMode(PIN_PWML,OUTPUT); pinMode(PIN_DIRL,OUTPUT);
  pinMode(PIN_PWMR,OUTPUT); pinMode(PIN_DIRR,OUTPUT);
  pinMode(PIN_LATIDO,OUTPUT);
  aplicar(0,0);                       // cero ANTES de conectarse a nada
  attachInterrupt(digitalPinToInterrupt(PIN_ENCL_A), [](){encL++;}, RISING);
  attachInterrupt(digitalPinToInterrupt(PIN_ENCR_A), [](){encR++;}, RISING);
  set_microros_transports();          // TODO(banco): serial vs WiFi-agent
  rclc_support_init(&sup,0,NULL,NULL);
  rclc_node_init_default(&nodo,"motriz_esp32","",&sup);
  rclc_subscription_init_default(&sub_cmd,&nodo,
    ROSIDL_GET_MSG_TYPE_SUPPORT(geometry_msgs,msg,TwistStamped),"/cmd_vel");
  rclc_timer_init_default(&timer,&sup,RCL_MS_TO_NS(20),cb_timer); // 50 Hz
  rclc_executor_init(&exe,&sup.context,2,&sup.context);
  rclc_executor_add_subscription(&exe,&sub_cmd,&cmd,&cb_cmd,ON_NEW_DATA);
  rclc_executor_add_timer(&exe,&timer);
}
void loop(){ rclc_executor_spin_some(&exe,1000); }
