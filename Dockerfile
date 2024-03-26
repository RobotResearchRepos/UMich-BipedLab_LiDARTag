FROM osrf/ros:melodic-desktop-full

ARG DEBIAN_FRONTEND=noninteractive

SHELL ["/bin/bash", "-c"]

# Tools

RUN apt-get update \
 && apt-get install -y git \
 && rm -rf /var/lib/apt/lists/*

# Binary package dependencies

RUN apt-get update \
 && apt-get install -y libtbb-dev \
 && rm -rf /var/lib/apt/lists/*

# Library source dependencies

RUN git clone https://github.com/stevengj/nlopt \
 && cd nlopt && git checkout 41967f \
 && mkdir build && cd build \
 && cmake .. && make install && cd .. && rm -fr nlopt

# Software package dependencies

RUN  mkdir -p /catkin_ws/src

RUN git clone https://github.com/UMich-BipedLab/LiDARTag_msgs /catkin_ws/src/LiDARTag_msgs

# Code repository
 
RUN  mkdir -p /catkin_ws/src/LiDARTag

COPY . /catkin_ws/src/LiDARTag

RUN . /opt/ros/$ROS_DISTRO/setup.bash \
 && apt-get update \
 && rosdep install -r -y \
     --from-paths /catkin_ws/src \
     --ignore-src \
 && rm -rf /var/lib/apt/lists/*

RUN . /opt/ros/$ROS_DISTRO/setup.bash \
 && cd /catkin_ws \
 && catkin_make -j1
 
# Source workspace
RUN sed --in-place --expression \
      '$isource "/catkin_ws/devel/setup.bash"' \
      /ros_entrypoint.sh
