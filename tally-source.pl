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
use JSON;

my %stats = ();
my $tmpdir = File::Spec->tmpdir();

sub wc {
   my ($f) = @_;
   my $s = `wc -c -l '$f'`;
   if ($s =~ m/^\s*(\d+)\s+(\d+)/) {
      $stats{$f}{'size'} = {
         'lines' => $1+0,
         'bytes' => $2+0,
      };
   }
}

foreach my $f (glob('*.dix *.metadix')) {
   $stats{$f}{'kind'} = 'dix';
   wc($f);
   my $s = `'$Bin/dixcounter.py' '$f' 2>/dev/null`;
   chomp($s);
   if (!$s) {
      `cat '$f' | uconv -f iso-8859-1 -t utf-8 > '$tmpdir/tmp-$$'`;
      $s = `'$Bin/dixcounter.py' '$tmpdir/tmp-$$'`;
   }

   if ($s =~ m/Stems: (\d+)/) {
      $stats{$f}{'stems'} = $1+0;
   }
   if ($s =~ m/Paradigms: (\d+)/) {
      $stats{$f}{'paradigms'} = $1+0;
   }
}

foreach my $f (glob('*.t1x *.t2x *.t3x *.t4x')) {
   $stats{$f}{'kind'} = 'transfer';
   wc($f);
   my $s = `cat '$f' | grep '<rule ' | wc -l`+0;
   $stats{$f}{'rules'} = $s;

   $s = `cat '$f' | grep '<def-macro ' | wc -l`+0;
   $stats{$f}{'macros'} = $s;
}

foreach my $f (glob('*.lexc')) {
   $stats{$f}{'kind'} = 'lexc';
   wc($f);

   $stats{$f}{'stems'} = {
      'all' => 0,
      'vanilla' => 0,
      'mt' => 0,
      };

   my $s = `'$Bin/lexccounter.py' '$f'`;
   if ($s =~ m/Unique entries: (\d+)/) {
      $stats{$f}{'stems'}{'all'} = $1+0;
   }

   $s = `'$Bin/lexccounter.py' -V '$f'`;
   if ($s =~ m/Unique entries: (\d+)/) {
      $stats{$f}{'stems'}{'vanilla'} = $1+0;
   }

   $stats{$f}{'stems'}{'mt'} = $stats{$f}{'stems'}{'all'} - $stats{$f}{'stems'}{'vanilla'};
}

foreach my $f (glob('*.twol')) {
   $stats{$f}{'kind'} = 'twol';
   wc($f);
   my $s = `cat '$f' | egrep '^"' | wc -l`+0;
   $stats{$f}{'rules'} = $s;
}

foreach my $f (glob('*.rlx')) {
   $stats{$f}{'kind'} = 'cg3';
   wc($f);
   my $s = `cg-comp '$f' '$tmpdir/tmp-$$' 2>&1`;
   if ($s =~ m/Sections: (\d+), Rules: (\d+), Sets: (\d+), Tags: (\d+)/) {
      $stats{$f}{'sections'} = $1+0;
      $stats{$f}{'rules'} = $2+0;
      $stats{$f}{'sets'} = $3+0;
      $stats{$f}{'tags'} = $4+0;
   }
   if ($s =~ m/(\d+) rules cannot be skipped/) {
      $stats{$f}{'slow_rules'} = $1+0;
   }
}

if (-e "$tmpdir/tmp-$$") {
   unlink("$tmpdir/tmp-$$");
}

print JSON->new->canonical(1)->utf8(1)->pretty(1)->encode(\%stats);
print "\n";
