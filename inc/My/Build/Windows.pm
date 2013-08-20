########################################################################
                   package My::Build::Windows;
########################################################################

use parent 'My::Build';
File::Copy::Recursive qw( rcopy_glob );

sub my_code {
	my $self = shift;
	
	# move into the source directory and invoke the custom Windows build
	chdir 'src\\win32';
	system('build-tcc.bat');
	chdir '..\\..';
	
	# Copy the files to the distribution's share dir
	rcopy_glob('src\\win32\\*' => 'share\\');
}

1;
