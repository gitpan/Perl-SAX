use inc::Module::Install;

name           ( 'Perl-SAX'                     );
abstract       ( 'Generate SAX events for Perl Documents' );
author         ( 'Adam Kennedy <cpan@ali.as>'   );
version_from   ( 'lib/Perl/SAX.pm'              );
license        ( 'perl'                         );
requires       ( 'perl'             => '5.005'  );
requires       ( 'XML::SAX::Base'   => '1.04'   );
requires       ( 'XML::SAX::Writer' => '0.44'   );
requires       ( 'PPI'              => '1.002'  );
build_requires ( 'File::Spec'       => '0.80'   );
build_requires ( 'Test::More'       => '0.47'   );
no_index       ( directory          => 't.data' );

auto_install();

&WriteAll;
