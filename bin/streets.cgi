#!/usr/bin/perl

use MyCgiSimple;

# use warnings make the script 20% slower!
#use warnings;
use strict;

$ENV{LANG} = 'C';

my $opensearch_file = 'opensearch.streetnames';
my $opensearch_dir  = '../data-osm';
my $opensearch_dir2  = '../data-opensearch';

my $debug         = 1;
my $match_anyware = 1;

# performance tuning, egrep may be faster than perl regex
my $use_egrep = 1;

sub ascii2unicode {
    my $string = shift;

    return $string if $string !~ /\t/;

    my ( $ascii, $unicode ) = split( /\t/, $string );

    warn "ascii2unicode: $unicode\n" if $debug >= 1;
    return $unicode;
}

sub street_match {
    my $file   = shift;
    my $street = shift;
    my $limit  = shift;

    if ( !-e $file ) {
        warn "$!: $file\n";
        return;
    }

    if ($use_egrep) {
        open( IN, '-|' ) || exec 'egrep', '-s', '-m', '2000', '-i', $street,
          $file;
    }
    else {
        if ( !open( IN, $file ) ) { warn "$!: $file\n"; return; }
    }

    # to slow
    # binmode(\*IN, ":utf8");

    my @data;
    my @data2;
    my $len = length($street);
    while (<IN>) {

        # match from beginning
        if (/^$street/i) {
            chomp;
            push( @data, &ascii2unicode($_) );
        }

        # or for long words anyware, second class matches
        elsif ( $match_anyware && $len >= 2 && /$street/i ) {
            chomp;
            push( @data2, &ascii2unicode($_) ) if scalar(@data2) <= $limit * 90;
        }

        last if scalar(@data) >= $limit * 50;
    }

    close IN;

    return ( \@data, \@data2 );
}

sub streetnames_suggestions_unique {
    my @list = &streetnames_suggestions(@_);

    # return unique list
    my %hash = map { $_ => 1 } @list;
    @list = keys %hash;

    return @list;
}

sub streetnames_suggestions {
    my %args   = @_;
    my $city   = $args{'city'};
    my $street = $args{'street'};
    my $limit  = 16;

    $street =~ s/([()|{}\]\[])/\\$1/;

    my $file =
      $city eq 'bbbike'
      ? "../data/$opensearch_file"
      : "$opensearch_dir/$city/$opensearch_file";

    if (! -f $file && -f "$opensearch_dir2/$city/$opensearch_file") {
	$file = "$opensearch_dir2/$city/$opensearch_file";
    }

    my ( $d, $d2 ) = &street_match( $file, $street, $limit );

    # no prefix match, try again with prefix match only
    if ( scalar(@$d) == 0 && scalar(@$d2) == 0 ) {
        ( $d, $d2 ) = &street_match( $file, "^$street", $limit );
    }

    my @data  = @$d;
    my @data2 = @$d2;

    warn "Len1: ", scalar(@data), " ", join( " ", @data ), "\n" if $debug >= 2;
    warn "Len2: ", scalar(@data2), " ", join( " ", @data2 ), "\n"
      if $debug >= 2;

    # less results
    if ( scalar(@data) + scalar(@data2) < $limit ) {
        return ( @data, @data2 );
    }

    # trim results, exact matches first
    else {

        # match words
        my @d;
        @d = grep { /$street\b/i || /\b$street/ } @data2;    # if $len >= 3;

        my @result = &strip_list( $limit, @data );
        push @result,
          &strip_list(
            $limit / ( scalar(@data) ? 2 : 1 ),
            ( scalar(@d) ? @d : @data2 )
          );
        return @result;
    }
}

sub strip_list {
    my $limit = shift;
    my @list  = @_;

    $limit = int($limit);

    my @d;
    my $step = int( scalar(@list) / $limit + 0.5 );
    $step = 1 if $step < 1;

    warn "step: $step, list: ", scalar(@list), "\n" if $debug >= 2;
    for ( my $i = 0 ; $i <= $#list ; $i++ ) {
        if ( ( $i % $step ) == 0 ) {
            warn "i: $i, step: $step\n" if $debug >= 2;
            push( @d, $list[$i] );
        }
    }
    return @d;
}

# GET /w/api.php?action=opensearch&search=berlin&namespace=0 HTTP/1.1

my $q = new MyCgiSimple;

my $action    = 'opensearch';
my $street    = $q->param('search') || $q->param('q') || 'borsig';
my $city      = $q->param('city') || 'bbbike';
my $namespace = $q->param('namespace') || '0';

binmode( \*STDERR, ":utf8" ) if $debug >= 1;

print $q->header(
    -type    => 'application/json',
    -charset => 'utf8',
    -expires => '+1d'
);

my @suggestion =
  &streetnames_suggestions_unique( 'city' => $city, 'street' => $street );

if ( $namespace == 1 ) {
    print join( "\n", @suggestion ), "\n";
}
else {
    print qq/["$street",[/;
    print qq{"}, join( '","', @suggestion ), qq{"} if scalar(@suggestion) > 0;
    print qq,]],;
}

