#!/bin/bash -e

set -o pipefail

BAZEL_VERSION=tags/0.2.2
TENSORFLOW_VERSION=v0.9.0rc0

# set up a big tmp space and a permanent tensorflow space
sudo mkdir -p -m 1777 /mnt/tmp /tensorflow

# install global deps
sudo apt-get update
sudo apt-get install -y build-essential git swig zip zlib1g-dev npm nodejs-legacy curl

# install bazel deps
sudo apt-get install -y software-properties-common  # for add-apt-repository
sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install -y openjdk-8-jdk
sudo update-alternatives --config java
sudo update-alternatives --config javac
sudo useradd -m -p sa5bQ0zRFAdX2 cortex

# install bazel
#pushd /mnt/tmp
#git clone https://github.com/bazelbuild/bazel.git
#pushd bazel
#git checkout $BAZEL_VERSION
#./compile.sh
#sudo cp output/bazel /usr/bin
#popd
#popd

# install anaconda python 3.5
pushd /mnt/tmp
curl -o Anaconda3-4.0.0-Linux-x86_64.sh -L http://repo.continuum.io/archive/Anaconda3-4.0.0-Linux-x86_64.sh
echo "36a558a1109868661a5735f5f32607643f6dc05cf581fefb1c10fb8abbe22f39 Anaconda3-4.0.0-Linux-x86_64.sh" | sha256sum -c -
sudo bash -c 'bash Anaconda3-4.0.0-Linux-x86_64.sh -b -f -p /usr/local'
sudo /usr/local/bin/conda install -y anaconda python=3.4
sudo /usr/local/bin/conda install -y pip
popd

# install tensorflow
pushd /tensorflow
#git clone -b $TENSORFLOW_VERSION --recurse-submodules https://github.com/tensorflow/tensorflow .
#bazel build //tensorflow/tools/pip_package:build_pip_package
#bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
#sudo /usr/local/bin/pip install /tmp/tensorflow_pkg/tensorflow-0.8.0-py3-none-any.whl
sudo /usr/local/bin/pip install https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.9.0rc0-cp34-cp34m-linux_x86_64.whl
sudo /usr/local/bin/pip install jupyter notebook jupyterhub keras pandas six cloudpickle numpy scikit-learn xgboost xgbmagic luigi ipyparallel
sudo npm install -g configurable-http-proxy
ipcluster nbextension enable

sudo openssl ecparam -genkey -name prime256v1 -out mykey.key
sudo openssl req -new -key mykey.key -out csr.pem -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=cortex.lmig.com"
sudo openssl req -x509 -days 365 -key mykey.key -in csr.pem -out mycert.pem

#sudo touch /etc/rc.d/rc.local

sudo bash -c 'echo "sudo jupyterhub --port 443 --ssl-key /tensorflow/mykey.key --ssl-cert /tensorflow/mycert.pem" >> /etc/init.d/rc.local'

#chmod +x /tensorflow/startup.sh
#sudo ln -s /tensorflow/startup.sh /etc/rc5.d/S99jupyterhub.sh

#sudo jupyterhub --port 443 --ssl-key /tensorflow/mykey.key --ssl-cert /tensorflow/mycert.pem &

# build retrainer
#bazel build -c opt --copt=-mavx tensorflow/examples/image_retraining:retrain
popd
