pgrep -f "gz-sim-main" || pgrep -f "gz sim" |#!/bin/bash
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |cd "$(dirname "$0")"
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |./detener_sim.sh >/dev/null 2>&1
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |source /opt/ros/lyrical/setup.bash
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |export TURTLEBOT3_MODEL=burger GZ_IP=127.0.0.1 IGN_IP=127.0.0.1
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |export GZ_SIM_RESOURCE_PATH=/opt/ros/lyrical/share/turtlebot3_gazebo/models:${GZ_SIM_RESOURCE_PATH}
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |# FIX v4: --force-version 10 (el wrapper se cuelga sin el) + chequeo por LOG
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |nohup stdbuf -oL -eL gz sim --force-version 10 -r -s -v2 /opt/ros/lyrical/share/turtlebot3_gazebo/worlds/turtlebot3_world.world >/tmp/gz_server.log 2>&1 &
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |GZPID=$!
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |LISTO=0
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |for i in $(seq 1 30); do
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |  grep -q "Serving world names" /tmp/gz_server.log && { LISTO=1; break; }
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |  if ! kill -0 $GZPID 2>/dev/null; then
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |    echo "== SERVIDOR GZ MURIO. Log: =="; tail -15 /tmp/gz_server.log; exit 1
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |  fi
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |  sleep 1
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |done
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |[ $LISTO -eq 0 ] && { echo "== TIMEOUT. Log: =="; tail -15 /tmp/gz_server.log; exit 1; }
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |echo "== SERVIDOR GZ VIVO (pid $GZPID) =="
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |nohup ros2 launch turtlebot3_gazebo robot_state_publisher.launch.py >/tmp/rsp.log 2>&1 &
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |sleep 3
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |SPAWN=0
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |for i in 1 2 3; do
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |  if ros2 run ros_gz_sim create -file /home/omar/proyectos/comi_colima/nodos/torta_ahogada.sdf -x 2 -y 0 -z 0.05; then SPAWN=1; break; fi
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |  echo "intento $i fallo, reintentando..."; sleep 3
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |done
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |[ $SPAWN -eq 1 ] && echo "SPAWN OK" || { echo "== SPAWN FALLO. Log: =="; tail -15 /tmp/gz_server.log; }
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |nohup ros2 run ros_gz_bridge parameter_bridge --ros-args -p config_file:=/opt/ros/lyrical/share/turtlebot3_gazebo/params/turtlebot3_burger_bridge.yaml >/tmp/bridge.log 2>&1 &
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |sleep 2
pgrep -f "gz-sim-main" || pgrep -f "gz sim" |echo "== MUNDO LISTO. Terminal libre =="
