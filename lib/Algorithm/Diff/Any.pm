# Algorithm::Diff::Any
#  An interface that automagically selects the XS or Pure Perl port of
#  the diff algorithm (Algorithm::Diff or Algorithm::Diff::XS)
#
# $Id: ISAAC.pm 9526 2009-10-04 04:23:46Z FREQUENCY@cpan.org $

package Algorithm::Diff::Any;

use strict;
use warnings;
use Carp ();

use Exporter 'import';
our @EXPORT_OK = qw(
  prepare
  LCS
  LCSidx
  LCS_length
  diff
  sdiff
  compact_diff
  traverse_sequences
  traverse_balanced
);

=head1 NAME

Algorithm::Diff::Any - Perl module to find differences between files

=head1 VERSION

Version 1.000 ($Id: ISAAC.pm 9526 2009-10-04 04:23:46Z FREQUENCY@cpan.org $)

=cut

our $VERSION = '1.000';
$VERSION = eval $VERSION;

our $DRIVER = 'PP';

# Try to load the XS version first
eval {
  require Algorithm::Diff::XS;
  $DRIVER = 'XS';

  # Import external subroutines here
  no strict 'refs';
  for my $func (@EXPORT_OK) {
    *{$func} = \&{'Algorithm::Diff::XS' . $func};
  }
};

# Fall back on the Perl version
if ($@) {
  require Algorithm::Diff;

  # Import external subroutines here
  no strict 'refs';
  for my $func (@EXPORT_OK) {
    *{$func} = \&{'Algorithm::Diff::' . $func};
  }
}

=head1 DESCRIPTION

This is a simple module to select the best available implementation of the
standard C<diff> algorithm, which works by effectively trying to solve the
Longest Common Subsequence (LCS) problem. This algorithm is described in:
I<A Fast Algorithm for Computing Longest Common Subsequences>, CACM, vol.20,
no.5, pp.350-353, May 1977.

However, it is algorithmically rather complicated to solve the LCS problem;
for arbitrary sequences, it is an NP-hard problem. Simply comparing two
strings together of lengths I<n> and I<m> is B<O(n x m)>. Consequently, this
means the algorithm necessarily has some tight loops, which, for a dynamic
language like Perl, can be slow.

In order to speed up processing, a fast (C/XS-based) implementation of the
algorithm's core loop was implemented. It can confer a noticable performance
advantage (benchmarks show a 54x speedup for the C<compact_diff> routine).

=head1 SYNOPSIS

  use Algorithm::Diff::Any;

  my $diff = Algorithm::Diff::Any->new(\@seq1, \@seq2);

For complete usage details, see the Object-Oriented interface description
for the L<Algorithm::Diff> module.

=head1 PURPOSE

The intent of this module is to provide single simple interface to the two
(presumably) compatible implementations of this module, namely,
L<Algorithm::Diff> and L<Algorithm::Diff::XS>.

If, for some reason, you need to determine what version of the module is
actually being included by C<Algorithm::Diff::Any>, then:

  print 'Backend type: ', $Algorithm::Diff::Any::DRIVER, "\n";

In order to force use of one or the other, simply load the appropriate module:

  use Algorithm::Diff::XS;
  my $diff = Algorithm::Diff::XS->new();
  # or
  use Algorithm::Diff;
  my $diff = Algorithm::Diff->new();

=head1 COMPATIBILITY

This module was tested under Perl 5.10.1, using Debian Linux. However, because
it's Pure Perl and doesn't do anything too obscure, it should be compatible
with any version of Perl that supports its prerequisite modules.

If you encounter any problems on a different version or architecture, please
contact the maintainer.

=head1 METHODS

=head2 Algorithm::Diff::Any->new( \@seq1, \@seq2, [ \%opts ] )

Creates a C<Algorithm::Diff::Any> object, based upon either the optimized
C/XS version of the algorithm, L<Algorithm::Diff::XS>, or falls back to
the Pure Perl implementation, L<Algorithm::Diff>.

Example code:

  my $diff = Algorithm::Diff->new( \@seq1, \@seq2 );

This method will return an appropriate B<Algorithm::Diff::Any> object or
throw an exception on error.

=cut

# Wrappers around the actual methods
sub new {
  my ($class, $seq1, $seq2, $opts) = @_;

  Carp::croak('You must call this as a class method') if ref($class);

  Carp::croak('You must provide two sequences to compare as array refs')
    unless (ref($seq1) eq 'ARRAY' && ref($seq2) eq 'ARRAY');

  my $self = {
  };

  if ($DRIVER eq 'XS') {
    $self->{backend} = Algorithm::Diff::XS->new($seq1, $seq2, $opts);
  }
  else {
    $self->{backend} = Algorithm::Diff->new($seq1, $seq2, $opts);
  }

  bless($self, $class);
  return $self;
}

=head2 $diff->Next( $count )

See L<Algorithm::Diff> for method documentation.

=cut

sub Next {
  shift->{backend}->Next(@_);
}

=head2 $diff->Prev( $count )

See L<Algorithm::Diff> for method documentation.

=cut

sub Prev {
  shift->{backend}->Prev(@_);
}

=head2 $diff->Reset( $pos )

See L<Algorithm::Diff> for method documentation.

=cut

sub Reset {
  shift->{backend}->Reset(@_);
}

=head2 $diff->Copy( $pos, $newBase )

See L<Algorithm::Diff> for method documentation.

=cut

sub Copy {
  shift->{backend}->Copy(@_);
}

=head2 $diff->Base( $newBase )

See L<Algorithm::Diff> for method documentation.

=cut

sub Base {
  shift->{backend}->Base(@_);
}

