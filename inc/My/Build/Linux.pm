########################################################################
                    package My::Build::Linux;
########################################################################

use strict;
use warnings;
use parent 'My::Build';

# We don't need any extra args for pure Linux builds, but this may be
# overridden by derived classes
sub extra_config_args { '' }

# The prefix for Linux is 

sub my_code {
	my $self = shift;
	
	# move into the source directory and perform configure, make, and install
	chdir 'src';
	
	# normal incantation
	my $extra_args = $self->extra_config_args;
	system("./configure --prefix=../share $extra_args");
	system('make');
	system('make install');
	
	# Move back to the root directory
	chdir '..';
}

sub my_clean {
	chdir 'src';
	system('make clean');
	chdir '..';
}

1;
