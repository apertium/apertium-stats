#!/usr/bin/env perl
# -*- mode: cperl; indent-tabs-mode: nil; tab-width: 3; cperl-indent-level: 3; -*-
# Copyright (C) 2021, Apertium Project Management Committee <apertium-pmc@dlsi.ua.es>
# Licensed under the GNU GPL version 2 or later; see https://www.gnu.org/licenses/
use utf8;
use strict;
use warnings;
BEGIN {
   $| = 1;
   binmode(STDIN, ':encoding(UTF-8)');
   binmode(STDOUT, ':encoding(UTF-8)');
}
use open qw( :encoding(UTF-8) :std );
use autodie qw(:all);

use FindBin qw($Bin);
use File::Spec;
use Cwd;
use JSON;

sub file_put_contents {
   my ($fname,$data) = @_;
   open FILE, '>:encoding(UTF-8)', $fname;
   print FILE $data;
   close FILE;
}

if (!$ARGV[0]) {
   die("Must give a folder to output to!\n");
}
if (! -d $ARGV[0]) {
   print `mkdir -pv '$ARGV[0]'`;
}
if (! -d $ARGV[0] || ! -w $ARGV[0]) {
   die("$ARGV[0] is not a writable folder!\n");
}

my $curdir = getcwd();
my $tmpdir = File::Spec->tmpdir();
my $outdir = $ARGV[0];

$ENV{'TZ'} = 'UTC';

chdir($tmpdir);
print `git clone '$curdir' '$tmpdir/tmp-$$'`;

chdir("$tmpdir/tmp-$$");
my $ls = `git log '--date=format-local:\%Y\%m\%d-\%H\%M\%S' --first-parent '--format=format:\%H\%x09\%ad'`;
chomp($ls);
foreach my $l (split(/\n/, $ls)) {
   my ($c,$d) = split(/\t/, $l);
   my $y = substr($d, 0, 4);
   if (! -d "$outdir/$y") {
      print `mkdir -pv '$outdir/$y'`;
   }
   print `git reset --hard '$c'`;
   `$Bin/tally-source.pl > '$outdir/$y/$d-$c.json'`;
}

chdir($tmpdir);
`rm -rf '$tmpdir/tmp-$$'`;
