# base image
FROM ubuntu:22.04

# setting environmental variables
ENV DEBIAN_FRONTEND noninteractive
ARG MAKEFLAGS
ARG PARALLELWORKERS
ARG DISPLAY
ARG WAYLAND_DISPLAY
ARG XDG_RUNTIME_DIR
ARG PULSE_SERVER
ENV MAKEFLAGS $MAKEFLAGS
ENV PARALLELWORKERS $PARALLELWORKERS
ENV DISPLAY $DISPLAY
ENV WAYLAND_DISPLAY $WAYLAND_DISPLAY
ENV XDG_RUNTIME_DIR $XDG_RUNTIME_DIR
ENV PULSE_SERVER $PULSE_SERVER

# setting time zone
RUN apt update && apt install -y --no-install-recommends tzdata
ENV TZ=Asia/Tokyo

RUN apt update -y && apt upgrade -y && apt install -y --no-install-recommends \
    software-properties-common \
    libxkbcommon-x11-0 \
    build-essential \
    libgl1-mesa-dev \
    iputils-ping \
    lsb-release \
    libudev-dev \
    python3-pip \
    python3-tk \
    mesa-utils \
    net-tools \
    xorg-dev \
    x11-apps \
    libfuse2 \
    libxcb* \
    gnupg \
    byobu \
    cmake \
    curl \
    wget \
    dbus \
    git \
    vim \
    zip \
    && rm -rf /var/lib/apt/lists/*

# adding the ROS2 GPG key with apt and add the repository to your sources list
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN /bin/bash -c 'echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null'

# updating mesa (fix the issue of displaying black world in Rviz2 and Gazebo)
# https://github.com/ros2/rviz/issues/948
RUN add-apt-repository ppa:kisak/kisak-mesa -y && apt update -y

# installing ROS2 packages and colcon build system with mixin
# changing the middleware (CycloneDDS recommended for MoveIt2)
RUN apt install -y --no-install-recommends \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    ros-humble-desktop \
    ros-humble-rmw-cyclonedds-cpp \
    ros-humble-gazebo-* \
    ros-humble-ros-gz \
    ros-humble-ign-ros2-control \
    ros-humble-ign-ros2-control-demos \
    ros-humble-warehouse-* \
    ros-humble-ros-testing \
    ros-humble-moveit \
    ros-humble-moveit-visual-tools \
    ros-dev-tools \
    gazebo \
    && echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc

RUN /bin/bash -c "colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && colcon mixin update default"

RUN mkdir -p /root/ros2_ws/src
WORKDIR /root/ros2_ws
RUN	/bin/bash -c "source /opt/ros/humble/setup.bash && colcon build"
RUN	echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc && \
    echo "source /root/ros2_ws/install/setup.bash" >> ~/.bashrc && \
    echo "export ROS_PACKAGE_PATH=\${ROS_PACKAGE_PATH}:/root/ros2_ws" >> ~/.bashrc && \
    echo "export ROS_WORKSPACE=/root/ros2_ws" >> ~/.bashrc && \
    echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc && \
    echo "export _colcon_cd_root=/opt/ros/humble/" >> ~/.bashrc

# building ros2 packages
WORKDIR /root/ros2_ws/src
RUN git clone https://github.com/ros-simulation/gazebo_ros2_control.git -b humble --recursive && \
    cd gazebo_ros2_control && \
    git reset --hard b49ed0b
RUN git clone https://github.com/ros-planning/moveit_msgs.git -b humble --recursive && \
    cd moveit_msgs && \
    git reset --hard 99e6898
RUN git clone https://github.com/ros-planning/moveit_resources.git -b humble --recursive && \
    cd moveit_resources && \
    git reset --hard 45ea355
RUN git clone https://github.com/moveit/moveit2.git -b humble --recursive && \
    cd moveit2 && \
    git reset --hard 7ffdfd3
COPY ./ros2_ws/src/moveit_configs_utils/launches.py /root/ros2_ws/src/moveit2/moveit_configs_utils/moveit_configs_utils/
RUN /bin/bash -c "touch /root/ros2_ws/src/moveit2/COLCON_IGNORE"
RUN /bin/bash -c "touch /root/ros2_ws/src/moveit2/moveit_ros/robot_interaction/COLCON_IGNORE"
RUN /bin/bash -c "touch /root/ros2_ws/src/moveit2/moveit_ros/hybrid_planning/COLCON_IGNORE"
RUN git clone https://github.com/ros-planning/moveit_task_constructor.git -b humble --recursive && \
    cd moveit_task_constructor && \
    git reset --hard 7566349
RUN git clone https://github.com/ros-planning/srdfdom.git -b ros2 --recursive && \
    cd srdfdom && \
    git reset --hard c118b35
RUN git clone https://github.com/ros-controls/ros2_control.git -b humble --recursive && \
    cd ros2_control && \
    git reset --hard 0af922d
RUN git clone https://github.com/ros-controls/ros2_controllers.git -b humble --recursive && \
    cd ros2_controllers && \
    git reset --hard 3557ed0
RUN git clone https://github.com/takuya-ki/gazebo-pkgs.git -b humble && \
    cd gazebo-pkgs && \
    git reset --hard 233cc8b
RUN git clone https://github.com/roboticsgroup/roboticsgroup_upatras_gazebo_plugins.git -b ros2 && \
    cd roboticsgroup_upatras_gazebo_plugins && \
    git reset --hard 8bf90f5
RUN echo "export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/root/ros2_ws/build/gazebo_grasp_plugin" >> ~/.bashrc
RUN echo "export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/root/ros2_ws/build/roboticsgroup_upatras_gazebo_plugins" >> ~/.bashrc
RUN echo "export PLUGINLIB_EXPORT_CLASS=$PLUGINLIB_EXPORT_CLASS:/root/ros2_ws/install/iiwa_gazebo/lib" >> ~/.bashrc
RUN echo "export IGN_IP=127.0.0.1" >> ~/.bashrc

WORKDIR /root/ros2_ws/
RUN /bin/bash -c "rosdep init && rosdep update && rosdep install -r --from-paths . --ignore-src --rosdistro humble -y"

# to remove warnings on setuptools that appear when building with colcon
RUN pip install setuptools==58.2.0

WORKDIR /root/ros2_ws/
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --executor parallel --parallel-workers $PARALLELWORKERS --symlink-install --mixin release"
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && rm /root/ros2_ws/src/moveit2/COLCON_IGNORE && colcon build --executor sequential --symlink-install --mixin release"
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && rm /root/ros2_ws/src/moveit2/moveit_ros/hybrid_planning/COLCON_IGNORE && colcon build --executor parallel --parallel-workers $PARALLELWORKERS --symlink-install --mixin release"
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && rm /root/ros2_ws/src/moveit2/moveit_ros/robot_interaction/COLCON_IGNORE && colcon build --executor parallel --parallel-workers $PARALLELWORKERS --symlink-install --mixin release"

# lbr_fri_ros2_stack
# https://raw.githubusercontent.com/lbr-stack/lbr_fri_ros2_stack/humble/lbr_fri_ros2_stack/repos-fri-${FRI_CLIENT_VERSION}.yaml
WORKDIR /root/ros2_ws/src
RUN pip install pyoptas casadi pynput
COPY ./yaml/repos-fri-1.15.yaml /tmp/
RUN /bin/bash -c "source /opt/ros/humble/setup.bash" && \
    mkdir -p lbr-stack/src && cd lbr-stack && \
    vcs import src --input /tmp/repos-fri-1.15.yaml && \
    rosdep install --from-paths src -i -r -y
WORKDIR /root/ros2_ws
RUN apt install -y --no-install-recommends ros-humble-kinematics-interface
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --executor parallel --parallel-workers $PARALLELWORKERS --symlink-install --mixin release" && \
    /bin/bash -c "source /root/ros2_ws/install/setup.bash"

# pyfri
WORKDIR /root/
COPY ./ros2_ws/src/pyfri /root/pyfri
RUN cd /root/pyfri && \
    export FRI_CLIENT_VERSION=1.15 && \
    pip install . && \
    pip install "numpy<2.0"

# Generates bash commands
WORKDIR /root/ros2_ws/src/
# visualize a model with rviz
RUN echo "ros2 launch lbr_bringup mock.launch.py model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup rviz.launch.py rviz_cfg_pkg:=lbr_bringup rviz_cfg:=config/mock.rviz" >> ~/.bash_history

# visualize a model with rviz and gui
RUN echo "ros2 launch lbr_bringup mock_gui.launch.py model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup rviz.launch.py rviz_cfg_pkg:=lbr_bringup rviz_cfg:=config/mock_gui.rviz" >> ~/.bash_history

# joint position command controller
RUN echo "cp --force /yaml/lbr_system_config_position_command_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_position_command_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py ctrl:=lbr_joint_position_command_controller model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_cpp joint_sine_overlay --ros-args -r __ns:=/lbr" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_py joint_trajectory_client --ros-args -r __ns:=/lbr" >> ~/.bash_history

# torque command controller
RUN echo "cp --force /yaml/lbr_system_config_torque_command_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_torque_command_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py ctrl:=lbr_torque_command_controller model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_cpp torque_sine_overlay --ros-args -r __ns:=/lbr" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_py torque_sine_overlay --ros-args -r __ns:=/lbr" >> ~/.bash_history

# wrench command controller
RUN echo "cp --force /yaml/lbr_system_config_wrench_command_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_wrench_command_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py ctrl:=lbr_wrench_command_controller model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_cpp wrench_sine_overlay --ros-args -r __ns:=/lbr" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_py wrench_sine_overlay --ros-args -r __ns:=/lbr" >> ~/.bash_history

# admittance controller 
RUN echo "cp --force /yaml/lbr_system_config_admittance_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_admittance_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py ctrl:=lbr_joint_position_command_controller model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_advanced_py admittance_control --ros-args -r __ns:=/lbr --params-file `ros2 pkg prefix lbr_demos_advanced_py`/share/lbr_demos_advanced_py/config/admittance_control.yaml" >> ~/.bash_history

# admittance controller w/ rcm
RUN echo "cp --force /yaml/lbr_system_config_admittance_rcm_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_admittance_rcm_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py ctrl:=lbr_joint_position_command_controller model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_advanced_py admittance_rcm_control --ros-args -r __ns:=/lbr --params-file `ros2 pkg prefix lbr_demos_advanced_py`/share/lbr_demos_advanced_py/config/admittance_rcm_control.yaml" >> ~/.bash_history

# pose controller
RUN echo "cp --force /yaml/lbr_system_config_pose_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_pose_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py ctrl:=lbr_joint_position_command_controller model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_advanced_cpp pose_control --ros-args -r __ns:=/lbr" >> ~/.bash_history
RUN echo "ros2 run lbr_demos_advanced_cpp pose_planning --ros-args -r __ns:=/lbr" >> ~/.bash_history

# moveit via rviz (simulation)
RUN echo "ros2 launch lbr_bringup mock.launch.py model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup move_group.launch.py mode:=mock rviz:=true model:=iiwa14" >> ~/.bash_history

# moveit via rviz (hardware)
RUN echo "cp --force /yaml/lbr_system_config_moveit.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_moveit.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup move_group.launch.py mode:=mock rviz:=true model:=iiwa14" >> ~/.bash_history

# moveit w/ cpp via rviz (simulation) in the world coordinate system
RUN echo "ros2 launch lbr_bringup mock.launch.py moveit:=true model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup move_group.launch.py mode:=mock model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_moveit_cpp hello_moveit_action.launch.py mode:=mock model:=iiwa14" >> ~/.bash_history

# moveit w/ py via rviz (simulation) in the robot coordinate system
RUN echo "ros2 launch lbr_bringup mock.launch.py moveit:=true model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup move_group.launch.py mode:=mock model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_moveit_py hello_moveit_action.launch.py mode:=mock model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_moveit_py hello_moveit_commander.launch.py mode:=mock model:=iiwa14" >> ~/.bash_history

# moveit w/ cpp via rviz (hardware)
RUN echo "cp --force /yaml/lbr_system_config_moveit.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_moveit.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py moveit:=true model:=iiwa14 sim:=true base_frame:=world" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup move_group.launch.py mode:=hardware model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_moveit_cpp hello_moveit_action.launch.py mode:=hardware model:=iiwa14" >> ~/.bash_history

# moveit w/ py via rviz (hardware)
RUN echo "cp --force /yaml/lbr_system_config_moveit.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_moveit.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py moveit:=true model:=iiwa14 sim:=true base_frame:=world" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup move_group.launch.py mode:=hardware model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_moveit_py hello_moveit_action.launch.py mode:=hardware model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_moveit_py hello_moveit_commander.launch.py mode:=hardware model:=iiwa14" >> ~/.bash_history

# hand-guiding with pyfri
# https://lbr-stack.readthedocs.io/en/latest/pyfri/doc/example_applications.html
RUN echo "cd /root/pyfri/examples && python3 hand_guide.py --lbr-ver 14" >> ~/.bash_history
RUN echo "cd /root/pyfri/examples && python3 joint_teleop.py" >> ~/.bash_history
RUN echo "cd /root/pyfri/examples && python3 task_teleop.py --lbr-ver 14" >> ~/.bash_history
RUN echo "cd /root/pyfri/examples && python3 hello_ik.py --lbr-ver 14" >> ~/.bash_history