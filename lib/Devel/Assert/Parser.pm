#!/usr/bin/perl
package Devel::Assert::Parser;

use strict;
use Devel::Declare ();

sub DEBUG() { 0 }

our $VERSION = '0.01';

sub new{
	my ($class, $offset) = @_;

	print STDERR "new called at $offset\n" if DEBUG;
	bless {
		offset	=> $offset,
	}, $class;
}

#token manip

sub skip_word{
	my $self = shift;

	print STDERR "skip_word called at $self->{offset}\n" if DEBUG;

	if (my $len = Devel::Declare::toke_scan_word($self->{'offset'}, 1)) {
		$self->{'offset'} += $len;
	}
}

sub get_word{
	my $self = shift;

	print STDERR "get_word called at $self->{offset}\n" if DEBUG;

	if (my $len = Devel::Declare::toke_scan_word($self->{'offset'}, 1)) {
		return substr(Devel::Declare::get_linestr(), $self->{'offset'}, $len);
	}
	return '';
}

sub skip_spaces{
	my $self = shift;

	print STDERR "skip_spaces called at $self->{offset}\n" if DEBUG;

	$self->{'offset'} += Devel::Declare::toke_skipspace($self->{'offset'});
}

sub get_symbols{
	my ($self, $len) = @_;

	print STDERR "get_symbols called at $self->{offset} for $len\n" if DEBUG;

	return substr(Devel::Declare::get_linestr(), $self->{'offset'}, $len);
}

sub extract_args{
	my $self = shift;

	print STDERR "extract_args called at $self->{offset}\n" if DEBUG;

	my $linestr = Devel::Declare::get_linestr();
	if (substr($linestr, $self->{'offset'}, 1) eq '(') {
		my $length = Devel::Declare::toke_scan_str($self->{'offset'});
		my $proto = Devel::Declare::get_lex_stuff();
		Devel::Declare::clear_lex_stuff();

		$linestr = Devel::Declare::get_linestr();
		if (
			$length < 0
				||
			$self->{'offset'} + $length > length($linestr)
		){
			require Carp;
			Carp::croak("Unbalanced text supplied for assert");
		}
		substr($linestr, $self->{'offset'}, $length) = '';
		Devel::Declare::set_linestr($linestr);

		return $proto;
	}
	return '';
}

#injectors

sub inject{
	my ($self, $inject) = @_;

	print STDERR "inject called at $self->{offset} for '$inject'\n" if DEBUG;

	my $linestr = Devel::Declare::get_linestr;
	if ($self->{'offset'} > length($linestr)){
		require Carp;
		Carp::croak("Parser tried to inject data outside program source, stopping");
	}
	substr($linestr, $self->{'offset'}, 0) = $inject;
	Devel::Declare::set_linestr($linestr);

	$self->{'offset'} += length($inject);
}

sub shadow{
	my $pack = Devel::Declare::get_curstash_name;

	print STDERR "shadow'ing for '${pack}::assert'\n" if DEBUG;

	Devel::Declare::shadow_sub("${pack}::assert", $_[1]);
}

1;

__END__

=head1 NAME

Devel::Assert::Parser - parses source for L<Devel::Assert> and is not intended for external use.

=head1 AUTHOR

Copyright (c) 2009 by Sergey Aleynikov.
This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
