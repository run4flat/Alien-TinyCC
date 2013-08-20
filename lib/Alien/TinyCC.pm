package Alien::TinyCC;

# Follow Golden's Version Rule: http://www.dagolden.com/index.php/369/version-numbers-should-be-boring/
our $VERSION = "0.01";
$VERSION = eval $VERSION;

use File::ShareDir;
use File::Spec;
use Env qw( @PATH @LD_LIBRARY_PATH );

my $dist_dir = File::ShareDir::dist_dir('Alien-TinyCC');

sub path_to_tcc {
	if ($^O =~ /MSWin/) {
		return $dist_dir;
	}
	return File::Spec->catdir($dist_dir, 'bin');
}

# Modify the PATH environment variable to include tcc's directory
unshift @PATH, path_to_tcc();

sub ld_library_path {
	return File::Spec->catdir($dist_dir, 'lib');
}
unshift @LD_LIBRARY_PATH, ld_library_path unless $^O =~ /MSWin/;

# version

sub include_paths {
	if ($^O =~ /MSWin/) {
		return File::Spec->catdir($dist_dir, 'libtcc');
	}
	return (
		File::Spec->catdir($dist_dir, 'include'),
		File::Spec->catdir($dist_dir, 'lib', 'tcc', 'include'),
	);
}

sub run_tcc {
	my ($class, @args) = @_;
	# TCC is in the path and the linker stuff should be set up either by
	# setting the path (Windows) or ld_library_path (everything else).
	# I just need to set up the includes directory:
	my @includes = map { "-I$_" } include_paths;
	system('tcc', @includes, @args);
}
1;

__END__

=head1 Alien::TinyCC

=cut
