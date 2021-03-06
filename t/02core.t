#!/usr/bin/perl

# ABSTRACT: Some core functionality tests

use strict;
use warnings;

use Test::More tests => 4;
use Test::NoWarnings; # 1 test

use Algorithm::Diff::Any;

# Incorrectly called methods
{
  eval { Algorithm::Diff::Any->new('a', 'b'); };
  ok($@, '->new called with string sequences');

  eval { Algorithm::Diff::Any->new([ 'a' ], 'b'); };
  ok($@, '->new called with one array, one string sequence');

  my $obj = Algorithm::Diff::Any->new(
    ['a', 'b', 'c'],
    ['a', 'b', 'd']
  );
  eval { $obj->new; };
  ok($@, '->new called as an object method');
}
