########################################################################
                       package My::Build;
########################################################################

use strict;
use warnings;
use parent 'Module::Build';

sub ACTION_build {
	my $self = shift;
	
	mkdir 'share';
	
	$self->SUPER::ACTION_build;
}

use File::Path;
sub ACTION_clean {
	my $self = shift;
	
	File::Path::remove_tree('share');
	$self->notes('build_state', '');
	
	# Call system-specific cleanup code
	$self->my_clean;
	
	# Call base-class code
	$self->SUPER::ACTION_clean;
}

1;
