###############################################################
# Wolfram Schneider, Aug 2008
#
# build a BBBike/SFBike image archive for MacOS 10.5 Intel
#
# For more information about BBBike, see http://www.bbbike.de

BBBIKE_ROOT=	BBBike
BBBIKE_ARCHIVE=	BBBike-3.16-MacOS-10.5-intel-perl-5.10.0.tbz
SFBIKE_DATA=	data-sfo.tgz
BUILD_DIR=	build
DOWNLOAD_DIR=	download
ARCHIVE_HOME=	http://wolfram.schneider.org/src

UPDATE_FILES=\
	.Build-BBBike-dmg.txt \
	.SFBike.txt \
	README.txt \
	bbbike \
	sfbike

all: help

bbbike-dmg: clean get-tarball update-files create-bbbike-image
sfbike-dmg: clean get-tarball update-files get-data-sfo extract-data-sfo create-sfbike-image

create-bbbike-image:
	  hdiutil create -srcfolder ${BUILD_DIR}/BBBike -volname BBBike -ov  ${BUILD_DIR}/BBBike-3.16-Intel.dmg

create-sfbike-image:
	  hdiutil create -srcfolder ${BUILD_DIR}/BBBike -volname SFBike -ov  ${BUILD_DIR}/SFBike-3.16-Intel.dmg

update-files:
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_ARCHIVE} | ( cd ${BUILD_DIR} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR}/${BBBIKE_ROOT}

get-tarball:
	cd ${DOWNLOAD_DIR}; \
	  if [ ! -f ${BBBIKE_ARCHIVE} ]; then  \
	     curl -o ${BBBIKE_ARCHIVE}.part ${ARCHIVE_HOME}/${BBBIKE_ARCHIVE}; \
	     mv -f ${BBBIKE_ARCHIVE}.part ${BBBIKE_ARCHIVE}; \
	  fi

get-data-sfo:
	cd ${DOWNLOAD_DIR}; \
	  if [ ! -f ${SFBIKE_DATA} ]; then  \
	     curl -o ${SFBIKE_DATA}.part ${ARCHIVE_HOME}/${SFBIKE_DATA}; \
	     mv -f ${SFBIKE_DATA}.part ${SFBIKE_DATA}; \
	  fi

extract-data-sfo:
	@zcat ${DOWNLOAD_DIR}/${SFBIKE_DATA} | ( cd ${BUILD_DIR}/BBBike/.BBBike-3.16 && tar xf - )

clean:
	rm -rf ${BUILD_DIR}/${BBBIKE_ROOT}
	rm -f ${BUILD_DIR}/*.dmg

dist-clean: clean
	cd ${DOWNLOAD_DIR} && rm -f *.part *.tbz *.tgz

help:
	@echo "usage: make [ help | bbbike-dmg | sfbike-dmg | clean | dist-clean ]"
