require 5.000;
use ExtUtils::MakeMaker;
WriteMakefile(
	'NAME'         => 'Perl::SAX',
	'VERSION_FROM' => 'lib/Perl/SAX.pm',
	'PREREQ_PM'    => {
		# Needed by Perl::SAX
		'Class::Autouse'   => '1.04',
		'XML::SAX::Base'   => '1.04',
		'XML::SAX::Writer' => '0.44',
		'PPI'              => '0.828', # Keep this current

		# Needed by tests
		'Test::More'       => 0,
		'File::Spec'       => '0.83',
		},

	($] >= 5.005) ? (
		'AUTHOR'   => 'Adam Kennedy (cpan@ali.as)',
		'ABSTRACT' => 'Generate SAX events for perl source code (incomplete)',
	) : (),
);
