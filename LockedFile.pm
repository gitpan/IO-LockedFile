package IO::LockedFile; 

use strict;
use vars qw($VERSION @ISA);

$VERSION = 0.1;

use IO::File;
@ISA = ("IO::File"); # subclass of IO::File

use strict;
use Fcntl ':flock'; # import LOCK_* constants
use Carp;

###########################
# new
###########################
# the constructor
sub new {
    my $proto = shift;          # get the class name
    my $class = ref($proto) || $proto;
    my $self  = $class->SUPER::new(); # the object is also file handle

    bless ($self, $class);
    # if receives any parameters, call our open with those parameters
    if (@_) {
	$self->open(@_);
    }

    return $self;
} # of new

############################
# open
############################
sub open {
    my $self = shift;

    # call open of the super class (IO::File) with the rest of the parameters
    $self->SUPER::open(@_); 

    # if the file was opened - lock it 
    if ($self->opened()) {
	unless (flock($self, LOCK_EX)) { # this will block till the file
	                                 # is unlocked.
	    croak("IO::LockedFile: Cannot lock");
	}
    }
    return $self;
} # of open

########################
# close
########################
sub close {
    my $self = shift;
    # if the file was opened - ulock it 
    if ($self->opened) {
        unless (flock($self, LOCK_UN)) {
            croak("IO::LockedFile: Cannot unlock");
        }
    }
    $self->SUPER::close();
} # of close

#######################
# is_locked
#######################
sub is_locked {
    shift; # we don't need the name of the class
    my $fh;
    # we try to open the file. note that $fh is in scope only in this
    # method, which means that the file is opened only when this method 
    # is running.	
    $fh = new IO::File(@_);

    # we check if it is locked by trying to lock it.
    if (flock($fh, LOCK_EX | LOCK_NB)) {
	# if it is not locked, we could lock it. so unlock it and 
	# return zero.
        flock($fh, LOCK_UN); 
        return 0; # not locked	
    }
    else {
        return 1; # locked
    }    
} # of is_locked

#######################
# DESTROY
#######################    
sub DESTROY {
    my $self = shift;
    # if the file was opened - ulock it 
    if ($self->opened) {
        unless (flock($self, LOCK_UN)) {
            croak("IO::LockedFile: Cannot unlock"); 
        }
    }
} # of DESTROY 

1;
__END__

###########################################################################

=head1 NAME

IO::LockedFile Class - supply object methods for locking files 

=head1 SYNOPSIS

  use IO::LockedFile;
              
  # create new locked file object. $file will hold a file handle.
  # if the file is already locked, the method will not return until the
  # file is unlocked 
  my $file = new IO::LockedFile(">locked1.txt");

  # when we close the file - it become unlocked.
  $file->close();

  # if we delete the object, the file is automatically unlocked and 
  # closed.
  $file = undef;

=head1 DESCRIPTION

The IO::LockedFile class gives us the same interface of the IO::File class 
to files with the unique difference that those files are locked using
the flock mechanism.  

If during the running of the process, the process crashed - the file will 
be automatically unlocked. Actually - if the IO::LockedFile object goes
out of scope, the file is automatically closed and unlocked.

=head1 CONSTRUCTOR

=over 4

=item new ( FILENAME [,MODE [,PERMS]] )

Creates a C<IO::LockedFile>.  If it receives any parameters, they are passed 
to the method C<open>; if the open fails, the object is destroyed. Otherwise,
it is returned to the caller.

=back

=head1 METHODS

=over 4

=item open( FILENAME [,MODE [,PERMS]] )

The file FILENAME will be opened as a locked file, and the object will be 
the file handle of that opened file. If the file that is opened is locked 
the method will not return until the file is unlocked. 
The parameters that should be provided are the same as the parameters that
the method C<open> of  C<IO::File> accepts. (like ">file.txt" for example).

=item close()

The file will be closed and unlocked. The method does not return anything. 

=item is_locked( FILENAME )

Will return true if the file is locked. Will return false otherwise.


=head1 AUTHOR

Rani Pinchuk, rani@cpan.org

=head1 COPYRIGHT

Copyright (c) 2001 EM-TECH (www.em-tech.net) & Rani Pinchuk. 
All rights reserved.  
This package is free software; you can redistribute it and/or modify 
it under the same terms as Perl itself.

=head1 SEE ALSO

L<IO::File(3)>

=cut
