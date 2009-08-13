###############################################################
# Wolfram Schneider, Aug 2008
#
# build and update a BBBike/SFBike image archive for MacOS 10.5 Intel
#
# For more information about BBBike, visit http://www.bbbike.de
#
# $Id: Makefile,v 1.126 2009/04/19 20:19:02 wosch Exp $

BBBIKE_ROOT=	BBBike
BBBIKE_VERSION= BBBike-3.17-devel

# see target build-version
BUILD_VERSION=	`${MAKE} -s build-version` 

PERL_TARBALL=	MacOS-10.5-intel-perl-5.10.0.tbz
BBBIKE_DMG=	${BBBIKE_VERSION}-Intel.dmg
OSMBIKE_DATA=	data-osm.tgz

PERL_TARBALL_POWERPC=	MacOS-10.5-powerpc-perl-5.10.0.tbz
BBBIKE_DMG_POWERPC=	${BBBIKE_VERSION}-PowerPC.dmg

BBBIKE_TARBALL= ${BBBIKE_VERSION}.tbz

_BUILD_DIR=		build
BUILD_DIR=		${_BUILD_DIR}/macos-intel
BUILD_DIR_POWERPC=	${_BUILD_DIR}/macos-powerpc
BUILD_DIR_SOLARIS=	${_BUILD_DIR}/solaris
BUILD_DIR_LINUX=	${_BUILD_DIR}/linux
BUILD_DIR_FREEBSD=	${_BUILD_DIR}/freebsd
BUILD_DIR_ALL=		${BUILD_DIR} ${BUILD_DIR_POWERPC} ${BUILD_DIR_SOLARIS} ${BUILD_DIR_LINUX} ${BUILD_DIR_FREEBSD}

DOWNLOAD_DIR=	download
ARCHIVE_HOMEPAGE=	http://wolfram.schneider.org/src/bbbike
SCP_HOME=		wolfram.schneider.org:www/src/bbbike

PERL_VERSION=	5.10.0
PERL_DIST=	perl-${PERL_VERSION}.tar.gz
PERL_RELEASE=	perl-${PERL_VERSION}
PERL_FAKEDIR=	/tmp

BBBIKE_SCRIPT=bin/bbbike
UPDATE_FILES= README.txt ${BBBIKE_SCRIPT}
CPAN_HOME=	${PERL_FAKEDIR}/${PERL_RELEASE}/cpan
B_PATH=		/bin:/usr/bin

MAKE_ARGS=	-j8

zcat=	gzip -dc

CITIES=		\
	Aachen \
	Amsterdam \
	Austin \
	Barcelona \
	Basel \
	Berlin \
	Bielefeld \
	Bonn \
	Boulder \
	BrandenburgHavel \
	Bremen \
	Budapest \
	Cambridge \
	CambridgeMa \
	Chemnitz \
	Chicago \
	Colmar \
	Copenhagen \
	Cottbus \
	Krakau \
	CraterLake \
	Danzig \
	Davis \
	Dresden \
	Duesseldorf \
	Erfurt \
	Erlangen \
	Frankfurt \
	FrankfurtOder \
	Freiburg \
	Goerlitz \
	Goettingen \
	Hamburg \
	Hannover \
	Jena \
	Karlsruhe \
	Koeln \
	Laibach \
	Leipzig \
	London \
	Luebeck \
	Mainz \
	Miami \
	Muenster \
	NewYork \
	PaloAlto \
	Paris \
	Portland \
	Prag \
	Providence \
	Rostock \
	Ruegen \
	SanFrancisco \
	SantaCruz \
	Seattle \
	Stettin \
	Strassburg \
	Toronto \
	Turin \
	Vancouver \
	WarenMueritz \
	Wien \
	Zagreb \
	Zuerich \
        Kaunas \
        Riga \
        Reval \
        SanktPetersburg \
        Helsinki \
        Stockholm \
        Oslo \
        Dublin \
        Sofia \
        Sarajewo \
        Kiew \
        Bruessel \
        Groningen \
        Montreal \
        DenHaag \
        Rotterdam \
        Aarhus \
        Corvallis \
        FortCollins \
        Madison \
        Tuscon \
        SanJose \
        Duisburg \
        Dortmund \
        Darmstadt \
        Mannheim \
        Kassel \
        Lissabon \


all: help

bbbike: bbbike-intel-dmg bbbike-powerpc-dmg
bbbike-intel-dmg bbbike-intel: clean get-tarball update-files get-data-osm extract-data-osm create-bbbike-image
bbbike-powerpc-dmg bbbike-powerpc: clean get-tarball-powerpc update-files-powerpc get-data-osm extract-data-osm-powerpc create-bbbike-image-powerpc

create-bbbike-image:
	@for city in ${CITIES}; do \
		( cd ${BUILD_DIR}/${BBBIKE_ROOT} && cp bbbike $$city ); \
	done
	date > ${BUILD_DIR}/${BBBIKE_ROOT}/.build_date
	cp -f bin/cpan ${BUILD_DIR}/${BBBIKE_ROOT}/.cpan
	echo ${BUILD_VERSION} > ${BUILD_DIR}/${BBBIKE_ROOT}/.build_version
	hdiutil create -srcfolder ${BUILD_DIR} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG}

