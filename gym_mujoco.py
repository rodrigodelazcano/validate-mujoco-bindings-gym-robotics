import gym
import mujoco


env = gym.make('Ant-v2', render_mode="rgb_array")

obs_reset = env.reset()
action = env.action_space.sample()
obs_step, _, _, _= env.step(action)

print('RESET OBS')
print(obs_reset)
print('STEP OOBS')
print(obs_step)
# while True:
#     action = env.action_space.sample()

#     _, _, done, _ = env.step(action)
#     env.render()
#     if done:
#         env.reset()