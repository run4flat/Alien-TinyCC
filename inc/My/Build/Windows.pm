########################################################################
                   package My::Build::Windows;
########################################################################

use strict;
use warnings;
use parent 'My::Build';
use File::Copy::Recursive;

sub ACTION_code {
	my $self = shift;
	
	if (not $self->notes('build_state')) {
		# move into the source directory and invoke the custom Windows build
		chdir 'src\\win32';
		system('build-tcc.bat');
		chdir '..\\..';
		
		# Copy the files to the distribution's share dir
		File::Copy::Recursive::rcopy_glob('src\\win32\\*' => 'share\\');
		
		# Note that we've built it.
		$self->notes('build_state', 'built');
	}
	
	$self->SUPER::ACTION_code;
}

sub my_clean {}

1;
