#!/bin/bash
# Verifica: /e_stop=True congela al robot aunque el frente este libre
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
echo "=== POSE 1 (sin e-stop, robot debe moverse) ==="
timeout 4 gz topic -e -t /world/default/dynamic_pose/info -n 1 2>/dev/null | grep -A6 waffle_pi | grep "y:" | head -1
sleep 3
echo "=== activar e-stop ==="
ros2 topic pub /e_stop std_msgs/Bool "{data: true}" --once 2>&1 | tail -1
sleep 5
echo "=== POSE 2 (con e-stop, NO debe moverse) ==="
timeout 4 gz topic -e -t /world/default/dynamic_pose/info -n 1 2>/dev/null | grep -A6 waffle_pi | grep "y:" | head -1
echo "=== log: confirmar E-STOP RECIBIDO ==="
grep "E-STOP" /tmp/comi.log | tail -3
pkill -9 -f gz-sim-main 2>/dev/null; pkill -f parameter_bridge 2>/dev/null; pkill -f nodo_comi 2>/dev/null