=head2 $diff->Diff( )

See L<Algorithm::Diff> for method documentation.

=cut

sub Diff {
  shift->{backend}->Diff(@_);
}

=head2 $diff->Same( )

See L<Algorithm::Diff> for method documentation.

=cut

sub Same {
  shift->{backend}->Same(@_);
}

=head2 $diff->Items( $seqNum )

See L<Algorithm::Diff> for method documentation.

=cut

sub Items {
  shift->{backend}->Items(@_);
}

=head2 $diff->Range( $seqNum, $base )

See L<Algorithm::Diff> for method documentation.

=cut

sub Range {
  shift->{backend}->Range(@_);
}

=head2 $diff->Min( $seqNum, $base )

See L<Algorithm::Diff> for method documentation.

=cut

sub Min {
  shift->{backend}->Min(@_);
}

=head2 $diff->Max( $seqNum, $base )

See L<Algorithm::Diff> for method documentation.

=cut

sub Max {
  shift->{backend}->Max(@_);
}

=head2 $diff->Get( @names )

See L<Algorithm::Diff> for method documentation.

=cut

sub Get {
  shift->{backend}->Get(@_);
}

=head1 AUTHOR

Jonathan Yu E<lt>jawnsy@cpan.orgE<gt>

=head2 CONTRIBUTORS

Your name here ;-)

=head1 ACKNOWLEDGEMENTS

=over

=item *

Many thanks go to the primary authors and maintainers of the Pure Perl
implementation of this algorithm, notably:

=over

=item * Mark-Jason Dominus <mjd-perl-diff@plover.com>

=item * Ned Konz <perl@bike-nomad.com>

=item * Tye McQueen <tyemq@cpan.org>

=back

=item *

Thanks to Audrey Tang <cpan@audreyt.org>, author of L<Algorithm::Diff::XS>,
for recognizing the value of Joe Schaefer's <apreq-dev@httpd.apache.org>
work on L<Algorithm::LCS>

=item *

Neither the Pure Perl nor C/XS-based implementations of this module would
have been possible without the work of James W. Hunt (Stanford University)
and Thomas G. Szymanski (Princeton University), authors of the often-cited
paper for computing longest common subsequences.

In their abstract, they claim that a running time of B<O(n log n)> can be
expected, with a worst-case time of B<O(n^2 log n)> for two subsequences of
length I<n>.

=back

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Algorithm::Diff::Any

You can also look for information at:

=over

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Algorithm-Diff-Any>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Algorithm-Diff-Any>

=item * Search CPAN

L<http://search.cpan.org/dist/Algorithm-Diff-Any>

=item * CPAN Request Tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Algorithm-Diff-Any>

=item * CPAN Testing Service (Kwalitee Tests)

L<http://cpants.perl.org/dist/overview/Algorithm-Diff-Any>

=item * CPAN Testers Platform Compatibility Matrix

L<http://www.cpantesters.org/show/Algorithm-Diff-Any.html>

=back

=head1 REPOSITORY

You can access the most recent development version of this module at:

L<http://svn.ali.as/cpan/trunk/Algorithm-Diff-Any>

If you are a CPAN developer and would like to make modifications to the code
base, please contact Adam Kennedy E<lt>adamk@cpan.orgE<gt>, the repository
administrator. I only ask that you contact me first to discuss the changes you
wish to make to the distribution.

=head1 FEEDBACK

Please send relevant comments, rotten tomatoes and suggestions directly to the
maintainer noted above.

If you have a bug report or feature request, please file them on the CPAN
Request Tracker at L<http://rt.cpan.org>. If you are able to submit your bug
report in the form of failing unit tests, you are B<strongly> encouraged to do
so.

=head1 SEE ALSO

L<Algorithm::Diff>, the classic reference implementation for finding the
differences between two chunks of text in Perl. It is based on the algorithm
described in I<A Fast Algorithm for Computing Longest Common Subsequences>,
CACM, vol.20, no.5, pp.350-353, May 1977.

L<Algorithm::Diff::XS>, the C/XS optimized version of Algorithm::Diff, which
will be used automatically if available.

=head1 CAVEATS

=head2 KNOWN BUGS

There are no known bugs as of this release.

=head2 LIMITATIONS

=over

=item *

It is not currently known whether L<Algorithm::Diff> (Pure Perl version)
and L<Algorithm::Diff::XS> (C/XS implementation) produce the same output.
The algorithms may not be equivalent (source code-wise) so they may produce
different output under some as-yet-undiscovered conditions.

=item *

Any potential performance gains will be limited by those features implemented
by L<Algorithm::Diff::XS>. As of time of writing, this is limited to the
C<cdiff> subroutine.

=back

=head1 QUALITY ASSURANCE METRICS

=head2 TEST COVERAGE

  ----------------------- ------ ------ ------ ------ ------ ------
  File                     stmt   bran   cond   sub    pod   total
  ----------------------- ------ ------ ------ ------ ------ ------
  Math/Random/ISAAC.pm    100.0  100.0  n/a    100.0  100.0  100.0
  Math/Random/ISAAC/PP.pm 100.0  100.0  n/a    100.0  100.0  100.0
  Total                   100.0  100.0  n/a    100.0  100.0  100.0

=head1 LICENSE

In a perfect world, I could just say that this package and all of the code
it contains is Public Domain. It's a bit more complicated than that; you'll
have to read the included F<LICENSE> file to get the full details.

=head1 DISCLAIMER OF WARRANTY

The software is provided "AS IS", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or copyright holders be liable for any claim, damages or other
liability, whether in an action of contract, tort or otherwise, arising from,
out of or in connection with the software or the use or other dealings in
the software.

=cut

1;
