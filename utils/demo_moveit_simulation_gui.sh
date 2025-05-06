#!/bin/bash

byobu new-session -d -s demo_moveit_simulation_gui
byobu select-pane -t 0
byobu split-window -v
byobu select-pane -t 0
byobu split-window -h
byobu select-pane -t 2
byobu split-window -h
byobu select-pane -t 3

byobu send-keys -t 0 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_bringup mock.launch.py model:=iiwa14"' 'C-m'
sleep 1.
byobu send-keys -t 1 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_bringup move_group.launch.py mode:=mock rviz:=true model:=iiwa14"' 'C-m'

byobu attach -t demo_moveit_simulation_gui