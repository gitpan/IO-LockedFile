# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.
BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $loaded;}
use IO::LockedFile;
use diagnostics;
$loaded = 1;
print "ok 1\n";

# create a locked file
my $file = new IO::LockedFile(">locked1.txt");

# check that the file is locked
print IO::LockedFile->is_locked("locked1.txt") ? "ok 2\n" : "not ok 2\n";

# close (and unlock) the file
$file = undef;

# check that the file is locked
print IO::LockedFile->is_locked("locked1.txt") ? "not ok 3\n" : "ok 3\n";

# remove the file
unlink("locked1.txt");






