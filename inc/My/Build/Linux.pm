########################################################################
                    package My::Build::Linux;
########################################################################

use strict;
use warnings;
use parent 'My::Build';
use File::ShareDir;

# We don't need any extra args for pure Linux builds, but this may be
# overridden by derived classes
sub extra_config_args { '' }

sub install_to_prefix {
	my ($self, $prefix) = @_;
	
	# move into the source directory and perform configure, make, and install
	chdir 'src';
	
	# normal incantation
	my $extra_args = $self->extra_config_args;
	system("./configure --prefix=$prefix $extra_args");
	system('make');
	system('make install');
	
	# Move back to the root directory
	chdir '..';
}

use Cwd;
sub my_code {
	my $self = shift;
	
	# Build an absolute prefix to our (local) sharedir
	my $prefix = File::Spec->catdir(getcwd(), 'share');
	
	# Install to that prefix
	$self->install_to_prefix($prefix);
}

sub my_clean {
	chdir 'src';
	system('make clean');
	chdir '..';
}

use File::Path;
sub ACTION_install {
	my $self = shift;
	
	# For unixish systems, we must re-build with the new prefix so that all of
	# the baked-in paths are correct.
	my $prefix = File::ShareDir::dist_dir('Alien-TinyCC');
	File::Path::make_path($prefix);
	$self->install_to_prefix($prefix);
	
	# Proceed with the rest of the install
	$self->SUPER::ACTION_install;
}

1;
