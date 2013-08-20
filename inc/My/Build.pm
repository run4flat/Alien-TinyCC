########################################################################
                       package My::Build;
########################################################################

use parent 'Module::Build';

sub ACTION_build {
	my $self = shift;
	
	mkdir 'share';
	
	$self->SUPER::ACTION_build;
}

sub ACTION_code {
	my $self = shift;
	
	# Only build if it hasn't built already
	my @files = glob('share/*');
	$self->my_code if @files == 0;
	
	$self->SUPER::ACTION_code;
}

use File::Path;
sub ACTION_clean {
	my $self = shift;
	
	File::Path::remove_tree('share');
	
	# Call system-specific cleanup code
	$self->my_clean;
	
	# Call base-class code
	$self->SUPER::ACTION_clean;
}

1;
