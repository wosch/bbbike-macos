#!/bin/sh

name="`basename $0 .cgi`"
dirname=`dirname "$0"`

export LANG=C

# English Version
case $name in 
	*.en) 
		name=`basename $name .en`
		;;
esac

exec env DATA_DIR="data-osm/$name" $dirname/bbbike.cgi

