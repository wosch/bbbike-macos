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

PERL_TARBALL_POWERPC=	MacOS-10.5-powerpc-perl-5.10.0.tbz
BBBIKE_DMG_POWERPC=	${BBBIKE_VERSION}-PowerPC.dmg
BBBIKE_DMG_BERLIN=	${BBBIKE_VERSION}-Intel-Berlin.dmg
BBBIKE_DMG_POWERPC_BERLIN=	${BBBIKE_VERSION}-PowerPC-Berlin.dmg

BBBIKE_TARBALL= ${BBBIKE_VERSION}-git.tbz

_BUILD_DIR=		build
_build:=		$(shell mkdir -p ${_BUILD_DIR})
BUILD_DIR:=		$(shell mktemp -d ${_BUILD_DIR}/macos-intel.XXXXXXXXXX)
BUILD_DIR_POWERPC:=	$(shell mktemp -d ${_BUILD_DIR}/macos-powerpc.XXXXXXXXXX)
BUILD_DIR_BERLIN:=	$(shell mktemp -d ${_BUILD_DIR}/macos-intel-berlin.XXXXXXXXXX)
BUILD_DIR_POWERPC_BERLIN:=$(shell mktemp -d ${_BUILD_DIR}/macos-powerpc-berlin.XXXXXXXXXX)

BUILD_DIR_ALL=		${BUILD_DIR} ${BUILD_DIR_POWERPC} ${BUILD_DIR_BERLIN}

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

zcat=	gzip -dc
bzip2=	pbzip2

CITIES= `../bbbike/world/bin/bbbike-db --city-by-lang=any`
###############################################################

all: help

bbbike: bbbike-intel-dmg bbbike-powerpc-dmg bbbike-intel-berlin bbbike-powerpc-berlin

bbbike-intel-dmg bbbike-intel: download-tarballs fix extract-data-osm dmg
bbbike-powerpc-dmg bbbike-powerpc: download-tarballs-powerpc fix-powerpc extract-data-osm-powerpc dmg-powerpc

bbbike-intel-berlin: download-tarballs fix-berlin dmg-berlin
bbbike-powerpc-berlin: download-tarballs fix-powerpc-berlin dmg-powerpc-berlin


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
	echo ${BUILD_VERSION} > ${BUILD_DIR}/${BBBIKE_ROOT}/.build_version
	hdiutil create -srcfolder ${BUILD_DIR} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG}

dmg-powerpc:
	@for city in ${CITIES}; do \
		( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT} && cp bbbike $$city ); \
	done
	date > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.build_date
	cp -f bin/cpan ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.cpan
	echo ${BUILD_VERSION} > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.build_version
	hdiutil create -srcfolder ${BUILD_DIR_POWERPC} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG_POWERPC}

dmg-berlin:
	date > ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT}/.build_date
	cp -f bin/cpan ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT}/.cpan
	echo ${BUILD_VERSION} > ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT}/.build_version
	hdiutil create -srcfolder ${BUILD_DIR_BERLIN} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG_BERLIN}

dmg-powerpc-berlin:
	date > ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT}/.build_date
	cp -f bin/cpan ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT}/.cpan
	echo ${BUILD_VERSION} > ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT}/.build_version
	hdiutil create -srcfolder ${BUILD_DIR_POWERPC_BERLIN} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG_POWERPC_BERLIN}


###############################################################
#
# correction, configuration for target platform
#

fix:
	mkdir -p ${BUILD_DIR}/${BBBIKE_ROOT}
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_TARBALL} | ( cd ${BUILD_DIR}/${BBBIKE_ROOT} && tar xf - )
	if test -n "${WITH_GIT_PULL}"; then cd ${BUILD_DIR}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && git pull -q && rm -rf .git; fi
	bzcat ${DOWNLOAD_DIR}/${PERL_TARBALL} | ( cd ${BUILD_DIR}/${BBBIKE_ROOT} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR}/${BBBIKE_ROOT}/.doc
	../bbbike/world/bin/bbbike-db --city-by-lang=en > ${BUILD_DIR}/${BBBIKE_ROOT}/.english_cities

fix-powerpc:
	mkdir -p ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_TARBALL} | ( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT} && tar xf - )
	if test -n "${WITH_GIT_PULL}"; then cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && git pull -q && rm -rf .git; fi
	bzcat ${DOWNLOAD_DIR}/${PERL_TARBALL_POWERPC} | ( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.doc
	perl -npe s'/^(\s+)i386/Power\*/; s,only MacOS/Intel,only MacOS/PowerPC,' ${BBBIKE_SCRIPT} > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/bbbike
	../bbbike/world/bin/bbbike-db --city-by-lang=en > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.english_cities

fix-berlin:
	mkdir -p ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT}
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_TARBALL} | ( cd ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT} && tar xf - )
	if test -n "${WITH_GIT_PULL}"; then cd ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && git pull -q && rm -rf .git; fi
	bzcat ${DOWNLOAD_DIR}/${PERL_TARBALL} | ( cd ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT}/.doc
	touch ${BUILD_DIR_BERLIN}/${BBBIKE_ROOT}/.english_cities

