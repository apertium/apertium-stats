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

sub file_get_contents {
   my ($fname) = @_;
   local $/ = undef;
   open my $f, '<:encoding(UTF-8)', $fname;
   my $data = <$f>;
   close $f;
   return $data;
}

use JSON;
my $stats = JSON->new->relaxed->decode(file_get_contents($ARGV[0]));

while (my ($kind,$t) = each(%{$stats->{'_total'}})) {
   my @ns = ();
   if ($kind eq 'cg3' || $kind eq 'twol') {
      if ($t->{'rules'}) {
         push(@ns, $t->{'rules'}.' rules');
      }
   }
   if ($kind eq 'lexc') {
      if ($t->{'stems_all'}) {
         push(@ns, $t->{'stems_all'}.' stems');
      }
      if ($t->{'stems_mt'} && $t->{'stems_vanilla'}) {
         $ns[scalar(@ns)-1] .= " ($t->{stems_mt} mt, $t->{stems_vanilla} vanilla)";
      }
   }
   if ($kind =~ m/dix$/) {
      if ($t->{'stems'}) {
         push(@ns, $t->{'stems'}.' stems');
      }
      if ($t->{'paradigms'}) {
         push(@ns, $t->{'paradigms'}.' paradigms');
      }
   }
   if ($kind eq 'lexd') {
      if ($t->{'lexicons'}) {
         push(@ns, $t->{'lexicons'}.' lexicons');
      }
      if ($t->{'lexicon_entries'}) {
         $ns[scalar(@ns)-1] .= " ($t->{lexicon_entries} entries)";
      }
      if ($t->{'patterns'}) {
         push(@ns, $t->{'patterns'}.' patterns');
      }
      if ($t->{'pattern_entries'}) {
         $ns[scalar(@ns)-1] .= " ($t->{pattern_entries} entries)";
      }
   }

   if (scalar(@ns)) {
      my $v = join(', ', @ns);
      print "$kind: $v\n";
      `curl -s -S 'https://img.shields.io/badge/$kind-$v-blue' -o '$kind.svg'`;
   }
}
