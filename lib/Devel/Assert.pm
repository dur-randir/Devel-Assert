package Devel::Assert;
use strict;

our $VERSION = '1.00';

our $__ASSERT_GLOBAL = 0;

require XSLoader;
XSLoader::load('Devel::Assert', $VERSION);

sub import {
	my ($class, $arg) = @_;
	my $caller = caller;

    $__ASSERT_GLOBAL = 1 if $arg eq 'global';

    my $ref = $arg eq 'off' || !$__ASSERT_GLOBAL && $arg ne 'on' ? \&assert_off : \&assert_on;
    {
        no strict 'refs';
        *{"${caller}::assert"} = $ref if !defined *{"${caller}::assert"}{CODE};
    }
}

sub assert_on {
    unless ($_[0]) {
        require Carp;
        $Carp::Internal{'Devel::Assert'}++;
        Carp::confess("Assertion failed");
    }
}

sub assert_off {}

1;

