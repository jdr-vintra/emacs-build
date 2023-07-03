#! /bin/bash

branch="master" # or emacs-27.2 or emacs-28.1 or emacs-28 or emacs-29

if [[ "${branch}" == "master" ]]; then
	pkgname="emacs-30"
else
	pkgname=${branch}
fi


apt-get update
apt-get install  -y git software-properties-common make checkinstall autoconf texinfo

add-apt-repository -y ppa:ubuntu-toolchain-r/ppa 
add-apt-repository -y ppa:ubuntu-toolchain-r/test # looks like gcc-10 is in here now for 18.04
apt-get update

apt-get install -y gcc-10 g++-10 libgccjit0 libgccjit-10-dev libjansson4 libjansson-dev libgtk-3-dev
apt-get install -y libjpeg-dev libxpm-dev libgif-dev libtiff-dev libgnutls28-dev libncurses-dev

update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 10
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10

git clone --depth=1 git://git.sv.gnu.org/emacs.git  --branch=${branch} # or use emacs-28.1 tag
cd emacs || exit

./autogen.sh
./configure \
	--with-cairo \
	--with-gnutls \
	--with-harfbuzz \
	--with-jpeg \
	--with-json \
	--with-mailutils \
	--with-modules \
	--with-native-compilation \
	--with-pgtk \
	--with-png \
	--with-rsvg \
	--with-tiff \
	--with-wide-int \
	--with-x-toolkit=gtk3 \
	--with-xft \
	--with-xml2 \
	--with-xpm \
	--without-compress-install \
	--without-gconf \
	--without-gsettings \
	--without-imagemagick \
	--without-toolkit-scroll-bars \
	--without-xaw3d \
	--without-xwidgets \
	CFLAGS="-O3 -mtune=native -march=native -fomit-frame-pointer" \
	prefix=/usr/local

make -j"$(nproc)" NATIVE_FULL_AOT=1

function build_deb(){
    checkinstall -y -D --install=no \
      --pkgname=${pkgname}-nativecomp \
      --pkgversion=1"$(git rev-parse --short HEAD)" \
      --requires="libjansson-dev,libharfbuzz-dev,libgccjit-10-dev" \
      --pkggroup=emacs \
      --gzman=yes \
        make install-strip
}

if build_deb; then
	cp -v ./*.deb /host
fi
