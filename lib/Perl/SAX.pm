package Perl::SAX;

=pod

=head1 NAME

Perl::SAX - Generate SAX events for perl source code (incomplete)

=head1 DESCRIPTION

With the completion of a relatively usful perl parser, in the form of
L<PPI|PPI>, there has been renewed interest in parsing perl source code
and "Doing Stuff" with it.

It was felt (actually, it was demanded) that there should be some sort of
event system that could go through a chunk of perl source code and emit events
that would be handled by a variety of methods.

Rather than invent my own, it was much easier to hijack SAX for this purpose.

(The ability to write Acme::PerlML had NOTHING to do with it. I swear!)

Perl::SAX is the result of this need. Starting with a single object of any
type descended from PPI::Node, Perl::Sax will generate a stream of SAX events.

For the sake of compatibility with SAX as a whole, and in the spirit of not
dictating the default behaviour based on any one use of this event stream,
the stream of events will be such that it can be passed to XML::SAX::Writer
and a "PerlML" file will be spat out.

This provides the highest level of details, and allows for a variety of
different potential uses, relating to both the actual and lexical content
inside of perl source code.

=head2 Perl::SAX is only a SAX Driver

Please note that Perl::SAX is B<only> a SAX Driver B<only>. It cannot be used
as a SAX Filter or some other form of SAX Handler, and will die fatally if
you try, as soon as it recieves a C<start_document> event.

=head2 Current State of Completion

Currently, this incomplete version is in CPAN largely as a placeholder. You
can create an object, you just can't do anything with it.

But I would expect it to be fleshed out a bit more during the next serious
chunk of time I get to work on PPI.

=cut

use strict;
use UNIVERSAL 'isa';
use base 'XML::SAX::Base';
use Class::Autouse 'XML::SAX::Writer';

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.01';
}

# While in development, use a version-specific namespace.
# In theory, this ensures documents are only truly valid with the
# version they were created with.
use constant XMLNS => "http://ali.as/xml/schema/devel/PerlML-$VERSION";





#####################################################################
# Constructor and Miscellaneous

=pod

=head1 METHODS

=head2 new [ Handler => $Handler | Output => $WriterConsumer ]

The C<new> constructor creates a new Perl SAX Driver instance.

If passed no arguments, it creates a new default
L<XML::SAX::Writer|XML::SAX::Writer> object, which by default will write the
resulting PerlML file to STDOUT.

If passed an C<Output => $Consumer> argument, this value will be passed along
to the XML::SAX::Writer constructor. Any value that is legal for the Output
parameter to XML::SAX::Writer is also legal here.

If passed a C<Handler => $Handler> argument, C<$Handler> will be used as the
SAX Handler directly. Any value provided via Output in this case will be
ignored.

Returns a new Perl::SAX object, or C<undef> if you pass an illegal Output
value, and the XML::SAX::Writer cannot be created.

=cut

sub new {
	my $class  = shift;
	my %params = @_;

	# Create the empty object
	my $self = bless {
		Root    => undef,
		Handler => undef,
		}, $class;

	# Have we been passed a custom handler?
	if ( $params{Handler} ) {
		### It appears there is no way to test the validity of a SAX handler
		$self->{Handler} = $params{Handler};
	} else {
		# Default to an XML::Writer.
		# Have we been passed in Consumer for it?
		if ( $params{Output} ) {
			$self->{Output} = $params{Output};
		} else {
			my $Output = '';
			$self->{Output} = \$Output;
		}

		# Add the handler for the Output
		$self->{Handler} = XML::SAX::Writer->new( Output => $self->{Output} ) or return undef;
	}

	$self;
}

# Prevent use as a SAX Filter.
# We only generate SAX events, we don't consume them.
sub start_document {
	die "Perl::SAX can only be used as a SAX Driver, it does not accept SAX events";
}




#####################################################################
# Main Methods

sub parse {
	die "->parse has not been implemented yet";
}

1;

=pod

=head1 TO DO

Design and create the PerlML Schema

Complete the C<parse> method

Write a bunch of tests

=head1 SUPPORT

Because the development of the PerlML Schema (and thus this module) has not
been completed yet, please do not report bugs B<other than> those that
are installation-related.

Bugs should be reported via the CPAN bug tracker at

L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Perl%3A%3ASAX>

For other issues, contact the author.

=head1 AUTHOR

Adam Kennedy (Maintainer), L<http://ali.as/>, cpan@ali.as

=head1 COPYRIGHT

Thank you to Phase N (L<http://phase-n.com/>) for permitting
the Open Sourcing and release of this distribution.

Copyright (c) 2004 Adam Kennedy. All rights reserved.
This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.

=cut
