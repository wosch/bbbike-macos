###############################################################
# Copyright (c) 2008-2010 Wolfram Schneider, http://bbbike.org
#
# build and update a BBBike image for MacOS 10.5 Intel & PowerPC
#
# For more information about BBBike, visit http://www.bbbike.de


BBBIKE_ROOT=	BBBike
BBBIKE_VERSION= BBBike-3.17-devel

# see target build-version
BUILD_VERSION=	`${MAKE} -s build-version` 

PERL_TARBALL=	MacOS-10.5-intel-perl-5.10.0.tbz
BBBIKE_DMG=	${BBBIKE_VERSION}-Intel.dmg
OSMBIKE_DATA=	data-osm.bbbike.tgz

BBBIKE_TARBALL= ${BBBIKE_VERSION}-git.tbz

_BUILD_DIR=		build
_build:=		$(shell mkdir -p ${_BUILD_DIR})
BUILD_DIR:=		$(shell mktemp -d ${_BUILD_DIR}/macos-intel.XXXXXXXXXX)

BUILD_DIR_ALL=		${BUILD_DIR}

DOWNLOAD_DIR=	download
ARCHIVE_HOMEPAGE=	http://wolfram.schneider.org/src/bbbike
SCP_HOME=		wolfram.schneider.org:www/src/bbbike

WITH_GIT_PULL=	YES

PERL_VERSION=	5.10.0
PERL_DIST=	perl-${PERL_VERSION}.tar.gz
PERL_RELEASE=	perl-${PERL_VERSION}
PERL_FAKEDIR=	/tmp

BBBIKE_SCRIPT=bin/bbbike
UPDATE_FILES= README.txt ${BBBIKE_SCRIPT}
CPAN_HOME=	${PERL_FAKEDIR}/${PERL_RELEASE}/cpan
B_PATH=		/bin:/usr/bin

MAX_CPU:=        $(shell ../bbbike/world/bin/ncpu)
MAKE_ARGS=	-j${MAX_CPU}

GZIP:=             $(shell which pigz gzip | head -1)
BZIP2:=            $(shell which pbzip2 bzip2 | head -1)


CITIES= `../bbbike/world/bin/bbbike-db --list | egrep -xv "berlin"`
###############################################################

all: help

bbbike: bbbike-macos
bbbike-macos: download-tarballs fix dmg


###############################################################
#
# target per system archtecture
#
dmg:
	@for city in ${CITIES}; do \
		( cd ${BUILD_DIR}/${BBBIKE_ROOT} && cp bbbike $$city ); \
	done
	date > ${BUILD_DIR}/${BBBIKE_ROOT}/.build_date
	cp -f bin/cpan ${BUILD_DIR}/${BBBIKE_ROOT}/.cpan
	cp -f bin/update-data-osm ${BUILD_DIR}/${BBBIKE_ROOT}/.update-data-osm
	echo ${BUILD_VERSION} > ${BUILD_DIR}/${BBBIKE_ROOT}/.build_version
	hdiutil create -srcfolder ${BUILD_DIR} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG}

###############################################################
#
# correction, configuration for target platform
#

fix:
	mkdir -p ${BUILD_DIR}/${BBBIKE_ROOT}
	${BZIP2} -dc ${DOWNLOAD_DIR}/${BBBIKE_TARBALL} | ( cd ${BUILD_DIR}/${BBBIKE_ROOT} && tar xf - )
	if test -n "${WITH_GIT_PULL}"; then cd ${BUILD_DIR}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && git pull -q && rm -rf .git; fi
	${BZIP2} -dc ${DOWNLOAD_DIR}/${PERL_TARBALL} | ( cd ${BUILD_DIR}/${BBBIKE_ROOT} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR}/${BBBIKE_ROOT}/.doc
	../bbbike/world/bin/bbbike-db --city-by-lang=en > ${BUILD_DIR}/${BBBIKE_ROOT}/.english_cities
	(echo data; ../bbbike/world/bin/bbbike-db --list )> ${BUILD_DIR}/${BBBIKE_ROOT}/.all_cities

###############################################################
#
# download tarballs for perl and bbbike
#
download-tarballs:
	mkdir -p ${DOWNLOAD_DIR}
	cd ${DOWNLOAD_DIR}; \
	  test -f ${BBBIKE_TARBALL} || curl -s -S -f -o ${BBBIKE_TARBALL} ${ARCHIVE_HOMEPAGE}/${BBBIKE_TARBALL}; \
	  test -f ${PERL_TARBALL} || curl -s -S -f -o ${PERL_TARBALL} ${ARCHIVE_HOMEPAGE}/${PERL_TARBALL}

