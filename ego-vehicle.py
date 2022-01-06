#!/usr/bin/env pybricks-micropython
from pybricks.hubs import EV3Brick
from pybricks.ev3devices import (Motor, TouchSensor, ColorSensor,
                                 InfraredSensor, UltrasonicSensor, GyroSensor)
from pybricks.parameters import Port, Stop, Direction, Button, Color
from pybricks.tools import wait, StopWatch, DataLog
from pybricks.robotics import DriveBase

# Initialize actuators and sensors
left_motor = Motor(Port.B)
right_motor = Motor(Port.C)
color_sensor = ColorSensor(Port.S3)
distance_sensor = UltrasonicSensor(Port.S4)
robot = DriveBase(left_motor, right_motor, wheel_diameter=55.5, axle_track=118)

# Initialize constants
BLACK = 5
WHITE = 75
COLOR_THRESHOLD = (BLACK + WHITE) / 2
DISTANCE_THRESHOLD = 200

# Speed PID Controller Constants
SPEED_PROPORTIONAL_GAIN = 0.4
SPEED_INTEGRAL_GAIN = 0.1
SPEED_DERIVATIVE_GAIN = 0.5

# Color PID Controller Constants
COLOR_PROPORTIONAL_GAIN = 0.4
COLOR_INTEGRAL_GAIN = 0.1
COLOR_DERIVATIVE_GAIN = 0.5

# Initialize variables
drive_speed = 90
speed_deviation = 0.0
speed_derivative = 0.0
speed_integral = 0.0
speed_last_deviation = 0.0

color_deviation = 0.0
color_derivative = 0.0
color_integral = 0.0
color_last_deviation = 0.0

while True:
    time = watch.time()
    color = color_sensor.reflection()
    distance = distance_sensor.distance()

    # Speed PID Controller
    speed_deviation = distance - DISTANCE_THRESHOLD
    speed_integral = speed_integral + speed_deviation
    speed_derivative = speed_deviation - speed_last_deviation
    drive_speed = (SPEED_PROPORTIONAL_GAIN * speed_deviation) + (SPEED_INTEGRAL_GAIN * speed_integral) + (SPEED_DERIVATIVE_GAIN * speed_derivative)

    # Color PID Controller
    color_deviation = color - COLOR_THRESHOLD

    # if deviation > -10 and deviation < 10:
    #     integral = 0
    # elif deviation * last_deviation < 0:
    #     integral = 0
    # else:
    #     integral = integral + deviation
    color_integral = color_integral + color_deviation
    color_derivative = color_deviation - color_last_deviation
    turn_rate = (COLOR_PROPORTIONAL_GAIN * color_deviation) + (COLOR_INTEGRAL_GAIN * color_integral) + (COLOR_DERIVATIVE_GAIN * color_derivative)

    robot.drive(drive_speed, turn_rate)
    color_last_deviation = color_deviation
    speed_last_deviation = speed_deviation

    end_time = watch.time()
    
    if LOG_DATA:
        data.log(time, color, distance, turn_rate, drive_speed)

    wait_time = 150
    if (end_time-time) < 150:
        wait_time = 150-(end_time-time)
    wait(wait_time)
