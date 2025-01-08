# iiwa_ros2_tutorials

[![support level: community](https://img.shields.io/badge/support%20level-community-lightgray.svg)](http://rosindustrial.org/news/2016/10/7/better-supporting-a-growing-ros-industrial-software-platform)
[![License: BSD](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)
![repo size](https://img.shields.io/github/repo-size/Osaka-University-Harada-Laboratory/iiwa_ros2_tutorials)

- ROS2 package for KUKA LBR iiwa 14 R820 tutorial.
- Docker for simulation and control environments for KUKA LBR iiwa 14 R820.

## Dependencies

### Docker build environments

- [Ubuntu 22.04 PC](https://ubuntu.com/certified/laptops?q=&limit=20&vendor=Dell&vendor=Lenovo&vendor=HP&release=22.04+LTS)
  - Docker 27.3.1
  - Docker Compose 2.29.7

### LBR iiwa 14 R820

- [Ubuntu 22.04 PC](https://ubuntu.com/certified/laptops?q=&limit=20&vendor=Dell&vendor=Lenovo&vendor=HP&release=22.04+LTS)
  - [ROS2 HUmble](https://wiki.ros.org/humble/Installation/Ubuntu)
  - [lbr_fri_ros2_stack](https://github.com/lbr-stack/lbr_fri_ros2_stack/tree/humble?tab=readme-ov-file)
  - [Byobu](https://www.byobu.org/)
- [LBR iiwa](https://www.kuka.com/en-us/products/robotics-systems/industrial-robots/lbr-iiwa) 

## Installation

1. Follow [Docs](https://lbr-stack.readthedocs.io/en/latest/lbr_fri_ros2_stack/lbr_fri_ros2_stack/doc/hardware_setup.html) to setup a package with Sunrise Workbench  
2. Connect an Ethernet cable between the host computer and the Ethernet port of controller  
3. Set the IP as `172.31.1.148` to reach the IP `172.31.1.147` at robot controller side  
4. Build the docker environment as below (if you use the docker, this must be set in docker container)  
    ```bash
    sudo apt install byobu && git clone git@github.com:Osaka-University-Harada-Laboratory/iiwa_ros2_tutorials.git --depth 1 && cd iiwa_ros2_tutorials && COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker compose build --no-cache --parallel  
    ```

## Usage with docker

1. Build and run the docker environment
    - Create and start docker containers in the initially opened terminal
    ```bash
    docker compose up
    ```
2. Enter the docker container built
    ```bash
    xhost + && docker exec -it iiwa_ros2_container bash
    ```
3. Execute the demos
    - You can find how to execute [demos](https://lbr-stack.readthedocs.io/en/latest/lbr_fri_ros2_stack/lbr_demos/doc/lbr_demos.html)

## Author / Contributor

[Takuya Kiyokawa](https://takuya-ki.github.io/)  

We always welcome collaborators!

## License

This software is released under the MIT License, see [LICENSE](./LICENSE).
