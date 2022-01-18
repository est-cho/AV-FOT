#!/usr/bin/env pybricks-micropython
from pybricks.hubs import EV3Brick
from pybricks.ev3devices import (Motor, TouchSensor, ColorSensor,
                                 InfraredSensor, UltrasonicSensor, GyroSensor)
from pybricks.parameters import Port, Stop, Direction, Button, Color
from pybricks.tools import wait, StopWatch, DataLog
from pybricks.robotics import DriveBase
from pybricks.messaging import BluetoothMailboxServer, NumericMailbox

# Initialize actuators and sensors
left_motor = Motor(Port.B)
right_motor = Motor(Port.C)
color_sensor = ColorSensor(Port.S3)
distance_sensor = UltrasonicSensor(Port.S4)
robot = DriveBase(left_motor, right_motor, wheel_diameter=55.5, axle_track=118)

# Initialize constants
BLACK = 3
WHITE = 63
COLOR_THRESHOLD = (BLACK + WHITE) / 2
LOOP_TIME = 50

# Speed Configuration
DRIVE_SPEED = 180   # FOT Z axis

# Color PID Controller Constants
COLOR_PROPORTIONAL_GAIN = 0.4
COLOR_INTEGRAL_GAIN = 0.1
COLOR_DERIVATIVE_GAIN = 0.5

# Initialize variables
color_deviation = 0.0
color_integral = 0.0
color_derivative = 0.0
color_last_deviation = 0.0

# Initialize Bluetooth server
server = BluetoothMailboxServer()
mbox_id = NumericMailbox('ext', server)

print('waiting for clients')
server.wait_for_connection(1)
print('connected!')
for _ in range(10):
    mbox_id.send(1)

watch = StopWatch()
watch.reset()

stop_count = 0

while True:
    time = watch.time()
    color = color_sensor.reflection()
    distance = distance_sensor.distance()
    print(distance)
    if distance < 280:
        stop_count += 1
        if stop_count > 3:
            robot.drive(0, 0)
            exit
    else:
        stop_count = 0
    

    # Color PID Controller
    color_deviation = color - COLOR_THRESHOLD
    color_integral = color_integral + color_deviation
    color_derivative = color_deviation - color_last_deviation
    turn_rate = (COLOR_PROPORTIONAL_GAIN * color_deviation) + (COLOR_INTEGRAL_GAIN * color_integral) + (COLOR_DERIVATIVE_GAIN * color_derivative)

    robot.drive(DRIVE_SPEED, turn_rate)
    color_last_deviation = color_deviation

    end_time = watch.time()

    wait_time = 0
    duration = end_time-time
    if duration < LOOP_TIME:
        wait_time = LOOP_TIME - duration
    wait(wait_time)