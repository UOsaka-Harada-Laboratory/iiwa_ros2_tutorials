#!/bin/bash

# FRI send period: 2 ms
# IP address: your configuration
# FRI control mode: CARTESIAN_IMPEDANCE_CONTROL
# FRI client command mode: WRENCH

byobu new-session -d -s demo_wrench_command_controller
byobu select-pane -t 0
byobu split-window -v
byobu select-pane -t 0
byobu split-window -h
byobu select-pane -t 2
byobu split-window -h
byobu select-pane -t 3

byobu send-keys -t 0 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "cp --force /yaml/lbr_system_config_wrench_command_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml"' 'C-m'
sleep 1.
byobu send-keys -t 1 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "cp --force /yaml/lbr_controllers_wrench_command_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml"' 'C-m'
sleep 1.
byobu send-keys -t 0 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_bringup hardware.launch.py ctrl:=lbr_wrench_command_controller model:=iiwa14"' 'C-m'
sleep 3.
byobu send-keys -t 1 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "ros2 run lbr_demos_cpp wrench_sine_overlay --ros-args -r __ns:=/lbr"' 'C-m'

byobu attach -t demo_wrench_command_controller