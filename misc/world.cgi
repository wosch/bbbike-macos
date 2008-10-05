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

exec env DATA_DIR="data-osm/$name" $dirname/bbbike.cgi

