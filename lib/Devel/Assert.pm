#!/usr/bin/perl
package Devel::Assert;

use strict;
use Devel::Declare ();
use Devel::Assert::Parser;

my $FORCE_ASSERTS = undef;
my $ASSERT_STATUS = {};
my $ASSERT_CONDS = {};
my $cond_counter = 0;

$Carp::Internal{'Devel::Assert'}++;
$Carp::Internal{'Devel::Declare'}++;

our $VERSION = '0.02';

my $fail_actions = {
	verbose			=> 0,
	hook_terse		=> \&hook_terse,
	hook_verbose	=> \&hook_verbose,
};

sub import{
	my $class = shift;
	my $caller = caller;

	my $flag = shift;

	if ($flag && $flag eq '-verbose'){
		$fail_actions->{'verbose'} = 1;
		$flag = shift;
	}

	if (!defined($FORCE_ASSERTS) && $flag){
		if ($flag eq '-none'){
			$FORCE_ASSERTS = 0;
		}elsif($flag eq '-all'){
			$FORCE_ASSERTS = 1;
		}
	}

	if (defined($FORCE_ASSERTS)){
		$ASSERT_STATUS->{$caller} = $FORCE_ASSERTS;
	}else{
		$ASSERT_STATUS->{$caller} = $flag ? 1 : 0;
	}

	if (scalar @_ == 1 && $_[0] eq '-verbose'){
		$fail_actions->{'verbose'} = 1;
	}elsif(scalar @_){
		require Carp;
		Carp::croak('Wrong options supplied for Devel::Assert');
	}

	Devel::Declare->setup_for(
		$caller,
		{ assert => { const => \&parse_assert } }
	);

	no strict 'refs';
	if ($ASSERT_STATUS->{$caller}){
		*{$caller.'::assert'} = sub ($$) {warn "this shouldn't be called - report your case to author\n"};
	}else{
		*{$caller.'::assert'} = sub () { warn "this shouldn't be called - report your case to author\n" };
	}
}

sub unimport{
	$ASSERT_STATUS->{scalar caller} = 0;
}

sub set_options{
	my %params = @_;

	$fail_actions->{'verbose'} = $params{'verbose'}
		if exists $params{'verbose'};

	$fail_actions->{'hook_terse'} = $params{'hook_terse'}
		if exists $params{'hook_terse'} && ref($params{'hook_terse'}) eq 'CODE';

	$fail_actions->{'hook_verbose'} = $params{'hook_verbose'}
		if exists $params{'hook_verbose'} && ref($params{'hook_verbose'}) eq 'CODE';
}

sub parse_assert{
	my $parser = Devel::Assert::Parser->new($_[1]);

	return if $parser->get_word() ne 'assert';

	$parser->skip_word();
	$parser->skip_spaces();
	return if $parser->get_symbols(2) eq '=>';

	if ($parser->get_symbols(1) ne '('){
		require Carp;
		Carp::croak("You must use assert ONLY as 'assert(expression);'");
	}

	my $args = $parser->extract_args();
	$args =~ s/(\r|\n)//go;

	my $pkg = Devel::Declare::get_curstash_name;

	if (!$ASSERT_STATUS->{$pkg} || !length($args)){
		$parser->shadow(sub () { 1 });

	}else{
		$parser->inject("($args, $cond_counter)");

		$args =~ s/^\s+//;
		$args =~ s/\s+$//;
		$ASSERT_CONDS->{$cond_counter} = $args;

		$parser->shadow(sub ($$) {
			if (!$_[0]) {
				if ($fail_actions->{'verbose'}){
					return $fail_actions->{'hook_verbose'}->($ASSERT_CONDS->{$_[1]});
				}else{
					return $fail_actions->{'hook_terse'}->($ASSERT_CONDS->{$_[1]});
				}
			}
		});

		$cond_counter++;
	}
}

sub hook_terse{
	require Carp;
	Carp::confess("Assertion ' $_[0] ' failed$_[1]");
}

sub hook_verbose{
	my $message = shift;

	eval { require Data::Dumper; 1 } or do {
		warn "Asked for detailed variables report, but no 'Data::Dumper' found\n";
		return $fail_actions->{'hook_terse'}->($message);
	};

	eval { require PadWalker; 1 } or do {
		warn "Asked for detailed variables report, but no 'PadWalker' found\n";
		return $fail_actions->{'hook_terse'}->($message);
	};

	my $tail = ", trying to determine acting variables...";
	my @var_list = ();
	my @names_list = ();

	my $my_list = PadWalker::peek_my(2);
	while (my ($name, $val_ref) = each(%$my_list)) {
		$name =~ s/\$/\\\$/;
		if ($message =~ /$name(?:\W(?<!:)|$)/){
			if ($name =~ m'^\\\$'){
				push @var_list, $$val_ref;
				$name =~ s/\\\$/\$/;
			}else{
				push @var_list, $val_ref;
			}

			$name =~ s/[\$\@\%]/\*/;
			push @names_list, $name;
		}
	}

	my $our_list = PadWalker::peek_our(2);
	while (my ($name, $val_ref) = each(%$our_list)) {
		next if exists $my_list->{$name};

		$name =~ s/\$/\\\$/;
		if ($message =~ /$name(?:\W(?<!:)|$)/){
			if ($name =~ m'^\\\$'){
				push @var_list, $$val_ref;
				$name =~ s/\\\$/\$/;
			}else{
				push @var_list, $val_ref;
			}

			$name =~ s/[\$\@\%]/\*/;
			push @names_list, $name;
		}
	}

	if (scalar @var_list == 0){
		$tail .= "none found\n";
	}else{
		local $Data::Dumper::Maxdepth = 2;
		local $Data::Dumper::Pad = '  ';
		$tail .= "\n".Data::Dumper->Dump(\@var_list, \@names_list);
	}

	$tail .= "...and all this happened";
	return $fail_actions->{'hook_terse'}->($message, $tail);
}

1;
