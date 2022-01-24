# Field Operational Test of Self-Adaptive Systems in a Continuous Configuration Space

This is the repository for our paper (Yong-Jun Shin et al., Field Operational Test of Multi-Objective and Multi-Controller Self-Adaptive Systems in a Continuous Configuration Space: a Case Study on the Autonomous Vehicle (in review)). 

## 1. Scenario Description

- Overview of LEGO-lized multi-objective and multi-controller autonomous vehicle.
<img src="/images/lego_av.png" width="450">

Hardware implementation guide can be found [here](https://github.com/KAIST-SE-Lab/Platooning-LEGOs).  
Software implementation can be found in `vehicles` folder of this repository.

- Autonomous vehicle controllers
<img src="/images/av_controllers.png" width="450">

- Physical implementation of autonomous vehicles and test environment
<img src="/images/phys_impl.png" width="450">

## 2. Field Operational Test Procedures

FOTs were conducted by varying the test configurations per the configuration space, totaling 125 test configurations. The tests were repeated 20 times per configuration.

- Configuration space
<img src="/images/configs.png" width="450">

## 3. Repository Hierarchy 

```
AV-FOT
│   README.md
│
└───analyses
│   │   <analysis>.R
│   │
│   └───images
│       └───3d_plot
│       └───boxplot
│       └───scatterplot
│       └───timeseries
│   
└───data
    │   log_<x>_<y>_<z>_all_<timestamp>.csv
│
└───images
│
└───pre-experiment
│
└───vehicles
    │   ego-vehicle.py
    │   external-vehicle.py

```

## 4. Data Analysis Results

- Autonomous vehicle driving trace visualization 
Config. (x=0.4, y=0.6, z=140) 
<img src="/analyses/images/timeseries/timeseries_0.8_1.2_220_all_2021_12_03_12_28_01_565022.png" width="450">

- Distribution of two autonomous driving goals achievement obtained through repetitive FOTs
<img src="/analyses/images/scatterplot/scatter_three_configuration_01.png" width="450">

- Changes in acehievement of autonomous driving goals affected by configurations (one independent variables)
<img src="/analyses/images/boxplot/boxplot_x_1.5_200_lka.png" width="450">

- Changes in acehievement of autonomous driving goals affected by configurations (three independent variables)
<img src="/analyses/images/3d_plot/lka.png" width="1000">
