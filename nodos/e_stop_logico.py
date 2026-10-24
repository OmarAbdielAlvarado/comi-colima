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
