FROM python:3.8.1-buster

COPY . /app
WORKDIR /app
RUN apt-get update -y && \
    apt-get install -y libgl1-mesa-dev

RUN pip install -r requirements.txt

WORKDIR /
RUN wget https://github.com/opencv/opencv/archive/3.3.0.zip \
&& git clone https://github.com/arthurgeron/picamera \
&& unzip 3.3.0.zip \
&& cd picamera \
&& pip install -r requirements.txt \
&& cd .. \
&& sed -i 's/#if NPY_INTERNAL_BUILD/#ifndef NPY_INTERNAL_BUILD\n#define NPY_INTERNAL_BUILD/g' /usr/local/lib/python3.6/site-packages/numpy/core/include/numpy/npy_common.h \
&& mkdir /opencv-3.3.0/cmake_binary \
&& cd /opencv-3.3.0/cmake_binary \
&& cmake -DBUILD_TIFF=ON \
  -DBUILD_opencv_java=OFF \
  -DWITH_CUDA=OFF \
  -DENABLE_AVX=ON \
  -DWITH_OPENGL=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=ON \
  -DWITH_TBB=ON \
  -DWITH_EIGEN=ON \
  -DWITH_V4L=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=RELEASE \
  -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
  -DPYTHON_EXECUTABLE=$(which python3.6) \
  -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
  -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
&& make install \
&& rm /3.3.0.zip \
&& rm -r /opencv-3.3.0

#ENV FLASK_APP="flaskblog.py"
#ENV LOG_LEVEL="INFO"
WORKDIR /app

CMD ["python", "facedetection.py" ]