#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
BEGIN {
    eval "use MouseX::InsideOut ()";
    plan skip_all => "MouseX::InsideOut is required for this test" if $@;
    plan tests => 10;
}

BEGIN {
    require Mouse;

    package Foo::Exporter;
    use Mouse::Exporter;
    Mouse::Exporter->setup_import_methods(also => ['Mouse']);

    sub init_meta {
        shift;
        my %options = @_;
        Mouse->init_meta(%options);
        return Mouse::Util::MetaRole::apply_metaclass_roles(
            for_class               => $options{for_class},
            metaclass_roles         => ['MouseX::Foreign::Meta::Role::Class'],
            constructor_class_roles =>
                ['MouseX::Foreign::Meta::Role::Constructor'],
            instance_metaclass_roles =>
                ['MouseX::InsideOut::Role::Meta::Instance'],
        );
    }
}

package Foo;

sub new {
    my $class = shift;
    bless [$_[0]], $class;
}

sub foo {
    my $self = shift;
    $self->[0] = shift if @_;
    $self->[0];
}

package Foo::Mouse;
BEGIN { Foo::Exporter->import }
extends 'Foo';

has bar => (
    is => 'rw',
    isa => 'Str',
);

sub BUILDARGS {
    my $self = shift;
    shift;
    return $self->SUPER::BUILDARGS(@_);
}

package Foo::Mouse::Sub;
use base 'Foo::Mouse';

package main;
my $foo = Foo::Mouse->new('FOO', bar => 'BAR');
is($foo->foo, 'FOO', 'base class accessor works');
is($foo->bar, 'BAR', 'subclass accessor works');
$foo->foo('OOF');
$foo->bar('RAB');
is($foo->foo, 'OOF', 'base class accessor works (setting)');
is($foo->bar, 'RAB', 'subclass accessor works (setting)');
TODO: {
    local $TODO = "nonmoose-moose-nonmoose extending doesn't currently work";
    my $sub_foo = eval { Foo::Mouse::Sub->new(FOO => bar => 'AHOY') };
    is(eval { $sub_foo->bar }, 'AHOY', 'subclass constructor works');
}
Foo::Mouse->meta->make_immutable;
$foo = Foo::Mouse->new('FOO', bar => 'BAR');
is($foo->foo, 'FOO', 'base class accessor works (immutable)');
is($foo->bar, 'BAR', 'subclass accessor works (immutable)');
$foo->foo('OOF');
$foo->bar('RAB');
is($foo->foo, 'OOF', 'base class accessor works (setting) (immutable)');
is($foo->bar, 'RAB', 'subclass accessor works (setting) (immutable)');
TODO: {
    local $TODO = "nonmoose-moose-nonmoose extending doesn't currently work";
    my $sub_foo = eval { Foo::Mouse::Sub->new(FOO => bar => 'AHOY') };
    is(eval { $sub_foo->bar }, 'AHOY', 'subclass constructor works (immutable)');
}
