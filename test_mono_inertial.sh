#!/bin/bash

export LD_LIBRARY_PATH=/home/me/Dev/ORB_SLAM3/lib:/home/me/Dev/ORB_SLAM3/Thirdparty/DBoW2/lib:/home/me/Dev/ORB_SLAM3/Thirdparty/g2o/lib:$LD_LIBRARY_PATH

source /home/me/orbslam3_ws/install/setup.bash

echo "Starting mono-inertial SLAM..."
echo "Waiting for camera/image on topic: /bocbot/camera/image"
echo "Waiting for IMU on topic: /bocbot/imu/data"
echo ""

ros2 run orbslam3 mono-inertial \
    ~/Dev/ORB_SLAM3/Vocabulary/ORBvoc.txt \
    ~/orbslam3_ws/config/gazebo_mono_inertial.yaml \
    --ros-args \
    -r /camera/image:=/bocbot/camera/image \
    -r /imu:=/bocbot/imu/data
