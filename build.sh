if [ -e /etc/apt/sources.list.d/ubuntu-toolchain-r-ubuntu-test-bionic.list ]
then
	echo "PPA already added"
else
	sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
fi

docker run -v $(pwd):/host ubuntu:18.04 bash /host/emacs.sh
