all: perltidy

ALL=	bbbike-world-kml \
	berlin-coords-data \
	new-city \
	opensearch-suggestion \
	strasse-str \
	livesearch.cgi \
	streetnames-gps \
	extract-streetnames \


perltidy:
	perltidy -b ${ALL}

clean:
	rm -f *.bak *.tdy
