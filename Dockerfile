FROM eclipse/stack-base:ubuntu

###################### PYTHON 3.7 ######################

# ensure local python is preferred over distribution python
RUN sudo apt-get purge -y python.* &&   sudo apt-get update &&   sudo apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    bzip2 \
    file \
    g++ \
    gcc \
    imagemagick \
    libbz2-dev \
    libc6-dev \
    libcurl4-openssl-dev libdb-dev libevent-dev libffi-dev libgdbm-dev libgeoip-dev libglib2.0-dev libjpeg-dev \
    libkrb5-dev liblzma-dev libmagickcore-dev libmagickwand-dev libmysqlclient-dev libncurses-dev libpng-dev \
    libpq-dev libreadline-dev libsqlite3-dev libssl-dev libtool libwebp-dev libxml2-dev libxslt-dev libyaml-dev make patch xz-utils zlib1g-dev \
    build-essential \
    cmake \
    git \
    wget \
    unzip \
    yasm \
    pkg-config \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavformat-dev \
    libpq-dev
ENV LANG=C.UTF-8
ENV GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION=3.7.1
ENV PYTHON_PIP_VERSION=18.1
RUN set -ex && sudo curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz && sudo curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc && export GNUPGHOME="$(mktemp -d)" && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" && gpg --batch --verify python.tar.xz.asc python.tar.xz && sudo rm -r "$GNUPGHOME" python.tar.xz.asc && sudo mkdir -p /usr/src/python && sudo tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz && sudo rm python.tar.xz && cd /usr/src/python && sudo ./configure --enable-shared --enable-unicode=ucs4 && sudo make -j$(nproc) && sudo make install && sudo ldconfig && sudo pip3 install --upgrade --ignore-installed pip==$PYTHON_PIP_VERSION && sudo find /usr/local \( -type d -a -name test -o -name tests \) -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) -exec rm -rf '{}' + && sudo rm -rf /usr/src/python
RUN cd /usr/local/bin && sudo ln -s easy_install-3.5 easy_install && sudo ln -s idle3 idle && sudo ln -s pydoc3 pydoc && sudo ln -s python3 python && sudo ln -s python-config3 python-config
RUN sudo pip install --upgrade pip && \
    sudo pip install --no-cache-dir virtualenv && \
    sudo pip install --upgrade setuptools && \
    sudo pip install 'python-language-server[all]'

###################### PYTHON 3.7 ######################

###################### OPENCV 4 ######################

RUN sudo pip install numpy

WORKDIR /
ENV OPENCV_VERSION="4.0.0"
RUN sudo wget https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip \
&& sudo unzip ${OPENCV_VERSION}.zip \
&& sudo mkdir -p /opencv-${OPENCV_VERSION}/cmake_binary \
&& cd /opencv-${OPENCV_VERSION}/cmake_binary \
&& sudo cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3.7 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.7) \
  -DPYTHON_INCLUDE_DIR=$(python3.7 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.7 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") \
  .. \
&& sudo make install \
&& sudo rm /${OPENCV_VERSION}.zip \
&& sudo rm -r /opencv-${OPENCV_VERSION}

###################### OPENCV 4 ######################

EXPOSE 8080
