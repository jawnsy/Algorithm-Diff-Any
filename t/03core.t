#!/usr/bin/perl -T

# t/03core.t
#  Some core functionality tests
#
# $Id: 02compile.t 8614 2009-08-18 03:19:57Z FREQUENCY@cpan.org $

use strict;
use warnings;

use Test::More tests => 3;
use Test::NoWarnings; # 1 test

use Algorithm::Diff::Any;

# Incorrectly called methods
{
  eval { Algorithm::Diff::Any->new('a', 'b'); };
  ok($@, '->new called with string sequences');

  my $obj = Algorithm::Diff::Any->new(
    ['a', 'b', 'c'],
    ['a', 'b', 'd']
  );
  eval { $obj->new; };
  ok($@, '->new called as an object method');
}
