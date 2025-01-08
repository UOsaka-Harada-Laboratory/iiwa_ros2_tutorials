#!/bin/bash

byobu new-session -d -s test_lbr_fri_ros2_stack
byobu select-pane -t 0
byobu split-window -v
byobu select-pane -t 0
byobu split-window -h
byobu select-pane -t 2
byobu split-window -h
byobu select-pane -t 3

byobu send-keys -t 0 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_bringup mock.launch.py model:=iiwa14"' 'C-m'
sleep 2.
byobu send-keys -t 1 'xhost + && docker exec -it iiwa_ros2_container bash -it -c "ros2 launch lbr_bringup rviz.launch.py rviz_cfg_pkg:=lbr_bringup rviz_cfg:=config/mock.rviz"' 'C-m'

byobu attach -t test_lbr_fri_ros2_stack