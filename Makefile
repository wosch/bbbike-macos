###############################################################
# Wolfram Schneider, Aug 2008
#
# build and update a BBBike/SFBike image archive for MacOS 10.5 Intel
#
# For more information about BBBike, see http://www.bbbike.de

BBBIKE_ROOT=	BBBike
BBBIKE_ARCHIVE=	BBBike-3.16-MacOS-10.5-intel-perl-5.10.0.tbz
BBBIKE_DMG=	BBBike-3.16-Intel.dmg
OSMBIKE_DATA=	data-osm.tgz

BUILD_DIR=	build
DOWNLOAD_DIR=	download
ARCHIVE_HOME=	http://wolfram.schneider.org/src

UPDATE_FILES= README.txt bbbike 

all: help

bbbike-dmg bbbike: clean get-tarball update-files get-data-osm extract-data-osm create-bbbike-image

create-bbbike-image:
	@for city in Copenhagen Karlsruhe San_Francisco Basel Amsterdam Erlangen Freiburg Hannover Colmar Zuerich; do \
		( cd ${BUILD_DIR}/${BBBIKE_ROOT} && cp bbbike $$city ); \
	done
	hdiutil create -srcfolder ${BUILD_DIR} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG}

update-files:
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_ARCHIVE} | ( cd ${BUILD_DIR} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR}/${BBBIKE_ROOT}/.doc

get-tarball:
	cd ${DOWNLOAD_DIR}; \
	  if [ ! -f ${BBBIKE_ARCHIVE} ]; then  \
	     curl -s -S -o ${BBBIKE_ARCHIVE}.part ${ARCHIVE_HOME}/${BBBIKE_ARCHIVE}; \
	     mv -f ${BBBIKE_ARCHIVE}.part ${BBBIKE_ARCHIVE}; \
	  fi

get-data-osm:
	cd ${DOWNLOAD_DIR}; \
	  if [ ! -f ${OSMBIKE_DATA} ]; then  \
	     curl  -s -S -o ${OSMBIKE_DATA}.part ${ARCHIVE_HOME}/${OSMBIKE_DATA}; \
	     mv -f ${OSMBIKE_DATA}.part ${OSMBIKE_DATA}; \
	  fi

extract-data-osm:
	@gzcat ${DOWNLOAD_DIR}/${OSMBIKE_DATA} | ( cd ${BUILD_DIR}/BBBike/.BBBike-3.16 && tar xf - )

scp:
	scp ${DOWNLOAD_DIR}/${BBBIKE_DMG} wolfram.schneider.org:www/src

clean:
	rm -rf ${BUILD_DIR}
	mkdir ${BUILD_DIR}

dist-clean devel-clean: clean
	cd ${DOWNLOAD_DIR} && rm -f *.part *.tbz *.tgz *.dmg
	rm -f ${BUILD_DIR}/*.dmg

help:
	@echo "usage: make [ help | bbbike-dmg | scp | clean | dist-clean ]"

