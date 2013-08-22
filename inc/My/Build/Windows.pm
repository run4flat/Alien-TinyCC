########################################################################
                   package My::Build::Windows;
########################################################################

use strict;
use warnings;
use parent 'My::Build';
use File::Copy::Recursive;

sub ACTION_code {
	my $self = shift;
	
	if (not $self->notes('build_state')) {
		# move into the source directory and invoke the custom Windows build
		chdir 'src\\win32';
		patch_build_tcc_bat();
		system('build-tcc.bat');
		chdir '..\\..';
		
		# check if there was a mishap:
		$ENV{ERRORLEVEL} and die 'build-tcc.bat failed';
		
		# Copy the files to the distribution's share dir
		File::Copy::Recursive::rcopy_glob('src\\win32\\*' => 'share\\');
		
		# Note that we've built it.
		$self->notes('build_state', 'built');
	}
	
	$self->SUPER::ACTION_code;
}

sub my_clean {}

sub patch_build_tcc_bat {
	# Assumes we're already in src\win32
	my $filename = 'build-tcc.bat';
	# make the file read-write
	chmod 0700, $filename;
	
	open my $in_fh, '<', $filename;
	open my $out_fh, '>', "$filename.new";
	LINE: while (my $line = <$in_fh>) {
		# Eat the two lines that talk about PROCESSOR_ARCH and replace them
		if ($line =~ /PROCESSOR_ARCH/) {
			# Eat next line, too
			<$in_fh>;
			print $out_fh <<'EOF';
@FOR /F "delims=" %%i IN ('perl -MConfig -e "$_=$Config{archname}; m/^MSWin32-(.*?)-/; print $1"') DO set TMP_PERLARCH=%%i
@if %TMP_PERLARCH%==x64 goto x86_64
EOF
			next LINE;
		}
		if ($line =~ /\@set CC=x86_64/) {
			print $out_fh "\@set CC=gcc -O0 -s -fno-strict-aliasing\n";
			next LINE;
		}
		print $out_fh $line;
	}
	
	close $in_fh;
	close $out_fh;
	unlink $filename;
	rename "$filename.new" => $filename;
}

1;
