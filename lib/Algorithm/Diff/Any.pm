package Algorithm::Diff::Any;
# ABSTRACT: Perl module to find differences between files

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

our $DRIVER = 'PP';

# Try to load the XS version first
eval {
  require Algorithm::Diff::XS;
  $DRIVER = 'XS';

  # Import external subroutines here
  no strict 'refs';
  for my $func (@EXPORT_OK) {
    *{$func} = \&{'Algorithm::Diff::XS::' . $func};
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

=head1 EXPORTABLE FUNCTIONS

The following functions are available for import into your namespace:

=over

=item * prepare

=item * LCS

=item * LCSidx

=item * LCS_length

=item * diff

=item * sdiff

=item * compact_diff

=item * traverse_sequences

=item * traverse_balanced

=back

For full documentation, see the relevant functional descriptions in the Pure
Perl implementation, L<Algorithm::Diff>.

=method new

  Algorithm::Diff::Any->new( \@seq1, \@seq2, \%opts );

Creates a C<Algorithm::Diff::Any> object, based upon either the optimized
C/XS version of the algorithm, L<Algorithm::Diff::XS>, or falls back to
the Pure Perl implementation, L<Algorithm::Diff>.

Example code:

  my $diff = Algorithm::Diff::Any->new( \@seq1, \@seq2 );
  # or with options
  my $diff = Algorithm::Diff::Any->new( \@seq1, \@seq2, \%opts );

This method will return an appropriate B<Algorithm::Diff::Any> object or
throw an exception on error.

=cut

# Wrappers around the actual methods
sub new
{
  my ($class, $seq1, $seq2, $opts) = @_;

  Carp::croak('You must call this as a class method') if ref($class);

  Carp::croak('You must provide two sequences to compare as array refs')
    unless (ref($seq1) eq 'ARRAY' && ref($seq2) eq 'ARRAY');

  my $self = {
  };

  if ($DRIVER eq 'XS')
  {
    $self->{backend} = Algorithm::Diff::XS->new($seq1, $seq2, $opts);
  }
  else
  {
    $self->{backend} = Algorithm::Diff->new($seq1, $seq2, $opts);
  }

  bless($self, $class);
  return $self;
}

=method Next

  $diff->Next( $count )

See L<Algorithm::Diff> for method documentation.

=cut

sub Next
{
  shift->{backend}->Next(@_);
}

=method Prev

  $diff->Prev( $count )

See L<Algorithm::Diff> for method documentation.

=cut

sub Prev
{
  shift->{backend}->Prev(@_);
}

=method Reset

  $diff->Reset( $pos )

See L<Algorithm::Diff> for method documentation.

=cut

sub Reset
{
  my $self = shift;
  $self->{backend}->Reset(@_);
  return $self;
}

=method Copy

  $diff->Copy( $pos, $newBase )

See L<Algorithm::Diff> for method documentation.

=cut

sub Copy
{
  shift->{backend}->Copy(@_);
}

=method Base

  $diff->Base( $newBase )

See L<Algorithm::Diff> for method documentation.

=cut

sub Base
{
  shift->{backend}->Base(@_);
}

=method Diff

  $diff->Diff( )

See L<Algorithm::Diff> for method documentation.

=cut

sub Diff
{
  shift->{backend}->Diff(@_);
}

=method Same

  $diff->Same( )

See L<Algorithm::Diff> for method documentation.

=cut

sub Same
{
  shift->{backend}->Same(@_);
}

=method Items

  $diff->Items( $seqNum )

See L<Algorithm::Diff> for method documentation.

=cut

sub Items
{
  shift->{backend}->Items(@_);
}

=method Range

  $diff->Range( $seqNum, $base )

See L<Algorithm::Diff> for method documentation.

=cut

sub Range
{
  shift->{backend}->Range(@_);
}

=method Min

  $diff->Min( $seqNum, $base )

See L<Algorithm::Diff> for method documentation.

=cut

sub Min
{
  shift->{backend}->Min(@_);
}

=method Max

  $diff->Max( $seqNum, $base )

See L<Algorithm::Diff> for method documentation.

=cut

sub Max
{
  shift->{backend}->Max(@_);
}

=method Get

  $diff->Get( @names )

See L<Algorithm::Diff> for method documentation.

=cut

sub Get
{
  shift->{backend}->Get(@_);
}

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

=head1 SEE ALSO

L<Algorithm::Diff>, the classic reference implementation for finding the
differences between two chunks of text in Perl. It is based on the algorithm
described in I<A Fast Algorithm for Computing Longest Common Subsequences>,
CACM, vol.20, no.5, pp.350-353, May 1977.

L<Algorithm::Diff::XS>, the C/XS optimized version of Algorithm::Diff, which
will be used automatically if available.

=head1 CAVEATS

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

=cut

1;
