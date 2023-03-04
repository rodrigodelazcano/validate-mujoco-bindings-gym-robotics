Code implementation of the benchmarks from the following [report](https://wandb.ai/rodrigodelazcano/gym_robotics/reports/Benchmark-Gym-Robotics-SB3--VmlldzoyMjc3Mzkw).
This benchmark compares the old version of Gym-Robotics environments that depend on `mujoco_py` and the latest version of the environments 
that use the lates official python bindings from [mujoco](https://mujoco.readthedocs.io/en/latest/python.html).

The benchmark uses an adapted version of TQC + HER from Stable Baselines 3 and the hyperparameters given in [rl-baselines3-zoo](https://github.com/DLR-RM/rl-baselines3-zoo) 

To run the benchmark first intall the dependencies:
```
pip install -r requirements.txt
```

Then to reproduce the examples from the `FetchReach` environment run:
```
OMP_NUM_THREADS=1 xvfb-run -a python main.py \
          --env-id FetchReach-v1 FetchReach-v2 \
          --command "python sb3_tqc_her.py" \
          --num-seeds 5 \
          --workers 10
```
