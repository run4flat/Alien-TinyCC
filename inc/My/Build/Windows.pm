########################################################################
                   package My::Build::Windows;
########################################################################

use strict;
use warnings;
use parent 'My::Build';
use File::Copy::Recursive;

sub my_code {
	my $self = shift;
	
	# move into the source directory and invoke the custom Windows build
	chdir 'src\\win32';
	system('build-tcc.bat');
	chdir '..\\..';
	
	# Copy the files to the distribution's share dir
	File::Copy::Recursive::rcopy_glob('src\\win32\\*' => 'share\\');
}

sub my_clean {}

1;