create-bbbike-image-powerpc:
	@for city in ${CITIES}; do \
		( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT} && cp bbbike $$city ); \
	done
	date > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.build_date
	cp -f bin/cpan ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.cpan
	echo ${BUILD_VERSION} > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.build_version
	hdiutil create -srcfolder ${BUILD_DIR_POWERPC} -volname BBBike -ov  ${DOWNLOAD_DIR}/${BBBIKE_DMG_POWERPC}

create-bbbike-tarball:
	cd tarball && tar cf - .${BBBIKE_VERSION} | bzip2 > ../${DOWNLOAD_DIR}/${BBBIKE_TARBALL}
	rsync -av ${DOWNLOAD_DIR}/${BBBIKE_TARBALL}  ${SCP_HOME}

update-files:
	mkdir -p ${BUILD_DIR}/${BBBIKE_ROOT}
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_TARBALL} | ( cd ${BUILD_DIR}/${BBBIKE_ROOT} && tar xf - )
	#cd ${BUILD_DIR}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && cvs -Q update -dP
	bzcat ${DOWNLOAD_DIR}/${PERL_TARBALL} | ( cd ${BUILD_DIR}/${BBBIKE_ROOT} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR}/${BBBIKE_ROOT}/.doc

update-files-powerpc:
	mkdir -p ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}
	bzcat ${DOWNLOAD_DIR}/${BBBIKE_TARBALL} | ( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT} && tar xf - )
	#cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && cvs -Q update -d
	bzcat ${DOWNLOAD_DIR}/${PERL_TARBALL_POWERPC} | ( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT} && tar xf - )
	cp -f ${UPDATE_FILES} ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}
	cp -rf doc ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.doc
	perl -npe s'/^(\s+)i386/Power\*/; s,only MacOS/Intel,only MacOS/PowerPC,' ${BBBIKE_SCRIPT} > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/bbbike


get-tarball:
	mkdir -p ${DOWNLOAD_DIR}
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

extract-data-osm-tbz:
	${zcat} ${DOWNLOAD_DIR}/${OSMBIKE_DATA} | ( cd ${_BUILD_DIR} && tar xf - )
	cd ${_BUILD_DIR}/data-osm; \
	for i in *; do \
	   if [ -d $$i -a ! -f $$i.tbz ]; then \
		tar cf - $$i | bzip2 > $$i.tbz; \
           fi; \
	done
	bzip2 -t ${_BUILD_DIR}/data-osm/*.tbz

extract-data-osm: extract-data-osm-tbz
	mkdir -p  ${BUILD_DIR}/${BBBIKE_ROOT}/.${BBBIKE_VERSION}/data-osm
	cp -f ${_BUILD_DIR}/data-osm/*.tbz ${BUILD_DIR}/${BBBIKE_ROOT}/.${BBBIKE_VERSION}/data-osm

extract-data-osm-powerpc: extract-data-osm-tbz
	mkdir -p  ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.${BBBIKE_VERSION}/data-osm
	cp -f ${_BUILD_DIR}/data-osm/*.tbz ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.${BBBIKE_VERSION}/data-osm

extract-data-osm-powerpc-old:
	@${zcat} ${DOWNLOAD_DIR}/${OSMBIKE_DATA} | ( cd ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/.${BBBIKE_VERSION} && tar xf - )


scp rsync:
	rsync -av ${DOWNLOAD_DIR}/${BBBIKE_DMG} ${DOWNLOAD_DIR}/${BBBIKE_DMG_POWERPC} ${SCP_HOME}

get-perl:
	if test -f ${DOWNLOAD_DIR}/${PERL_DIST} && gzip -t ${DOWNLOAD_DIR}/${PERL_DIST}; then : ; \
	else \
	  curl -sSf -o ${DOWNLOAD_DIR}/${PERL_DIST} http://www.cpan.org/src/${PERL_DIST}; \
	fi

build-perl-powerpc:
	${MAKE} BUILD_DIR=${BUILD_DIR_POWERPC} build-perl-intel
build-perl-solaris:
	${MAKE} BUILD_DIR=${BUILD_DIR_SOLARIS} build-perl-intel


perl-intel: clean get-tarball update-files get-data-osm extract-data-osm get-perl build-perl-intel build-perllibs-intel

perl-powerpc: clean get-tarball update-files get-data-osm extract-data-osm get-perl build-perl-powerpc build-perllibs-powerpc

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

clean:
	rm -rf -- ${BUILD_DIR_ALL}
	rm -f /tmp/cpan.log
	mkdir -p ${BUILD_DIR_ALL}

dist-clean devel-clean distclean: clean
	if [ -d ${DOWNLOAD_DIR} ]; then \
		 cd ${DOWNLOAD_DIR} && rm -f *.part *.tbz *.tgz *.dmg; \
	fi
	rm -f ${BUILD_DIR}/*.dmg
	rm -rf ${PERL_FAKEDIR}/${PERL_RELEASE}

build-version version:
	@git show | head -1 | perl -npe 's/^commit\s+//'

update: 
	${MAKE} distclean
	cd ../bbbike && ${MAKE} -f Makefile.osm rsync-tgz
	${MAKE} bbbike
	${MAKE} rsync

help:
	@echo "usage: make [ bbbike | bbbike-intel | bbbike-powerpc | rsync ]"
	@echo "            [ help | build-version | clean | dist-clean | update ]"

