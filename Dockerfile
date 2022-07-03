FROM pytorch/pytorch:1.12.0-cuda11.3-cudnn8-runtime

COPY . /root/validate-mujoco-bindings-gym-robotics/
WORKDIR /root/

RUN apt-get update
RUN apt-get install sudo
RUN sudo apt-get update -q \
    && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    libgl1-mesa-dev \
    libgl1-mesa-glx \
    libglew-dev \
    patchelf \
    libosmesa6-dev \
    software-properties-common \
    net-tools \
    xpra \
    xserver-xorg-dev \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/* 

RUN apt-get update
RUN sudo apt-get install curl -y
RUN sudo apt-get install wget -y
RUN sudo apt-get install git -y
RUN sudo apt-get install xvfb -y
RUN sudo apt-get install build-essential -y

RUN pip install --upgrade pip

## MuJoCo 2.2.0
RUN mkdir .mujoco/ && cd .mujoco/ \
    && wget https://github.com/deepmind/mujoco/releases/download/2.2.0/mujoco-2.2.0-linux-aarch64.tar.gz \
    && tar -xf mujoco-2.2.0-linux-aarch64.tar.gz \
    && rm mujoco-2.2.0-linux-aarch64.tar.gz 

## MuJoCo 210
RUN cd .mujoco/ \
    && wget https://github.com/deepmind/mujoco/releases/download/2.1.0/mujoco210-linux-x86_64.tar.gz \
    && tar -xf mujoco210-linux-x86_64.tar.gz\
    && rm mujoco210-linux-x86_64.tar.gz
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/root/.mujoco/mujoco210/bin

## Stable Baselines 3
RUN git clone https://github.com/rodrigodelazcano/stable-baselines3-contrib.git \
    && cd stable-baselines3-contrib/ \
    && git checkout feat/new-gym-version \
    && pip install -e .

## Stable Baselines Contrib 3
RUN git clone https://github.com/rodrigodelazcano/stable-baselines3.git \
    && cd stable-baselines3/ \ 
    && git checkout fix_tests \
    && pip install -e .

## Gym 
RUN git clone https://github.com/pseudo-rnd-thoughts/gym.git \
    && cd gym/ \
    && git checkout fixed-env-checker \
    && pip install -e .["all"]

## Gym Robotics
RUN git clone https://github.com/rodrigodelazcano/Gym-Robotics.git \
    && cd Gym-Robotics \
    && git checkout mujoco-bindings \
    && pip install -e .

RUN pip install wandb
RUN pip install tensorboard
RUN python -c "import mujoco_py"
