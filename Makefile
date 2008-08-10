BBBIKE_ROOT=	BBBike
BBBIKE_ARCHIVE=	BBBike-3.16-MacOS-10.5-intel-perl-5.10.0.tbz
BUILD_DIR=	build
DOWNLOAD_DIR=	download

UPDATE_FILES=\
	.Build-BBBike-dmg.txt \
	.SFBike.txt \
	bbbike \
	sfbike

all: help

update-files:
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_ARCHIVE} | ( cd ${BUILD_DIR} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR}/${BBBIKE_ROOT}

get:
	cd ${DOWNLOAD_DIR}; \
	  if [ ! -f ${BBBIKE_ARCHIVE} ]; then  \
	     curl -o ${BBBIKE_ARCHIVE}.part http://wolfram.schneider.org/src/${BBBIKE_ARCHIVE}; \
	     mv -f ${BBBIKE_ARCHIVE}.part ${BBBIKE_ARCHIVE}; \
	  fi

clean:
	rm -rf build/${BBBIKE_ROOT}

help:
	@echo "usage: make [ help | bbbike-dmg | sfbike-dmg | clean ]"
