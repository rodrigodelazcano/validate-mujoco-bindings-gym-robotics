FROM python:3.10

RUN apt-get -y update \
    && apt-get install -y xvfb ffmpeg libosmesa6-dev patchelf\
    && mkdir /root/.mujoco \
    && cd /root/.mujoco \
    && wget -qO- 'https://github.com/deepmind/mujoco/releases/download/2.2.1/mujoco-2.2.1-linux-x86_64.tar.gz' | tar -xzvf - \
    && wget -qO- 'https://github.com/deepmind/mujoco/releases/download/2.1.0/mujoco210-linux-x86_64.tar.gz' | tar -xzvf - \
    && pip install wandb mujoco_py torch=="1.11.0" gym=="0.25.0" tensorboard=="2.8.0" mujoco=="2.2.1" imageio=="2.16.1"
    

ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/root/.mujoco/mujoco-2.2.1/bin"
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/root/.mujoco/mujoco210/bin"

RUN python -c "import mujoco_py"

COPY . /usr/local/validate-mujoco-bindings-gym-robotics/
WORKDIR /usr/local/validate-mujoco-bindings-gym-robotics/

RUN git clone https://github.com/rodrigodelazcano/stable-baselines3.git \
    && cd stable-baselines3 \
    && pip install -e .

RUN git clone https://github.com/rodrigodelazcano/stable-baselines3-contrib.git \
    && cd stable-baselines3-contrib \
    && pip install -e .

RUN git clone https://github.com/rodrigodelazcano/Gym-Robotics.git \
    && cd Gym-Robotics \
    && git checkout mujoco-bindings \
    && pip install -e .