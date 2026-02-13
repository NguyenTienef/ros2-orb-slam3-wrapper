# ORB-SLAM3 ROS2 Integration - Complete Setup

## Overview

This setup provides 5 SLAM modes integrated with ROS2:
- ✅ **mono** - Monocular camera with Pangolin viewer
- ✅ **mono-ros** - Monocular camera with ROS2 publishers (NO Pangolin - for Gazebo sync)
- ✅ **rgbd** - RGB-D camera 
- ✅ **stereo** - Stereo camera
- ✅ **stereo-inertial** - Stereo + IMU

## Quick Start

### 1. Terminal 1: Start Gazebo (or any source publishing camera/IMU)
```bash
# Your gazebo or simulation command
gazebo_something_that_publishes_images_and_imu
```

### 2. Terminal 2: Run ORB-SLAM3 ROS2 (monocular without Pangolin viewer)
```bash
cd ~/orbslam3_ws
source ~/.bashrc
./run_slam_ros.sh
```

This will:
- Load ORB vocabulary
- Start monocular tracking
- Subscribe to `/camera/image` and `/imu/data`
- Publish pose to `/slam/pose` (geometry_msgs/PoseStamped)
- Publish velocity to `/slam/velocity` (geometry_msgs/TwistStamped)
- Broadcast TF: `world` → `camera`
- **NO Pangolin window** (won't block Gazebo)

### 3. Terminal 3: Visualize with RViz
```bash
rviz2 -d ~/orbslam3_ws/slam_ros.rviz
```

This loads pre-configured display showing:
- TF tree (world → camera)
- Camera pose
- Velocity vectors
- Grid

## Configuration

### Camera Calibration
Your Gazebo bocbot camera calibration (verify with `ros2 topic echo /bocbot/camera/image/camera_info`):
```yaml
Camera.fx: 381.362          # focal length X (from K[0])
Camera.fy: 381.362          # focal length Y (from K[4])
Camera.cx: 320.5            # principal point X (from K[2])
Camera.cy: 240.5            # principal point Y (from K[5])
Camera.width: 640
Camera.height: 480
```
✓ **Already matches!** Edit `~/orbslam3_ws/config/gazebo_monocular.yaml` only if your camera differs.

### Topic Remapping
`run_slam_ros.sh` automatically remaps topics for **bocbot namespace**:
```bash
--ros-args \
  -r /camera/image:=/bocbot/camera/image        # Gazebo publishes here \
  -r /imu/data:=/bocbot/imu/data               # Gazebo publishes here
```
If using different topics, edit these lines in the script.

## Published Topics

| Topic | Type | Description |
|-------|------|-------------|
| `/slam/pose` | geometry_msgs/PoseStamped | Camera pose (world → camera) |
| `/slam/velocity` | geometry_msgs/TwistStamped | Camera velocity (estimated from pose diff) |
| `/tf` | tf2 | Transform: world → camera |

## Disable/Enable Pangolin Viewer

### Keep Pangolin (mono):
```bash
ros2 run orbslam3 mono ~/Dev/ORB_SLAM3/Vocabulary/ORBvoc.txt ~/orbslam3_ws/config/gazebo_monocular.yaml
```

### Disable Pangolin (mono-ros, better for Gazebo):
```bash
ros2 run orbslam3 mono-ros ~/Dev/ORB_SLAM3/Vocabulary/ORBvoc.txt ~/orbslam3_ws/config/gazebo_monocular.yaml 0
```

## Troubleshooting

### "libDBoW2.so not found"
Already fixed! The `~/.bashrc` has:
```bash
export LD_LIBRARY_PATH=/home/me/Dev/ORB_SLAM3/lib:...
```

### RViz not showing anything
1. Check if SLAM is running: `ros2 topic list | grep slam`
2. Check if `/slam/pose` has data:`ros2 topic echo /slam/pose | head`
3. Set Fixed Frame to `world` in RViz
4. Click "Add Display" → select `/slam/pose`

### Gazebo lags when Pangolin opens
Use `mono-ros` instead of `mono` (Pangolin viewer disabled)

## Files Structure

```
~/orbslam3_ws/
├── src/ORB_SLAM3_ROS2/
│   ├── src/monocular/
│   │   ├── mono.cpp                    # Original with Pangolin
│   │   ├── mono-ros.cpp                # ROS2 version, no Pangolin
│   │   ├── monocular-slam-node.cpp     # Original subscriber
│   │   └── monocular-slam-node-ros.cpp # ROS2 with publishers
│   └── CMakeLists.txt                  # Updated with mono-ros target
├── config/
│   └── gazebo_monocular.yaml           # Camera calibration
├── run_slam_ros.sh                      # Launch script
└── slam_ros.rviz                        # RViz config
```

## Performance Tips

1. **Reduce ORB features** if tracking is slow:
   ```yaml
   ORBextractor.nFeatures: 500  # instead of 1000
   ```

2. **Increase FPS** for smoother tracking:
   ```yaml
   Camera.fps: 60  # or match your camera
   ```

3. **Use ROS2 bag** to test offline:
   ```bash
   ros2 bag play your_rosbag \
     --remap /camera/image:=/your/image/topic \
     --remap /imu/data:=/your/imu/topic
   ```

## Next Steps

- Process IMU data for better velocity estimation
- Add loop closure detection visualization
- Estimate camera angular velocity
- Project map points on RViz
