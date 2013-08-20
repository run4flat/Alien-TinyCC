package Alien::TinyCC;

# Follow Golden's Version Rule: http://www.dagolden.com/index.php/369/version-numbers-should-be-boring/
our $VERSION = "0.01";
$VERSION = eval $VERSION;

use File::ShareDir;

# Modifies PATH environment variable to include tcc's directory
sub prepare_path {
	return File::ShareDir::dist_dir('Alien-TinyCC') . '/stuff';
}

# prefix
# version
# libs
# include/cflags?

1;

__END__

=head1 Alien::TinyCC

=cut
