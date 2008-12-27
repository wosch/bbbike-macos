###############################################################
# Wolfram Schneider, Aug 2008
#
# build and update a BBBike/SFBike image archive for MacOS 10.5 Intel
#
# For more information about BBBike, visit http://www.bbbike.de
#
# $Id: Makefile,v 1.41 2008/12/27 14:20:54 wosch Exp $

BBBIKE_ROOT=	BBBike
BBBIKE_VERSION= BBBike-3.17-devel

# see target build-version
BUILD_VERSION=	132

PERL_TARBALL=	MacOS-10.5-intel-perl-5.10.0.tbz
BBBIKE_DMG=	${BBBIKE_VERSION}-Intel.dmg
OSMBIKE_DATA=	data-osm.tgz

PERL_TARBALL_POWERPC=	MacOS-10.5-powerpc-perl-5.10.0.tbz
BBBIKE_DMG_POWERPC=	${BBBIKE_VERSION}-PowerPC.dmg
BUILD_DIR_POWERPC=	build-powerpc

BBBIKE_TARBALL= ${BBBIKE_VERSION}.tbz
BBBIKE_WEB_DIR=	/usr/local/www/srand.de/bbbike

BUILD_DIR=	build
DOWNLOAD_DIR=	download
ARCHIVE_HOMEPAGE=	http://wolfram.schneider.org/src/bbbike
SCP_HOME=		wolfram.schneider.org:www/src/bbbike

UPDATE_FILES= README.txt bbbike 
CITIES=		Amsterdam Austin Basel Cambridge Cracow Colmar Copenhagen Erlangen Freiburg Hannover Karlsruhe Laibach New_York Portland San_Francisco Santa_Cruz Toronto Wien Zuerich

all: help

bbbike: bbbike-intel-dmg bbbike-powerpc-dmg
bbbike-intel-dmg bbbike-intel: clean get-tarball update-files get-data-osm extract-data-osm create-bbbike-image
bbbike-powerpc-dmg bbbike-powerpc: clean get-tarball-powerpc update-files-powerpc get-data-osm extract-data-osm-powerpc create-bbbike-image-powerpc

create-bbbike-image:
	@for city in ${CITIES}; do \
		( cd ${BUILD_DIR}/${BBBIKE_ROOT} && cp bbbike $$city ); \
	done
	date > ${BUILD_DIR}/${BBBIKE_ROOT}/.build_date
	echo ${BUILD_VERSION} > ${BUILD_DIR}/${BBBIKE_ROOT}/.build_version
	hdiutil create -srcfolder ${BUILD_DIR} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG}

create-bbbike-image-powerpc:
	@for city in ${CITIES}; do \
		( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT} && cp bbbike $$city ); \
	done
	date > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.build_date
	echo ${BUILD_VERSION} > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.build_version
	hdiutil create -srcfolder ${BUILD_DIR_POWERPC} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG_POWERPC}

create-bbbike-tarball:
	cd tarball && tar cf - .BBBike-3.17-devel | bzip2 > ../${DOWNLOAD_DIR}/${BBBIKE_TARBALL}
	rsync -av ${DOWNLOAD_DIR}/${BBBIKE_TARBALL}  ${SCP_HOME}

update-files:
	mkdir -p ${BUILD_DIR}/${BBBIKE_ROOT}
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_TARBALL} | ( cd ${BUILD_DIR}/${BBBIKE_ROOT} && tar xf - )
	bzcat ${DOWNLOAD_DIR}/${PERL_TARBALL} | ( cd ${BUILD_DIR}/${BBBIKE_ROOT} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR}/${BBBIKE_ROOT}/.doc

update-files-powerpc:
	mkdir -p ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_TARBALL} | ( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT} && tar xf - )
	bzcat ${DOWNLOAD_DIR}/${PERL_TARBALL_POWERPC} | ( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.doc
	perl -npe s'/^(\s+)i386/Power\*/; s,only MacOS/Intel,only MacOS/PowerPC,' bbbike > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/bbbike


get-tarball:
	cd ${DOWNLOAD_DIR}; \
	  test -f ${BBBIKE_TARBALL} || curl -s -S -f -o ${BBBIKE_TARBALL} ${ARCHIVE_HOMEPAGE}/${BBBIKE_TARBALL}; \
	  test -f ${PERL_TARBALL} || curl -s -S -f -o ${PERL_TARBALL} ${ARCHIVE_HOMEPAGE}/${PERL_TARBALL}

get-tarball-powerpc:
	cd ${DOWNLOAD_DIR}; \
	  test -f ${BBBIKE_TARBALL} || curl -s -S -f -o ${BBBIKE_TARBALL} ${ARCHIVE_HOMEPAGE}/${BBBIKE_TARBALL}; \
	  test -f ${PERL_TARBALL_POWERPC} || curl -s -S -f -o ${PERL_TARBALL_POWERPC} ${ARCHIVE_HOMEPAGE}/${PERL_TARBALL_POWERPC}

get-data-osm:
	cd ${DOWNLOAD_DIR}; \
	  test -f ${OSMBIKE_DATA} || curl  -s -S -f -o ${OSMBIKE_DATA} ${ARCHIVE_HOMEPAGE}/${OSMBIKE_DATA}

extract-data-osm:
	@gzcat ${DOWNLOAD_DIR}/${OSMBIKE_DATA} | ( cd ${BUILD_DIR}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && tar xf - )

extract-data-osm-powerpc:
	@gzcat ${DOWNLOAD_DIR}/${OSMBIKE_DATA} | ( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && tar xf - )

create-bbbike-web-symlinks:
	cd ${BBBIKE_WEB_DIR}/cgi && \
	for city in ${CITIES}; do \
		ln -fs world.cgi $$city.cgi; \
		ln -fs world.cgi $$city.en.cgi; \
		ln -fs world.cgi.config $$city.cgi.config; \
	done
	ln -fs `pwd`/misc/index.html ${BBBIKE_WEB_DIR}
	ln -fs `pwd`/misc/world.cgi ${BBBIKE_WEB_DIR}/cgi
	ln -fs `pwd`/misc/world.cgi.config ${BBBIKE_WEB_DIR}/cgi

scp rsync:
	rsync -av ${DOWNLOAD_DIR}/${BBBIKE_DMG} ${DOWNLOAD_DIR}/${BBBIKE_DMG_POWERPC} ${SCP_HOME}


clean:
	rm -rf ${BUILD_DIR} ${BUILD_DIR_POWERPC}
	mkdir ${BUILD_DIR} ${BUILD_DIR_POWERPC}

dist-clean devel-clean distclean: clean
	cd ${DOWNLOAD_DIR} && rm -f *.part *.tbz *.tgz *.dmg
	rm -f ${BUILD_DIR}/*.dmg

build-version:
	cvs -q log | perl -ne 'print if s/head: 1.//' | awk '{ s += $$1 } END { print s + 1}'

help:
	@echo "usage: make [ help | bbbike-intel | bbbike-powerpc | rsync | clean | dist-clean ]"
	@echo "            [ build-version | create-bbbike-web-symlinks ]"

