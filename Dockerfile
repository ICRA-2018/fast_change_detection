FROM roslab/roslab:kinetic-nvidia

USER root

RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    libeigen3-dev \
    libboost-all-dev \
    qtbase5-dev \
    libglew-dev \
    libopencv-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/jbehley/glow.git /glow \
 && cd /glow \
 && mkdir -p ${HOME}/catkin_ws/src \
 && cp -R /glow ${HOME}/catkin_ws/src/. \
 && /bin/bash -c "source /opt/ros/kinetic/setup.bash && catkin build" \
 && rm -fr /glow

RUN mkdir -p ${HOME}/catkin_ws/src/fast-change-detection
COPY . ${HOME}/catkin_ws/src/fast-change-detection/.
RUN cd ${HOME}/catkin_ws \
 && mv src/fast-change-detection/README.ipynb .. \
 && apt-get update \
 && /bin/bash -c "source /opt/ros/kinetic/setup.bash && rosdep update && rosdep install --as-root apt:false --from-paths src --ignore-src -r -y" \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && /bin/bash -c "source /opt/ros/kinetic/setup.bash && catkin build"

RUN echo "source ~/catkin_ws/devel/setup.bash" >> ${HOME}/.bashrc

RUN chown -R ${NB_UID} ${HOME}

USER ${NB_USER}
WORKDIR ${HOME}
