use strict;
use warnings;
use lib 'inc';

#            if OS is...      class is...
my $class = $^O =~ /MSWin/   ? 'My::Build::Windows'
           : $^O =~ /Cygwin/  ? 'My::Build::Cygwin'
           : $^O =~ /darwin/  ? 'My::Build::MacOSX'
           :                    'My::Build::Linux'
           ;

(my $module_file = "$class.pm") =~ s/::/\//g;
require $module_file;
$class->new(
	module_name => 'Alien::TinyCC',
	dist_abstract => 'Ensure the Tiny C Compiler is installed on your system',
	dist_author => 'David Mertens <dcmertens.perl@gmail.com>',
	license => 'perl',
	share_dir => 'share',
	configure_requires => {
		'Module::Build' => 0,
	},
	build_requires => {
		'Module::Build' => 0,
		'Test::File::ShareDir' => 0,
		'ExtUtils::CBuilder' => 0,
		# only really needed for Windows, but I'm lazy at the moment
		'File::Copy::Recursive' => 0,
	},
	requires => {
		'File::ShareDir' => 0,
	},
)->create_build_script;
