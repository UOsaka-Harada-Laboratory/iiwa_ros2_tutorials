#!/bin/bash

# stop a previous run of this byobu session and any leftover ROS processes in
# the container. Stale launches from earlier demo runs keep their nodes alive
# and exhaust DDS discovery, which makes the controller spawners fail with
# "Controller manager not available".
IIWA_ROS_DOMAIN_ID="${IIWA_ROS_DOMAIN_ID:-73}"

byobu kill-session -t bringup_lbr_urdf_gui 2>/dev/null
docker exec -e ROS_DOMAIN_ID="${IIWA_ROS_DOMAIN_ID}" iiwa_ros2_container bash -c "pkill -f 'ros2 launc[h]' 2>/dev/null; sleep 4; pkill -9 -f 'ros2 launc[h]' 2>/dev/null; pkill -9 -f 'ros2_contro[l]_node' 2>/dev/null; pkill -9 -f 'robot_state_publishe[r]' 2>/dev/null; pkill -9 -f 'rviz[2]' 2>/dev/null; pkill -9 -f 'move_grou[p]' 2>/dev/null; pkill -9 -f 'static_transform_publishe[r]' 2>/dev/null; true"

byobu new-session -d -s bringup_lbr_urdf_gui
byobu select-pane -t 0
byobu split-window -v
byobu select-pane -t 0
byobu split-window -h
byobu select-pane -t 2
byobu split-window -h
byobu select-pane -t 3

byobu send-keys -t 0 "(xhost +local:root >/dev/null 2>&1 || true); docker exec -e ROS_DOMAIN_ID=${IIWA_ROS_DOMAIN_ID} -it iiwa_ros2_container bash -it -c \"ros2 launch lbr_bringup mock_gui.launch.py model:=iiwa14\"" 'C-m'
sleep 2
byobu send-keys -t 1 "(xhost +local:root >/dev/null 2>&1 || true); docker exec -e ROS_DOMAIN_ID=${IIWA_ROS_DOMAIN_ID} -it iiwa_ros2_container bash -it -c \"ros2 launch lbr_bringup rviz.launch.py rviz_cfg_pkg:=lbr_bringup rviz_cfg:=config/mock_gui.rviz\"" 'C-m'

byobu attach -t bringup_lbr_urdf_gui