###############################################################
# create a bzip2'd tarball for every city and put it online
create-data-osm-tbz: 
	mkdir -p ${_BUILD_DIR}
	if ! test -d ${_BUILD_DIR}/data-osm; then \
		${GZIP} -dc ../../www/src/bbbike/data-osm.tgz | ( cd ${_BUILD_DIR} && tar xf - ); \
		( cd ${_BUILD_DIR} && ( rm -rf data-osm; mv data-osm.bbbike data-osm ) ); \
		( tbz=`pwd`/bin/tbz; cd ${_BUILD_DIR}/data-osm; ls | xargs -n1 -P${MAX_CPU} $${tbz} ); \
		find ${_BUILD_DIR}/data-osm/*.tbz -print0 | xargs -n1 -0 -P${MAX_CPU} ${BZIP2} -t; \
	fi
	mkdir -p ../../www/src/bbbike/data-osm
	rsync -a ${_BUILD_DIR}/data-osm/*.tbz ../../www/src/bbbike/data-osm

###############################################################
#
# old perl stuff
#

get-perl:
	if test -f ${DOWNLOAD_DIR}/${PERL_DIST} && gzip -t ${DOWNLOAD_DIR}/${PERL_DIST}; then : ; \
	else \
	  curl -sSf -o ${DOWNLOAD_DIR}/${PERL_DIST} http://www.cpan.org/src/${PERL_DIST}; \
	fi

build-perl-powerpc:
	${MAKE} BUILD_DIR=${BUILD_DIR_POWERPC} build-perl-intel

perl-intel: download-tarballs update-files get-data-osm extract-data-osm get-perl build-perl-intel build-perllibs-intel

perl-powerpc: download-tarballs update-files get-data-osm extract-data-osm get-perl build-perl-powerpc build-perllibs-powerpc

build-perl-intel: 
	@test -n ${PERL_RELEASE} && rm -rf /tmp/${PERL_RELEASE}
	@rm -rf ${BUILD_DIR}/${PERL_RELEASE}
	@echo "extract perl dist..."
	${GZIP} -dc ${DOWNLOAD_DIR}/${PERL_DIST} | ( cd ${BUILD_DIR}; tar xf - )
	@echo "configure perl..."
	cd ${BUILD_DIR}/${PERL_RELEASE};  \
		env PATH="${B_PATH}" HOME="${CPAN_HOME}" cc='cc' ccflags='-g -pipe -fno-common -DPERL_DARWIN -no-cpp-precomp -fno-strict-aliasing -Wdeclaration-after-statement -I/usr/include' optimize='-O3' ld='cc -mmacosx-version-min=10.5' ldflags='-L/usr/lib' \
		./Configure -ds -e -Dinc_version_list=none -Dlocincpth="/usr/include" -Dloclibpth="/usr/lib" -Dprefix=${PERL_FAKEDIR}/${PERL_RELEASE} -Duseithreads -Duseshrplib > perl-config.log 2>&1 
	@echo "build perl..."
	cd ${BUILD_DIR}/${PERL_RELEASE}; \
		yes "" | ( env PATH="${B_PATH}" HOME="${CPAN_HOME}" ${MAKE} ${MAKE_ARGS} all && \
				env PATH="${B_PATH}" HOME="${CPAN_HOME}" ${MAKE} ${MAKE_ARGS} install ) > make.log 2>&1

build-perllibs-powerpc:
	${MAKE} BUILD_DIR=${BUILD_DIR_POWERPC} build-perllibs-intel
	
build-perllibs-intel:
	yes "" | env PATH="${B_PATH}" HOME="${CPAN_HOME}" ${PERL_FAKEDIR}/${PERL_RELEASE}/bin/cpan -i CPAN > /tmp/cpan.log 2>&1
	perl -i.bak -npe "s|'make_arg' => q\[\],|'make_arg' => q[${MAKE_ARGS}],|; s|'makepl_arg' => q\[\],|'makepl_arg' => q['XFT=1'],|; " ${PERL_FAKEDIR}/${PERL_RELEASE}/lib/${PERL_VERSION}/CPAN/Config.pm
	yes "" | env PATH="${B_PATH}" HOME="${CPAN_HOME}" ${PERL_FAKEDIR}/${PERL_RELEASE}/bin/cpan -if "YAML" >> /tmp/cpan.log 2>&1
	yes "" | env PATH="${B_PATH}" HOME="${CPAN_HOME}" ${PERL_FAKEDIR}/${PERL_RELEASE}/bin/cpan -if "Tk" >> /tmp/cpan.log 2>&1
	yes "" | env PATH="${B_PATH}" HOME="${CPAN_HOME}" ${PERL_FAKEDIR}/${PERL_RELEASE}/bin/cpan -if "Tk::FireButton" >> /tmp/cpan.log 2>&1
	cp -f /tmp/cpan.log ${BUILD_DIR}/${BBBIKE_ROOT}/.${BBBIKE_VERSION}
	${PERL_FAKEDIR}/${PERL_RELEASE}/bin/perl -MTk -e 'exit 0'

###############################################################
#
# generic 
#

scp rsync:
	rsync -av ${DOWNLOAD_DIR}/${BBBIKE_DMG} ${SCP_HOME}

# currently not in used
clean:
	@true

distclean: clean
	rm -rf ${DOWNLOAD_DIR} ${_BUILD_DIR}
	rm -rf ${PERL_FAKEDIR}/${PERL_RELEASE} /tmp/cpan.log

update: 
	${MAKE} distclean
	#cd ../bbbike && ${MAKE} -f Makefile.osm rsync-tgz
	${MAKE} bbbike
	${MAKE} rsync

build-version version:
	@git show | head -1 | perl -npe 's/^commit\s+//'

help:
	@echo "usage: make [ bbbike | rsync ]"
	@echo "            [ create-data-osm-tbz ]"
	@echo "            [ help | build-version | clean | distclean | update ]"

