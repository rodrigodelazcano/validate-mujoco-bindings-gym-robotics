import argparse
from copy import deepcopy
import gym
from sb3_contrib import TQC
from stable_baselines3 import HerReplayBuffer
import yaml
from stable_baselines3.common.monitor import Monitor
from stable_baselines3.common.vec_env import DummyVecEnv, VecVideoRecorder, VecNormalize
from sb3_contrib.common.wrappers import TimeFeatureWrapper
import wandb
from wandb.integration.sb3 import WandbCallback
 

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, default=1,
        help="seed of the experiment")
    parser.add_argument("--verbose", type=int, default=1,
            help="the verbosity of the logs")
    

    # Algorithm specific arguments
    parser.add_argument("--env-id", type=str, default="FetchPush-v1",
        help="the id of the environment")
    args = parser.parse_args()


    return args

if __name__ == "__main__":
    args = parse_args()

    with open(f"hyperparam/rl-zoo.yml") as f:
        hyperparams_dict = yaml.safe_load(f)
        if args.env_id in list(hyperparams_dict.keys()):
            hyperparams = hyperparams_dict[args.env_id].copy()
        else:
            raise ValueError(f"Hyperparameters not found for {args.env_id}")

    env_config = hyperparams_dict[args.env_id]
    env_config.update({'env_id': args.env_id})

    run = wandb.init(
        project="gym_robotics",
        config=env_config,
        sync_tensorboard=True,  # auto-upload sb3's tensorboard metrics
        monitor_gym=True,  # auto-upload the videos of agents playing the game
        save_code=True,  # optional
        name=args.env_id + "_" + str(args.seed)
    )
    
    def make_env():
        env = gym.make(args.env_id)

        env = Monitor(env)  # record stats such as returns
        env = TimeFeatureWrapper(env)

        return env

    env = DummyVecEnv([make_env])

    normalize_kwargs = {"gamma": hyperparams["gamma"]}
    
    env = VecNormalize(env, **normalize_kwargs)
    # Get the env_wrapper hyperparam

    env = VecVideoRecorder(env, f"videos/{args.env_id}_{args.seed}", record_video_trigger=lambda x: x % 10000 == 0, video_length=200)

    hyperparams["policy_kwargs"] = eval(hyperparams["policy_kwargs"])
    hyperparams["replay_buffer_kwargs"] = eval(hyperparams["replay_buffer_kwargs"])

    n_timesteps = deepcopy(hyperparams["n_timesteps"])
    del hyperparams["n_timesteps"]

    model = TQC(env=env, replay_buffer_class=HerReplayBuffer, verbose=1,  seed=args.seed, device='cuda', tensorboard_log=f"runs/{args.env_id}_{args.seed}_1", **hyperparams) 
    # tensorboard_log=f"runs/{run.id}",
    model.learn(
        total_timesteps=n_timesteps,
        callback=WandbCallback(
            gradient_save_freq=100,
            model_save_freq=10,
            model_save_path=f"models/{args.env_id}",
            verbose=2,
        ),
    )
    run.finish()