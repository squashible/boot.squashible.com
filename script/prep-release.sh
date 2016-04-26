#!/bin/bash
# prep release for upload to production container

function error_check()
{

	if [ $? -eq 1 ]
	then
	  echo "Error encountered... failing..."
	  exit 1
	fi

}

# make ipxe directory to store ipxe disks
mkdir -p build/ipxe

# pull down upstream iPXE
git clone --depth 1 https://github.com/ipxe/ipxe.git ipxe_build

# copy iPXE config overrides into source tree
cp ipxe/local/* ipxe_build/src/config/local/

# build iPXE disks
cd ipxe_build/src

# get current iPXE hash
IPXE_HASH=`git log -n 1 --pretty=format:"%H"`

# generate boot.squashible.com iPXE disks
for ipxe_config in `ls ../../ipxe/`
do
  make bin/ipxe.dsk bin/ipxe.iso bin/ipxe.lkrn bin/ipxe.usb bin/ipxe.kpxe bin/undionly.kpxe \
  EMBED=../../ipxe/disks/$ipxe_config
  error_check
  mv bin/ipxe.dsk ../../build/ipxe/$ipxe_config.dsk
  mv bin/ipxe.iso ../../build/ipxe/$ipxe_config.iso
  mv bin/ipxe.lkrn ../../build/ipxe/$ipxe_config.lkrn
  mv bin/ipxe.usb ../../build/ipxe/$ipxe_config.usb
  mv bin/ipxe.kpxe ../../build/ipxe/$ipxe_config.kpxe
  mv bin/undionly.kpxe ../../build/ipxe/$ipxe_config-undionly.kpxe
done

# return to root
cd ../..

# generate header for sha256-checksums file
cd build/
CURRENT_TIME=`date`
cat > boot.squashible.com-sha256-checksums.txt <<EOF
# boot.squashible.com bootloaders generated at $CURRENT_TIME
# iPXE Commit: https://github.com/ipxe/ipxe/commit/$IPXE_HASH
# Travis-CI Job: https://travis-ci.org/squashible/boot.squashible.com/builds/$TRAVIS_BUILD_ID

EOF

# generate sha256sums for iPXE disks
cd ipxe/
for ipxe_disk in `ls .`
do
  sha256sum $ipxe_disk >> ../boot.squashible.com-sha256-checksums.txt
done
cat ../boot.squashible.com-sha256-checksums.txt
mv ../boot.squashible.com-sha256-checksums.txt .
cd ../..

# delete index.html so that we don't overwrite existing content type
rm src/index.html

# copy iPXE src code into build directory
cp -R src/* build/
