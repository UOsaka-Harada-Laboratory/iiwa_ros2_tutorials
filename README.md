# iiwa_ros2_tutorials

[![support level: community](https://img.shields.io/badge/support%20level-community-lightgray.svg)](http://rosindustrial.org/news/2016/10/7/better-supporting-a-growing-ros-industrial-software-platform)
[![License: BSD](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
![repo size](https://img.shields.io/github/repo-size/UOsaka-Harada-Laboratory/iiwa_ros2_tutorials)

- ROS2 package for KUKA LBR iiwa 14 R820 tutorial.
- Docker for simulation and control environments for KUKA LBR iiwa 14 R820.

## Dependencies

### Docker build environments

- [Ubuntu 22.04 PC](https://ubuntu.com/certified/laptops?q=&limit=20&vendor=Dell&vendor=Lenovo&vendor=HP&release=22.04+LTS)
  - Docker 27.4.1
  - Docker Compose 2.32.1

### LBR iiwa 14 R820

- [Ubuntu 22.04 PC](https://ubuntu.com/certified/laptops?q=&limit=20&vendor=Dell&vendor=Lenovo&vendor=HP&release=22.04+LTS)
  - [ROS2 HUmble](https://wiki.ros.org/humble/Installation/Ubuntu)
  - [lbr_fri_ros2_stack](https://github.com/lbr-stack/lbr_fri_ros2_stack/tree/humble?tab=readme-ov-file)
  - [Byobu](https://www.byobu.org/)
- [LBR iiwa](https://www.kuka.com/en-us/products/robotics-systems/industrial-robots/lbr-iiwa) 

## Installation

1. Follow [Docs](https://lbr-stack.readthedocs.io/en/latest/lbr_fri_ros2_stack/lbr_fri_ros2_stack/doc/hardware_setup.html) to setup a package with Sunrise Workbench  
2. If the SmartPAD fails to start properly, update the SmartHMI.exe.PdsFirmwareUpdate.config file located in C:/KRC/SmartHMI/ with [this](/smartpad/SmartHMI.exe.PdsFirmwareUpdate.config)  
3. Connect an Ethernet cable between the host computer and the Ethernet port of controller  
4. Set the IP as `172.31.1.150` to reach the IP `172.31.1.147` (robot controller side)  
5. Build the docker environment as below (if you use the docker, this must be set in docker container)  
    ```bash
    sudo apt install byobu && git clone git@github.com:UOsaka-Harada-Laboratory/iiwa_ros2_tutorials.git --recursive --depth 1 && cd iiwa_ros2_tutorials && COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker compose build --no-cache --parallel  
    ```

## Usage with docker

1. Build and run the docker environment
    - Create and start docker containers in the initially opened terminal
    ```bash
    docker compose up
    ```
2. Confirm the lbr_fri_ros2_stack was installed successfully in another terminal
    ```bash
    ./utils/bringup_lbr_urdf_ctrl.sh
    ```
3. Kill the processes at step 2 and execute the demos with the real robot
    - You can find how to execute [demos](https://lbr-stack.readthedocs.io/en/latest/lbr_fri_ros2_stack/lbr_demos/doc/lbr_demos.html)
    - You can find scripts in iiwa_ros2_tutorials/utils to execute all necessary commands for each demonstration
    ```bash
    ./utils/XXX.sh
    ```

### [./utils/bringup_lbr_urdf_ctrl.sh](./utils/bringup_lbr_urdf_ctrl.sh)

<img src=image/bringup_lbr_urdf_ctrl.png width=500>  

## Author / Contributor

[Takuya Kiyokawa](https://takuya-ki.github.io/)  

We always welcome collaborators!

## License

This software is released under the MIT License, see [LICENSE](./LICENSE).
