package Alien::TinyCC;

# Follow Golden's Version Rule: http://www.dagolden.com/index.php/369/version-numbers-should-be-boring/
our $VERSION = "0.01";
$VERSION = eval $VERSION;

use File::ShareDir;
use File::Spec;
use Env qw( @PATH @LD_LIBRARY_PATH );
use Carp;

# The prefix will depend on whether or not the thing was finally installed.
# Let's assume it was, and if not (i.e. during testing before the install), we
# can take more drastic measures
my $dist_dir;
eval {
	$dist_dir = File::ShareDir::dist_dir('Alien-TinyCC');
	1;
} or do {
	# OK, need to take more drastic measures. Get the directory of THIS module,
	# and find the share/ dir from that
	my $mod_path = $INC{'Alien/TinyCC.pm'};
	if ($mod_path =~ s/blib.*/share/) {
		$dist_dir = $mod_path;
		croak('Looks like Alien::TinyCC is being invoked from blib, but I cannot find build-time sharedir!')
			unless -d $dist_dir;
	}
	else {
		croak('It looks like Alien::TinyCC is installed, but there is no File::ShareDir for it!');
	}
};

# Find the path to the tcc executable
sub path_to_tcc {
	if ($^O =~ /MSWin/) {
		return $dist_dir;
	}
	return File::Spec->catdir($dist_dir, 'bin');
}

# Modify the PATH environment variable to include tcc's directory
unshift @PATH, path_to_tcc();

# Find the path to the compiled libraries (only applicable on Unixish systems;
# Windows simply uses the %PATH%)
sub ld_library_path {
	return File::Spec->catdir($dist_dir, 'lib');
}
# Add library path on Unixish:
unshift @LD_LIBRARY_PATH, ld_library_path() unless $^O =~ /MSWin/;

# version

# Determine the include paths
sub include_paths {
	if ($^O =~ /MSWin/) {
		return File::Spec->catdir($dist_dir, 'libtcc');
	}
	return (
		File::Spec->catdir($dist_dir, 'include'),
		File::Spec->catdir($dist_dir, 'lib', 'tcc', 'include'),
	);
}

sub system_tcc {
	my ($class, @args) = @_;
	# TCC is in the path and the linker stuff should be set up either by
	# setting the path (Windows) or ld_library_path (everything else).
	# I just need to set up the includes directory:
	my @includes = map { "-I$_" } include_paths;
	system('tcc', @includes, @args);
}

sub qx_tcc {
	my ($class, @args) = @_;
	my @includes = map { "-I$_" } include_paths;
	my $args_string = join(' ', @includes, @args);
	`tcc $args_string`;
}

1;

__END__

=head1 Alien::TinyCC

=cut
