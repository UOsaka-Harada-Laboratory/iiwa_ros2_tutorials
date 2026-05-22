#!/usr/bin/env python3
"""Simulation-friendly joint sine overlay for the LBR joint position command controller.

The upstream ``joint_sine_overlay`` demo (``lbr_demos_cpp`` / ``lbr_demos_py``)
only publishes joint position commands while the FRI session state is
``COMMANDING_ACTIVE``. That state is produced exclusively by a real FRI
connection, so the demo never moves the robot in ``mock`` / ``gazebo``
simulation.

This node reproduces the same sinusoidal overlay without depending on the FRI
session state. It takes the current joint configuration from ``joint_states``
(published by ``joint_state_broadcaster``) and publishes
``LBRJointPositionCommand`` messages to ``command/joint_position``, which the
``lbr_joint_position_command_controller`` forwards to the (simulated) robot.
"""

import math
import sys

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import JointState

# import lbr_fri_idl
from lbr_fri_idl.msg import LBRJointPositionCommand


class JointSineOverlaySimNode(Node):
    def __init__(self) -> None:
        super().__init__("joint_sine_overlay_sim")

        # parameters
        self._robot_name = self.declare_parameter("robot_name", "lbr").value
        self._amplitude = self.declare_parameter("amplitude", 0.2).value  # rad
        self._frequency = self.declare_parameter("frequency", 0.25).value  # Hz
        self._joint = self.declare_parameter("joint", 3).value  # 0-indexed, A4
        self._command_rate = self.declare_parameter("command_rate", 100.0).value  # Hz

        self._joint_names = [f"{self._robot_name}_A{i}" for i in range(1, 8)]
        self._dt = 1.0 / float(self._command_rate)
        self._phase = 0.0
        self._initial_position = None  # captured from the first joint_states message

        # create publisher to command/joint_position
        self._command_pub = self.create_publisher(
            LBRJointPositionCommand, "command/joint_position", 1
        )

        # create subscription to joint_states (instead of the FRI-only state topic)
        self._joint_state_sub = self.create_subscription(
            JointState, "joint_states", self._on_joint_state, 1
        )

        self._timer = self.create_timer(self._dt, self._on_timer)

        self.get_logger().info(
            f"Overlaying a sine wave (amplitude {self._amplitude} rad, "
            f"frequency {self._frequency} Hz) on joint "
            f"{self._joint_names[self._joint]}."
        )
        self.get_logger().info("Waiting for joint_states...")

    def _on_joint_state(self, joint_state: JointState) -> None:
        if self._initial_position is not None:
            return
        name_to_position = dict(zip(joint_state.name, joint_state.position))
        try:
            self._initial_position = [
                float(name_to_position[name]) for name in self._joint_names
            ]
        except KeyError:
            # joint_states does not (yet) contain all lbr joints
            return
        self.get_logger().info(
            f"Captured initial joint configuration: {self._initial_position}"
        )

    def _on_timer(self) -> None:
        if self._initial_position is None:
            return
        joint_position = list(self._initial_position)
        joint_position[self._joint] += self._amplitude * math.sin(self._phase)
        self._phase += 2.0 * math.pi * self._frequency * self._dt

        command = LBRJointPositionCommand()
        command.joint_position = joint_position
        self._command_pub.publish(command)


def main(args: list = None) -> None:
    rclpy.init(args=args if args is not None else sys.argv)
    node = JointSineOverlaySimNode()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        if rclpy.ok():
            rclpy.shutdown()


if __name__ == "__main__":
    main()
