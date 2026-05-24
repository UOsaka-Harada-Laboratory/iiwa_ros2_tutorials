#!/bin/bash

# Simulation variant of demo_joint_position_command_controller.sh.
#
# The hardware demo relies on `joint_sine_overlay`, which only commands the
# robot while the FRI session state is COMMANDING_ACTIVE. That state requires a
# real KUKA robot, so the demo cannot move the robot in simulation.
#
# This script instead launches the robot with `mock.launch.py`, shows it in
# RViz, and runs `joint_sine_overlay_sim.py` (no FRI dependency) to overlay a
# sine wave on joint A4 of the simulated robot.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# stop a previous run of this byobu session and any leftover ROS processes in
# the container. Stale launches from earlier demo runs keep their nodes alive
# and exhaust DDS discovery, which makes the controller spawners fail with
# "Controller manager not available".
byobu kill-session -t demo_joint_position_command_controller_simulation 2>/dev/null
docker exec iiwa_ros2_container bash -c "pkill -f 'ros2 launc[h]' 2>/dev/null; pkill -f 'joint_sine_overlay_si[m]' 2>/dev/null; sleep 4; pkill -9 -f 'ros2 launc[h]' 2>/dev/null; pkill -9 -f 'ros2_contro[l]_node' 2>/dev/null; pkill -9 -f 'robot_state_publishe[r]' 2>/dev/null; pkill -9 -f 'rviz[2]' 2>/dev/null; pkill -9 -f 'move_grou[p]' 2>/dev/null; pkill -9 -f 'static_transform_publishe[r]' 2>/dev/null; true"

# copy the simulation sine overlay node into the running container
docker cp "${SCRIPT_DIR}/joint_sine_overlay_sim.py" \
    iiwa_ros2_container:/root/joint_sine_overlay_sim.py

byobu new-session -d -s demo_joint_position_command_controller_simulation
byobu select-pane -t 0
byobu split-window -v
byobu select-pane -t 0
byobu split-window -h
byobu select-pane -t 2
byobu split-window -h
byobu select-pane -t 3

byobu send-keys -t 0 '(xhost +local:root >/dev/null 2>&1 || true); docker exec -it iiwa_ros2_container bash -it -c "cp --force /yaml/lbr_controllers_position_command_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml"' 'C-m'
sleep 1
byobu send-keys -t 0 '(xhost +local:root >/dev/null 2>&1 || true); docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_bringup mock.launch.py ctrl:=lbr_joint_position_command_controller model:=iiwa14"' 'C-m'
sleep 8
byobu send-keys -t 1 '(xhost +local:root >/dev/null 2>&1 || true); docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_bringup rviz.launch.py rviz_cfg_pkg:=lbr_bringup rviz_cfg:=config/mock.rviz"' 'C-m'
sleep 5
byobu send-keys -t 2 '(xhost +local:root >/dev/null 2>&1 || true); docker exec -it iiwa_ros2_container bash -it -c "python3 /root/joint_sine_overlay_sim.py --ros-args -r __ns:=/lbr"' 'C-m'

byobu attach -t demo_joint_position_command_controller_simulation