fix-powerpc-berlin:
	mkdir -p ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT}
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_TARBALL} | ( cd ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT} && tar xf - )
	if test -n "${WITH_GIT_PULL}"; then cd ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && git pull -q && rm -rf .git; fi 
	bzcat ${DOWNLOAD_DIR}/${PERL_TARBALL_POWERPC} | ( cd ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT}/.doc
	perl -npe s'/^(\s+)i386/Power\*/; s,only MacOS/Intel,only MacOS/PowerPC,' ${BBBIKE_SCRIPT} > ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT}/bbbike
	touch ${BUILD_DIR_POWERPC_BERLIN}/${BBBIKE_ROOT}/.english_cities

###############################################################
#
# download tarballs for perl and bbbike
#
download-tarballs:
	mkdir -p ${DOWNLOAD_DIR}
	cd ${DOWNLOAD_DIR}; \
	  test -f ${BBBIKE_TARBALL} || curl -s -S -f -o ${BBBIKE_TARBALL} ${ARCHIVE_HOMEPAGE}/${BBBIKE_TARBALL}; \
	  test -f ${PERL_TARBALL} || curl -s -S -f -o ${PERL_TARBALL} ${ARCHIVE_HOMEPAGE}/${PERL_TARBALL}

download-tarballs-powerpc:
	cd ${DOWNLOAD_DIR}; \
	  test -f ${BBBIKE_TARBALL} || curl -s -S -f -o ${BBBIKE_TARBALL} ${ARCHIVE_HOMEPAGE}/${BBBIKE_TARBALL}; \
	  test -f ${PERL_TARBALL_POWERPC} || curl -s -S -f -o ${PERL_TARBALL_POWERPC} ${ARCHIVE_HOMEPAGE}/${PERL_TARBALL_POWERPC}

###############################################################

get-data-osm:
	cd ${DOWNLOAD_DIR}; \
	  test -f ${OSMBIKE_DATA} || curl  -s -S -f -o ${OSMBIKE_DATA} ${ARCHIVE_HOMEPAGE}/${OSMBIKE_DATA}

extract-data-osm-tbz: get-data-osm
	mkdir -p ${_BUILD_DIR}
	if ! test -d ${_BUILD_DIR}/data-osm; then \
		${zcat} ${DOWNLOAD_DIR}/${OSMBIKE_DATA} | ( cd ${_BUILD_DIR} && tar xf - ); \
		( cd ${_BUILD_DIR} && ( rm -rf data-osm; mv data-osm.bbbike data-osm ) ); \
		( tbz=`pwd`/bin/tbz; cd ${_BUILD_DIR}/data-osm; ls | xargs -n1 -P${MAX_CPU} $${tbz} ); \
		find ${_BUILD_DIR}/data-osm/*.tbz -print0 | xargs -n1 -0 -P${MAX_CPU} ${bzip2} -t; \
	fi

extract-data-osm: extract-data-osm-tbz
	mkdir -p  ${BUILD_DIR}/${BBBIKE_ROOT}/.${BBBIKE_VERSION}/data-osm
	p=`pwd`; cd ${BUILD_DIR}/${BBBIKE_ROOT}/.${BBBIKE_VERSION}/data-osm && ln -f $$p/${_BUILD_DIR}/data-osm/*.tbz .

extract-data-osm-powerpc: extract-data-osm-tbz
	mkdir -p  ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.${BBBIKE_VERSION}/data-osm
	p=`pwd`; cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.${BBBIKE_VERSION}/data-osm && ln -f $$p/${_BUILD_DIR}/data-osm/*.tbz .

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
	${zcat} ${DOWNLOAD_DIR}/${PERL_DIST} | ( cd ${BUILD_DIR}; tar xf - )
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
	rsync -av ${DOWNLOAD_DIR}/${BBBIKE_DMG} ${DOWNLOAD_DIR}/${BBBIKE_DMG_POWERPC} \
		${DOWNLOAD_DIR}/${BBBIKE_DMG_BERLIN} ${DOWNLOAD_DIR}/${BBBIKE_DMG_POWERPC_BERLIN} ${SCP_HOME}

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
	@echo "usage: make [ bbbike | bbbike-intel | bbbike-powerpc | rsync ]"
	@echo "usage: make [ bbbike-powerpc-berlin | bbbike-intel-berlin ]"
	@echo "            [ help | build-version | clean | distclean | update ]"

