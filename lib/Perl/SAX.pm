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
	$VERSION = '0.03';
}

# While in development, use a version-specific namespace.
# In theory, this ensures documents are only truly valid with the
# version they were created with.
use constant XMLNS => "http://ali.as/xml/schema/experimental/perlml/$VERSION/";





#####################################################################
# Constructor and Accessors

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
		NamespaceURI => '',
		Prefix       => '',
		Handler      => undef,
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

	# Generate NamespaceURI information?
	if ( $params{NamespaceURI} ) {
		if ( length $params{NamespaceURI} > 1 ) {
			# Custom namespace
			$self->{NamespaceURI} = $params{NamespaceURI};
		} else {
			# Default namespace
			$self->{NamespaceURI} = XMLNS;
		}
	}

	# Use a prefix?
	if ( $params{Prefix} ) {
		$self->{Prefix} = $params{Prefix};
	}

	$self;
}

sub NamespaceURI { $_[0]->{NamespaceURI} }
sub Prefix       { $_[0]->{Prefix}       }
sub Handler      { $_[0]->{Handler}      }
sub Output       { $_[0]->{Output}       }





#####################################################################
# Main Methods

# Prevent use as a SAX Filter.
# We only generate SAX events, we don't consume them.
sub start_document {
	my $class = ref $_[0] || $_[0];
	die "$class can only be used as a SAX Driver";
}

sub parse {
	my $self     = shift;
	my $Document = isa(ref $_[0], 'PPI::Document') ? shift : return undef;

	# Generate the SAX2 events
	$self->SUPER::start_document( {} );
	$self->_parse_document( $Document ) or return undef;
	$self->SUPER::end_document( {} );

	1;
}

sub _parse {
	my $self    = shift;
	my $Element = isa(ref $_[0], 'PPI::Element') ? shift : return undef;

	# Split to the various generic handlers
	  isa($Element, 'PPI::Token')     ? $self->_parse_token( $Element )
	: isa($Element, 'PPI::Statement') ? $self->_parse_statement( $Element )
	: isa($Element, 'PPI::Structure') ? $self->_parse_structure( $Element )
	: undef;
}

sub _parse_document {
	my $self     = shift;
	my $Document = isa(ref $_[0], 'PPI::Document') ? shift : return undef;

	# Generate the SAX2 events
	my $Element = $self->_element( $Document ) or return undef;
	$self->start_element( $Element );
	foreach my $Child ( $Document->elements ) {
		$self->_parse( $Child ) or return undef;
	}
	$self->end_element( $Element );

	1;
}

sub _parse_token {
	my $self  = shift;
	my $Token = isa(ref $_[0], 'PPI::Token') ? shift : return undef;

	# Support custom handlers
	my $method = $self->_tag_method( $Token );
	return $self->$method( $Token ) if $self->can($method);

	# Generate the SAX2 events
	my $Element = $self->_element( $Token ) or return undef;
	$self->start_element( $Element );
	$self->characters( {
		Data => $Token->content,
		} );
	$self->end_element( $Element );

	1;
}

sub _parse_statement {
	my $self      = shift;
	my $Statement = isa(ref $_[0], 'PPI::Statement') ? shift : return undef;

	# Support custom handlers
	my $method = $self->_tag_method( $Statement );
	return $self->$method( $Statement ) if $self->can($method);

	# Generate the SAX2 events
	my $Element = $self->_element( $Statement ) or return undef;
	$self->start_element( $Element );
	foreach my $Child ( $Statement->elements ) {
		$self->_parse( $Child ) or return undef;
	}
	$self->end_element( $Element );

	1;
}

sub _parse_structure {
	my $self      = shift;
	my $Structure = isa(ref $_[0], 'PPI::Structure') ? shift : return undef;

	# Support custom handlers
	my $method = $self->_tag_method( $Structure );
	return $self->$method( $Structure ) if $self->can($method);

	# Generate the SAX2 events
	my $Element = $self->_element( $Structure, {} ) or return undef;
	$self->start_element( $Element );
	foreach my $Child ( $Structure->elements ) {
		$self->_parse( $Child ) or return undef;		
	}
	$self->end_element( $Element );

	1;
}





#####################################################################
# Support Methods

# Strip out the Attributes for the end element
sub end_element {
	delete $_[1]->{Attributes};
	shift->SUPER::end_element(@_);
}

# Auto-preparation of the text
sub characters {
	my $self = shift;
	(ref $_[0])
		? $self->SUPER::characters(shift)
		: $self->SUPER::characters( {
			Data => $self->_escape(shift),
			} );
}

sub _tag_name {
	my $tag  = lc ref $_[1];
	$tag =~ s/::/_/g;
	substr $tag, 4;
}

sub _tag_method {
	my $tag = lc ref $_[1];
	$tag =~ s/::/_/g;
	'_parse_' . substr $tag, 4;
}

sub _element {
	my $self      = shift;
	my $LocalName = isa(ref $_[0], 'PPI::Element')
		? $self->_tag_name(shift)
		: $_[0]
		or return undef;
	my $attr = ref $_[0] eq 'HASH' ? shift : {};

	# Localise some variables for speed
	my $NamespaceURI = $self->{NamespaceURI};
	my $Prefix       = $self->{Prefix} ? "$self->{Prefix}:" : '';

	# Convert the attributes to the full version
	my %Attributes = ();
	foreach my $key ( keys %$attr ) {
		$Attributes{"{$NamespaceURI}$key"} = {
			Name         => $Prefix . $key,
			NamespaceURI => $NamespaceURI,
			Prefix       => $Prefix,
			LocalName    => $key,
			Value        => $attr->{$key},
			};
	}

	# Create the main element
	return {
		Name         => $Prefix . $LocalName,
		NamespaceURI => $NamespaceURI,
		Prefix       => $Prefix,
		LocalName    => $LocalName,
		Attributes   => \%Attributes,
		};
}

### Not sure if we escape here.
### Just pass through for now.
sub _escape { $_[1] }

1;

=pod

=head1 TO DO

Design and create the PerlML Schema

Make any changes needed to conform to it

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
