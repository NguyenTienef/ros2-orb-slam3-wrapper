#!/bin/bash

export LD_LIBRARY_PATH=/home/me/Dev/ORB_SLAM3/lib:/home/me/Dev/ORB_SLAM3/Thirdparty/DBoW2/lib:/home/me/Dev/ORB_SLAM3/Thirdparty/g2o/lib:$LD_LIBRARY_PATH

source /home/me/orbslam3_ws/install/setup.bash

echo "================================"
echo "Starting ORB-SLAM3 monocular-inertial + ROS2"
echo "================================"
echo ""
echo "Topics published:"
echo "  - /slam/pose (geometry_msgs/PoseStamped)"
echo "  - /slam/velocity (geometry_msgs/TwistStamped)"
echo "  - tf: world -> camera"
echo ""
echo "To visualize in RViz:"
echo "  1. rviz2"
echo "  2. Add TF display"
echo "  3. Add Pose display (/slam/pose)"
echo "  4. Add Vector display (/slam/velocity)"
echo ""
echo "Subscribers (remapped for bocbot)::"
echo "  - /bocbot/camera/image → /camera/image (sensor_msgs/Image)"
echo "  - /bocbot/imu/data → /imu/data (sensor_msgs/Imu)"
echo ""
echo "To disable Pangolin viewer, set 3rd argument to 0:"
echo "  ros2 run orbslam3 mono-ros <vocab> <config> 0"
echo ""
echo "================================"
echo ""

# Run mono-ros without Pangolin viewer
ros2 run orbslam3 mono-ros \
    ~/Dev/ORB_SLAM3/Vocabulary/ORBvoc.txt \
    ~/orbslam3_ws/config/gazebo_monocular.yaml \
    0 \
    --ros-args \
    -r /camera/image:=/bocbot/camera/image \
    -r /imu/data:=/bocbot/imu/data
