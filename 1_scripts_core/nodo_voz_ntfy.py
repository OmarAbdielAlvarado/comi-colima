#!/usr/bin/env python3
# COMI-COLIMA voz via ntfy->Android(Termux TTS "Jorge") — mismo mecanismo Vemos
import rclpy, urllib.request
from rclpy.node import Node
from std_msgs.msg import String
class Voz(Node):
    def __init__(self):
        super().__init__('voz_ntfy')
        self.create_subscription(String,'pedido',self.envia,10)
    def envia(self,m):
        self.get_logger().info(f"-> ntfy: {m.data}")
        try:
            urllib.request.urlopen(urllib.request.Request(
                "https://ntfy.sh/comicolima-voz", data=m.data.encode(),
                headers={"Title":"COMI-COLIMA"}),timeout=10)
        except Exception as e: self.get_logger().error(f"ntfy: {e}")
def main():
    rclpy.init(); n=Voz()
    try: rclpy.spin(n)
    except KeyboardInterrupt: pass
    finally: n.destroy_node(); rclpy.shutdown()
if __name__=='__main__': main()
