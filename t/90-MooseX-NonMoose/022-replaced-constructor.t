#!/usr/bin/env perl
use strict;
use warnings;
use Test::More skip_all => "not supported";

our $foo_constructed = 0;

package Foo;

sub new {
    my $class = shift;
    bless {}, $class;
}

package Foo::Mouse;
use Mouse;
use MouseX::Foreign;
extends 'Foo';

after new => sub {
    $main::foo_constructed = 1;
};

package Foo::Mouse2;
use Mouse;
use MouseX::Foreign;
extends 'Foo';

sub new {
    my $class = shift;
    $main::foo_constructed = 1;
    return $class->meta->new_object(@_);
}

package main;
my $method = Foo::Mouse->meta->get_method('new');
my $foo = Foo::Mouse->new;
ok($foo_constructed, 'method modifier called for the constructor');
$foo_constructed = 0;
{
    # we don't care about the warning that moose isn't going to inline our
    # constructor - this is the behavior we're testing
    local $SIG{__WARN__} = sub {};
    Foo::Mouse->meta->make_immutable;
}
is($method->body, Foo::Mouse->meta->get_method('new')->body,
   'make_immutable doesn\'t overwrite constructor with method modifiers');
$foo = Foo::Mouse->new;
ok($foo_constructed, 'method modifier called for the constructor (immutable)');

$foo_constructed = 0;
$method = Foo::Mouse2->meta->get_method('new');
$foo = Foo::Mouse2->new;
ok($foo_constructed, 'custom constructor called');
$foo_constructed = 0;
# still need to specify inline_constructor => 0 when overriding new manually
Foo::Mouse2->meta->make_immutable(inline_constructor => 0);
is($method->body, Foo::Mouse2->meta->get_method('new')->body,
   'make_immutable doesn\'t overwrite custom constructor');
$foo = Foo::Mouse2->new;
ok($foo_constructed, 'custom constructor called (immutable)');

done_testing;
