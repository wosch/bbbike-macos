#!/bin/sh

name="`basename $0 .cgi`"
dirname=`dirname "$0"`

export LANG="C"
export PATH="/bin:/usr/bin:/usr/local/bin:/opt/local/bin"

# English Version
case $name in 
	*.en) 
		name=`basename $name .en`
		;;
esac

tmpdir=`mktemp -d /tmp/bbbike.XXXXXXXXXXXXXXX`

trap 'rm -rf "$tmpdir"; exit 1' 1 2 3 13 15
trap 'rm -rf "$tmpdir"' 0


env TMPDIR=$tmpdir DATA_DIR="data-osm/$name" BBBIKE_DATADIR="data-osm/$name" $dirname/bbbike.cgi

