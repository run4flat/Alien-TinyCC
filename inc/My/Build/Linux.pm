########################################################################
                    package My::Build::Linux;
########################################################################

use parent 'My::Build';

# We don't need any extra args for pure Linux builds, but this may be
# overridden by derived classes
sub extra_config_args { '' }

# The prefix for Linux is 

sub ACTION_code {
	my $self = shift;
	my $extra_args = $self->extra_config_args;
	
	# move into the source directory and perform configure, make, and install
	chdir 'src';
	
	# normal incantation
	system('./configure --prefix=../share $extra_args');
	system('make');
	system('make install');
	
	# Move back to the root directory
	chdir '..';
	
	$self->SUPER::ACTION_code;
}

sub ACTION_clean {
	chdir 'src';
	system('make clean');
	chdir '..';
	$self->SUPER::ACTION_clean;
}

1;
