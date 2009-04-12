###############################################################
# Wolfram Schneider, Aug 2008
#
# build and update a BBBike/SFBike image archive for MacOS 10.5 Intel
#
# For more information about BBBike, visit http://www.bbbike.de
#
# $Id: Makefile,v 1.77 2009/04/12 19:39:38 wosch Exp $

BBBIKE_ROOT=	BBBike
BBBIKE_VERSION= BBBike-3.17-devel

# see target build-version
BUILD_VERSION=	314

PERL_TARBALL=	MacOS-10.5-intel-perl-5.10.0.tbz
BBBIKE_DMG=	${BBBIKE_VERSION}-Intel.dmg
OSMBIKE_DATA=	data-osm.tgz

PERL_TARBALL_POWERPC=	MacOS-10.5-powerpc-perl-5.10.0.tbz
BBBIKE_DMG_POWERPC=	${BBBIKE_VERSION}-PowerPC.dmg
BUILD_DIR_POWERPC=	build-powerpc

BBBIKE_TARBALL= ${BBBIKE_VERSION}.tbz

BUILD_DIR=	build
DOWNLOAD_DIR=	download
ARCHIVE_HOMEPAGE=	http://wolfram.schneider.org/src/bbbike
SCP_HOME=		wolfram.schneider.org:www/src/bbbike

PERL_DIST=	perl-5.10.0.tar.gz
PERL_RELEASE=	perl-5.10.0

BBBIKE_SCRIPl=bin/bbbike
UPDATE_FILES= README.txt ${BBBIKE_SCRIPT}
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
	Cracow \
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
	perl -npe s'/^(\s+)i386/Power\*/; s,only MacOS/Intel,only MacOS/PowerPC,' ${BBBIKE_SCRIPT} > ${BUILD_DIR_POWERPC}/${BBBIKE_ROOT}/bbbike


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


scp rsync:
	rsync -av ${DOWNLOAD_DIR}/${BBBIKE_DMG} ${DOWNLOAD_DIR}/${BBBIKE_DMG_POWERPC} ${SCP_HOME}

get-perl:
	if test -f ${DOWNLOAD_DIR}/${PERL_DIST} && gzip -t ${DOWNLOAD_DIR}/${PERL_DIST}; then : \
	else \
	  curl -sSf -o ${DOWNLOAD_DIR}/${PERL_DIST} http://www.cpan.org/src/${PERL_DIST}; \
	fi

build-perl-intel:
	@test -n ${PERL_RELEASE} && rm -rf /tmp/${PERL_RELEASE}
	@rm -rf ${BUILD_DIR}/${PERL_RELEASE}
	@echo "extract perl dist..."
	@cd ${BUILD_DIR} && tar xfz ../${DOWNLOAD_DIR}/${PERL_DIST}
	@echo "configure perl..."
	@cd ${BUILD_DIR}/${PERL_RELEASE};  \
		env cc='cc' ccflags='-arch i386 -g -pipe -fno-common -DPERL_DARWIN -no-cpp-precomp -fno-strict-aliasing -Wdeclaration-after-statement -I/usr/local/include' optimize='-O3' ld='cc -mmacosx-version-min=10.5' ldflags='-arch i386 -L/usr/local/lib' \
		./Configure -ds -e -Dprefix=/tmp/${PERL_RELEASE} -Duseithreads -Duseshrplib > perl-config.log 2>&1 
	@echo "build perl..."
	@cd ${BUILD_DIR}/${PERL_RELEASE} &&  make all test install > make.log 2>&1

clean:
	rm -rf ${BUILD_DIR} ${BUILD_DIR_POWERPC}
	mkdir ${BUILD_DIR} ${BUILD_DIR_POWERPC}

dist-clean devel-clean distclean: clean
	cd ${DOWNLOAD_DIR} && rm -f *.part *.tbz *.tgz *.dmg
	rm -f ${BUILD_DIR}/*.dmg

kml:
	./bin/bbbike-world-kml Makefile.osm > misc/bbbike-world.kml
		
build-version version:
	cvs -q log | perl -ne 'print if s/head: 1.//' | awk '{ s += $$1 } END { print s + 1}'

update: 
	${MAKE} distclean
	cd ../bbbike && ${MAKE} -f Makefile.osm rsync-tgz
	${MAKE} bbbike
	${MAKE} rsync

help:
	@echo "usage: make [ bbbike | bbbike-intel | bbbike-powerpc | rsync | kml ]"
	@echo "            [ help | build-version | clean | dist-clean | update ]"

