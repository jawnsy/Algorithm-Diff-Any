#!/usr/bin/perl -T

# t/02compile.t
#  Check that the module can be compiled and loaded properly.
#
# $Id$

use strict;
use warnings;

use Test::More tests => 3;
use Test::NoWarnings; # 1 test

# Check that we can load the module
BEGIN {
  use_ok('Algorithm::Diff');
  use_ok('Algorithm::Diff::Any');
}
