#!/bin/bash
set -e

# Setup script
export DEBIAN_FRONTEND=noninteractive

# Update package list and upgrade existing packages
apt update && apt upgrade -y

# Install basic build tools
apt install -y \
    git \
    tzdata \
    build-essential \
    cmake \
    qt5-default \
    libvtk6-dev \
    zlib1g-dev \
    libjpeg-dev \
    libwebp-dev \
    libpng-dev \
    libtiff5-dev \
    libopenexr-dev \
    libgdal-dev \
    libdc1394-22-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libtheora-dev \
    libvorbis-dev \
    libxvidcore-dev \
    libx264-dev yasm \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libv4l-dev \
    libxine2-dev \
    libtbb-dev \
    libeigen3-dev \
    flake8 \
    ant default-jdk \
    doxygen \
    unzip \
    wget \
    pkg-config \
    software-properties-common \
    curl \
    gdb \
    valgrind \
    ca-certificates \
    gnupg \
    lsb-release \
    libboost-dev \
    libboost-serialization-dev

# Install C++ compiler and development tools
apt install -y \
    g++ \
    gcc \
    libc6-dev \
    make

# Install GUI and display dependencies
apt install -y \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libglew-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    x11-apps \
    x11-utils \
    x11-xserver-utils \
    xauth \
    mesa-utils

# Install Python and required modules
apt install -y \
    python-dev \
    python-tk \
    pylint \
    python-numpy \
    python3 \
    python3-pip \
    python3-dev \
    python3-tk \
    pylint3 \
    python3-numpy \
    python3-matplotlib \
    libpython3-dev

# Install OpenCV dependencies
apt install -y \
    libopencv-dev \
    libopencv-contrib-dev \
    python3-opencv

# Install Pangolin dependencies
apt install -y \
    libwayland-dev \
    libxkbcommon-dev \
    wayland-protocols \
    libegl1-mesa-dev \
    libc++-dev \
    ninja-build \
    libavutil-dev \
    libavdevice-dev

# Install OpenCV from source (v.4.4.0)
echo "Installing OpenCV from source..."
cd /tmp
wget https://github.com/opencv/opencv/archive/4.4.0.zip
unzip 4.4.0.zip && rm 4.4.0.zip && mv opencv-4.4.0 OpenCV
cd OpenCV && mkdir -p build && cd build
cmake -DWITH_QT=ON -DWITH_OPENGL=ON -DFORCE_VTK=ON -DWITH_TBB=ON -DWITH_GDAL=ON \
      -DWITH_XINE=ON -DENABLE_PRECOMPILED_HEADERS=OFF ..
make -j8
make install
ldconfig

# Install Pangolin from source (v0.8)
echo "Installing Pangolin from source..."
cd /tmp
git clone --recursive -b v0.8 https://github.com/stevenlovegrove/Pangolin.git
cd Pangolin
mkdir -p build && cd build
cmake ..
cmake --build .
make install
ldconfig

# Configuring and building Thirdparty/DBoW2
echo "Configuring and building Thirdparty/DBoW2 ..."
cd /workspace/Thirdparty/DBoW2
rm -rf build && mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j
cd .. && chown -R vscode:vscode build lib

# Configuring and building Thirdparty/g2o
echo "Configuring and building Thirdparty/g2o ..."
cd /workspace/Thirdparty/g2o
rm -rf build && mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j
cd .. && chown -R vscode:vscode build lib config.h

# Configuring and building Thirdparty/Sophus
echo "Configuring and building Thirdparty/Sophus ..."
cd  /workspace/Thirdparty/Sophus
rm -rf build && mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j
cd .. && chown -R vscode:vscode build

# Uncompress vocabulary
echo "Uncompress vocabulary ..."
cd /workspace/Vocabulary
tar -xf ORBvoc.txt.tar.gz

# Create symbolic link for python (some scripts expect 'python' command)
ln -sf /usr/bin/python3 /usr/bin/python

# Set proper ownership
chown -R vscode:vscode /home/vscode

# Setup X11 forwarding for GUI applications
echo "Setting up X11 forwarding..."
if [ ! -z "$DISPLAY" ]; then
    # Create .Xauthority file if it doesn't exist
    sudo -u vscode touch /home/vscode/.Xauthority
    sudo -u vscode xauth generate $DISPLAY . trusted 2>/dev/null || true
    
    # Set permissions for X11
    chmod 755 /tmp/.X11-unix 2>/dev/null || true
fi

# Add useful aliases to bashrc
echo "alias ll='ls -alF'" >> /home/vscode/.bashrc
echo "alias la='ls -A'" >> /home/vscode/.bashrc
echo "alias l='ls -CF'" >> /home/vscode/.bashrc

# Clean up
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/Pangolin

echo "Setup completed successfully!"
