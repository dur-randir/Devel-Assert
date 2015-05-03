package Devel::Assert;
use strict;

our $VERSION = '1.00';

our $__ASSERT_ON     = 0;
our $__ASSERT_GLOBAL = 0;

require XSLoader;
XSLoader::load('Devel::Assert', $VERSION);

sub import {
	my ($class, $arg) = @_;
	my $caller = caller;

    $__ASSERT_ON = 0 unless $__ASSERT_GLOBAL;

    if ($arg eq 'global') {
        $__ASSERT_ON     = 1;
        $__ASSERT_GLOBAL = 1;

    } elsif ($arg eq 'on') {
        $__ASSERT_ON = 1;
    }

    {
        no strict 'refs';
        *{"${caller}::assert"} = \&assert if !defined *{"${caller}::assert"}{CODE};
    }
}

sub unimport {
    $__ASSERT_ON = 0 unless $__ASSERT_GLOBAL;
}

INIT {
    unimport(); #reset to default behaviour for runtime evals
}

sub assert {
    unless ($_[0]) {
        require Carp;
        $Carp::Internal{'Devel::Assert'}++;
        Carp::confess("Assertion failed");
    }
}

1;

