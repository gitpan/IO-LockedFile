# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

BEGIN { $| = 1; print "1..3\n"; }
END { print "not ok 1\n" unless $loaded;}

use IO::LockedFile;
use diagnostics;
$loaded = 1;
print "ok 1\n";

# create a locked file
my $file = new IO::LockedFile(">locked1.txt");

# check that the file is locked
if( my $pid = fork ) {
    wait;
}
else {
    print is_locked() ? "ok 2\n" : "not ok 2\n";
    exit 0;
}

# close (and unlock) the file
$file = undef;

# check that the file is not locked
if( my $pid = fork ) {
    wait;
}
else {
    print is_locked() ? "not ok 3\n" : "ok 3\n";
    exit 0;
}

# remove the file
unlink("locked1.txt");

sub is_locked {
    return( ! new IO::LockedFile( { block => 0 }, "locked1.txt", "r+" ) );
}
