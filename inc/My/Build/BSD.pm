########################################################################
                    package My::Build::BSD;
########################################################################

use strict;
use warnings;
use parent 'My::Build::Linux';

sub make_command { 'gmake' }

### MidnightBSD detection patch ###

my $is_midnight_handled = 0;

# Apply patch for MidnightBSD
My::Build::apply_patches('src/configure' =>
	# Note if we have already taken care of midnight bsd or not
	qr/MidnightBSD\) noldl=yes;;/ => sub {
		$is_midnight_handled = 1;
		return 0;
	},
	qr/DragonFly\) noldl=yes;;/ => sub {
		my ($in_fh, $out_fh, $line) = @_;
		print $out_fh "  MidnightBSD) noldl=yes;;\n"
			unless $is_midnight_handled;
		return 0;
	}
	
);

### ucontext location detection patch ###

use File::Temp qw/ tempfile /;
use Config;

# Test for ucontext.h vs sys/ucontext.h
sub try_include_file {
	my $lib_name = shift;
	my ($out_fh, $out_filename) = tempfile(UNLINK => 1);
	print $out_fh "#include <$lib_name>\n";
	close $out_fh;
	print "Testing for ucontext as $lib_name...\n";
	return system("$Config{cc} $out_filename") == 0 ? $lib_name : undef;
}

my $ucontext_include = try_include_file('ucontext.h')
	|| try_include_file('sys/ucontext.h')
	|| die "Unable to locate ucontext!";

# Now patch tcc.h for the proper ucontext location
My::Build::apply_patches('src/tcc.h'
	qr{#include <sys/ucontext\.h>} => sub {
		my ($in_fh, $out_fh, $line) = @_;
		print $out_fh "#include <ucontext.h>\n";
		return 1;
	},
) if $ucontext_include eq 'ucontext.h';

1;
