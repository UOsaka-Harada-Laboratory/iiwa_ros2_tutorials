#!/bin/bash

byobu new-session -d -s demo_moveit_action_simulation_py
byobu select-pane -t 0
byobu split-window -v
byobu select-pane -t 0
byobu split-window -h
byobu select-pane -t 2
byobu split-window -h
byobu select-pane -t 3

byobu send-keys -t 0 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_bringup mock.launch.py moveit:=true model:=iiwa14"' 'C-m'
sleep 2.
byobu send-keys -t 1 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_bringup move_group.launch.py mode:=mock rviz:=true model:=iiwa14"' 'C-m'
sleep 5.
byobu send-keys -t 2 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_moveit_py hello_moveit_action.launch.py mode:=mock model:=iiwa14"' 'C-m'

byobu attach -t demo_moveit_action_simulation_py