# base image
FROM nvidia/opengl:1.2-glvnd-devel-ubuntu22.04

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
ENV __NV_PRIME_RENDER_OFFLOAD 1
ENV __GLX_VENDOR_LIBRARY_NAME nvidia

# setting time zone
RUN apt update && apt install -y --no-install-recommends tzdata
ENV TZ=Asia/Tokyo

RUN apt update -y && apt upgrade -y && apt install -y --no-install-recommends \
    software-properties-common \
    texlive-fonts-recommended \
    texlive-latex-extra \
    iputils-ping net-tools \
    libxkbcommon-x11-0 \
    gnome-screenshot \
    libcanberra-gtk* \
    build-essential \
    libgl1-mesa-dev \
    nvidia-settings \
    nvidia-prime \
    lsb-release \
    libudev-dev \
    imagemagick \
    python3-pip \
    python3-tk \
    mesa-utils \
    net-tools \
    aptitude \
    xorg-dev \
    x11-apps \
    libfuse2 \
    cm-super \
    texlive \
    libxcb* \
    dvipng \
    unzip \
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
    ros-humble-ament-cmake \
    ros-humble-warehouse-* \
    ros-humble-gazebo-* \
    ros-humble-ros-gz* \
    ros-humble-moveit* \
    ros-humble-ros2-control \
    ros-humble-ros2-controllers \
    ros-dev-tools \
    gazebo \
    && echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> ~/.bashrc

RUN /bin/bash -c "colcon mixin add default https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && colcon mixin update default"

RUN mkdir -p /tmp/
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
RUN git clone https://github.com/moveit/moveit2.git -b 2.5.6 --recursive && \
    cd moveit2 && \
    git reset --hard c2b0e3d
COPY ./ros2_ws/src/moveit_configs_utils/launches.py /root/ros2_ws/src/moveit2/moveit_configs_utils/moveit_configs_utils/
RUN git clone https://github.com/ros-planning/moveit_task_constructor.git -b humble --recursive && \
    cd moveit_task_constructor && \
    git reset --hard a4daede
RUN git clone https://github.com/ros-planning/srdfdom.git -b ros2 --recursive && \
    cd srdfdom && \
    git reset --hard c118b35
WORKDIR /root/ros2_ws/
RUN /bin/bash -c "rosdep init && rosdep update && rosdep install -r --from-paths . --ignore-src --rosdistro humble -y"

RUN /bin/bash -c "touch /root/ros2_ws/src/moveit2/COLCON_IGNORE"
RUN /bin/bash -c "touch /root/ros2_ws/src/moveit2/moveit_ros/robot_interaction/COLCON_IGNORE"
RUN /bin/bash -c "touch /root/ros2_ws/src/moveit2/moveit_ros/hybrid_planning/COLCON_IGNORE"
WORKDIR /root/ros2_ws/
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --executor parallel --parallel-workers $PARALLELWORKERS --symlink-install --mixin release"
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && rm /root/ros2_ws/src/moveit2/COLCON_IGNORE && colcon build --executor sequential --symlink-install --mixin release"
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && rm /root/ros2_ws/src/moveit2/moveit_ros/hybrid_planning/COLCON_IGNORE && colcon build --executor parallel --parallel-workers $PARALLELWORKERS --symlink-install --mixin release"
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && rm /root/ros2_ws/src/moveit2/moveit_ros/robot_interaction/COLCON_IGNORE && colcon build --executor parallel --parallel-workers $PARALLELWORKERS --symlink-install --mixin release"

# lbr_fri_ros2_stack
WORKDIR /root/ros2_ws/src
RUN apt install -y --no-install-recommends ros-dev-tools && \
    /bin/bash -c "source /opt/ros/humble/setup.bash" && \
    export FRI_CLIENT_VERSION=1.15 && \
    mkdir -p lbr-stack/src && cd lbr-stack && \
    vcs import src --input https://raw.githubusercontent.com/lbr-stack/lbr_fri_ros2_stack/humble/lbr_fri_ros2_stack/repos-fri-${FRI_CLIENT_VERSION}.yaml && \
    rosdep install --from-paths src -i -r -y
WORKDIR /root/ros2_ws
RUN apt install -y --no-install-recommends ros-humble-kinematics-interface
RUN /bin/bash -c "source /opt/ros/humble/setup.bash && colcon build --executor parallel --parallel-workers $PARALLELWORKERS --symlink-install --mixin release" && \
    /bin/bash -c "source /root/ros2_ws/install/setup.bash"
RUN pip install pyoptas casadi

# Generates bash commands
WORKDIR /root/ros2_ws/src/
# visualize a model with rviz
RUN echo "ros2 launch lbr_bringup mock.launch.py model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup rviz.launch.py rviz_cfg_pkg:=lbr_bringup rviz_cfg:=config/mock.rviz" >> ~/.bash_history

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

# twist controller 
RUN echo "cp --force /yaml/lbr_system_config_twist_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_system_config.yaml" >> ~/.bash_history
RUN echo "cp --force /yaml/lbr_controllers_twist_controller.yaml /root/ros2_ws/src/lbr-stack/src/lbr_fri_ros2_stack/lbr_description/ros2_control/lbr_controllers.yaml" >> ~/.bash_history
RUN echo "ros2 launch lbr_bringup hardware.launch.py ctrl:=twist_controller model:=iiwa14" >> ~/.bash_history
RUN echo "ros2 topic pub --rate 100 /lbr/command/twist geometry_msgs/msg/Twist "{linear: {x: 0.0, y: 0.0, z: 0.05}, angular: {x: 0.0, y: 0.0, z: 0.0}}"" >> ~/.bash_history

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
