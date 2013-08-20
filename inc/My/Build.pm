########################################################################
                       package My::Build;
########################################################################

use parent 'Module::Build';

sub ACTION_build {
	my $self = shift;
	
	mkdir 'share' unless(-d 'share');
	$self->add_to_cleanup('share');
	
	$self->SUPER::ACTION_build;
}

1;
