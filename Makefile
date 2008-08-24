###############################################################
# Wolfram Schneider, Aug 2008
#
# build and update a BBBike/SFBike image archive for MacOS 10.5 Intel
#
# For more information about BBBike, visit http://www.bbbike.de
#
# $Id: Makefile,v 1.21 2008/08/24 17:06:18 wosch Exp $

BBBIKE_ROOT=	BBBike
BBBIKE_ARCHIVE=	BBBike-3.16-MacOS-10.5-intel-perl-5.10.0.tbz
BBBIKE_DMG=	BBBike-3.16-Intel.dmg
OSMBIKE_DATA=	data-osm.tgz

BBBIKE_POWERPC_DMG=	BBBike-3.16-PowerPC.dmg
BBBIKE_POWERPC_ARCHIVE=	BBBike-3.16-MacOS-10.5-powerpc-perl-5.10.0.tbz
BUILD_POWERPC_DIR=	build-powerpc

BUILD_DIR=	build
DOWNLOAD_DIR=	download
ARCHIVE_HOME=	http://wolfram.schneider.org/src

UPDATE_FILES= README.txt bbbike 
CITIES=		Amsterdam Basel Colmar Copenhagen Erlangen Freiburg Hannover Karlsruhe Laibach San_Francisco Wien Zuerich

all: help

bbbike-dmg bbbike: clean get-tarball update-files get-data-osm extract-data-osm create-bbbike-image
bbbike-powerpc-dmg bbbike-powerpc: clean get-tarball-powerpc update-files-powerpc get-data-osm extract-data-osm-powerpc create-bbbike-image-powerpc

create-bbbike-image:
	@for city in ${CITIES}; do \
		( cd ${BUILD_DIR}/${BBBIKE_ROOT} && cp bbbike $$city ); \
	done
	hdiutil create -srcfolder ${BUILD_DIR} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG}

create-bbbike-image-powerpc:
	@for city in ${CITIES}; do \
		( cd ${BUILD_POWERPC_DIR}/${BBBIKE_ROOT} && cp bbbike $$city ); \
	done
	hdiutil create -srcfolder ${BUILD_POWERPC_DIR} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_POWERPC_DMG}


update-files:
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_ARCHIVE} | ( cd ${BUILD_DIR} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR}/${BBBIKE_ROOT}/.doc

update-files-powerpc:
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_POWERPC_ARCHIVE} | ( cd ${BUILD_POWERPC_DIR} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_POWERPC_DIR}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_POWERPC_DIR}/${BBBIKE_ROOT}/.doc
	perl -npe s'/^(\s+)i386/Power\*/; s,only MacOS/Intel,only MacOS/PowerPC,' bbbike > ${BUILD_POWERPC_DIR}/${BBBIKE_ROOT}/bbbike


get-tarball:
	cd ${DOWNLOAD_DIR}; \
	  test -f ${BBBIKE_ARCHIVE} || curl -s -S -f -o ${BBBIKE_ARCHIVE} ${ARCHIVE_HOME}/${BBBIKE_ARCHIVE}

get-tarball-powerpc:
	cd ${DOWNLOAD_DIR}; \
	  test -f ${BBBIKE_POWERPC_ARCHIVE} || curl -s -S -f -o ${BBBIKE_POWERPC_ARCHIVE} ${ARCHIVE_HOME}/${BBBIKE_POWERPC_ARCHIVE}; 

get-data-osm:
	cd ${DOWNLOAD_DIR}; \
	  test -f ${OSMBIKE_DATA} || curl  -s -S -f -o ${OSMBIKE_DATA} ${ARCHIVE_HOME}/${OSMBIKE_DATA}

extract-data-osm:
	@gzcat ${DOWNLOAD_DIR}/${OSMBIKE_DATA} | ( cd ${BUILD_DIR}/BBBike/.BBBike-3.16 && tar xf - )

extract-data-osm-powerpc:
	@gzcat ${DOWNLOAD_DIR}/${OSMBIKE_DATA} | ( cd ${BUILD_POWERPC_DIR}/BBBike/.BBBike-3.16 && tar xf - )

scp:
	scp ${DOWNLOAD_DIR}/${BBBIKE_DMG} ${DOWNLOAD_DIR}/${BBBIKE_POWERPC_DMG} wolfram.schneider.org:www/src

clean:
	rm -rf ${BUILD_DIR} ${BUILD_POWERPC_DIR}
	mkdir ${BUILD_DIR} ${BUILD_POWERPC_DIR}

dist-clean devel-clean distclean: clean
	cd ${DOWNLOAD_DIR} && rm -f *.part *.tbz *.tgz *.dmg
	rm -f ${BUILD_DIR}/*.dmg

help:
	@echo "usage: make [ help | bbbike-dmg | scp | clean | dist-clean ]"

