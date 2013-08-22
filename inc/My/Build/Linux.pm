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
	
	return if $self->notes('build_state') eq $prefix;
	
	my_clean();
	
	# move into the source directory and perform configure, make, and install
	chdir 'src';
	
	# clean followed by a normal incantation
	my $extra_args = $self->extra_config_args;
	system("./configure --prefix=$prefix $extra_args")
		and die 'tcc build failed at ./configure';
	system('make')
		and die 'tcc build failed at make';
	system('make install')
		and die 'tcc build failed at make install';
	
	# Move back to the root directory
	chdir '..';
	
	# Record the current build state so we don't build more than necessary.
	$self->notes('build_state', $prefix);
}

use Cwd;
sub ACTION_code {
	my $self = shift;
	$self->notes('build_state', '') unless defined $self->notes('build_state');
	
	# Build an absolute prefix to our (local) sharedir, build and install
	my $prefix = File::Spec->catdir(getcwd(), 'share');
	$self->install_to_prefix($prefix);
	
	$self->SUPER::ACTION_code;
}

sub my_clean {
	return unless -f 'src/config.mak';
	chdir 'src';
	system('make clean');
	chdir '..';
}

use File::Path;
sub ACTION_install {
	my $self = shift;
	
	# For unixish systems, we must re-build with the new prefix so that all of
	# the baked-in paths are correct. I just wanna say this:
	#my $prefix = File::ShareDir::dist_dir('Alien-TinyCC');
	# Unfortunately, this won't work because File::ShareDir expects the
	# folder to already exist.
	
	# Instead, I copy code from Alien::Base::ModuleBuild to calculate the
	# sharedir location by-hand:
	my $prefix = File::Spec->catdir($self->install_destination('lib'),
		qw(auto share dist Alien-TinyCC));
	
	# Completely rebuild (and install) the compiler with the new prefix
	File::Path::make_path($prefix);
	$self->install_to_prefix($prefix);
	
	# Proceed with the rest of the install
	$self->SUPER::ACTION_install;
}

1;
