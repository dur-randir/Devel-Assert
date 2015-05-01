package Devel::Assert;
use strict;

our $VERSION = '1.00';
our $__ASSERT_ON = 0;

require XSLoader;
XSLoader::load('Devel::Assert', $VERSION);

sub import{
	my $class = shift;
	my $caller = caller;

    no strict 'refs';
    *{"${caller}::assert"} = \&assert if !defined *{"${caller}::assert"}{CODE};

    $__ASSERT_ON = 1;
}

sub unimport{
    $__ASSERT_ON = 0;
}

sub assert {
    unless ($_[0]) {
        require Carp;
        $Carp::Internal{'Devel::Assert'}++;
        Carp::confess("Assertion failed");
    }
}

1;

