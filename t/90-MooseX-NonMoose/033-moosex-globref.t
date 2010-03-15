#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
BEGIN {
    eval "use MouseX::GlobRef ()";
    plan skip_all => "MouseX::GlobRef is required for this test" if $@;
    plan tests => 10;
}
# XXX: the way the IO modules are loaded means we can't just rely on cmop to
# load these properly/:
use IO::Handle;
use IO::File;

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
            metaclass_roles         => ['MouseX::Extend::Meta::Role::Class'],
            constructor_class_roles =>
                ['MouseX::Extend::Meta::Role::Constructor'],
            instance_metaclass_roles =>
                ['MouseX::GlobRef::Role::Meta::Instance'],
        );
    }
}

package IO::Handle::Mouse;
BEGIN { Foo::Exporter->import }
extends 'IO::Handle';

has bar => (
    is => 'rw',
    isa => 'Str',
);

sub FOREIGNBUILDARGS { return }

package IO::File::Mouse;
BEGIN { Foo::Exporter->import }
extends 'IO::File';

has baz => (
    is => 'rw',
    isa => 'Str',
);

sub FOREIGNBUILDARGS { return }

package main;
my $handle = IO::Handle::Mouse->new(bar => 'BAR');
is($handle->bar, 'BAR', 'moose accessor works properly');
$handle->bar('RAB');
is($handle->bar, 'RAB', 'moose accessor works properly (setting)');
IO::Handle::Mouse->meta->make_immutable;
$handle = IO::Handle::Mouse->new(bar => 'BAR');
is($handle->bar, 'BAR', 'moose accessor works properly');
$handle->bar('RAB');
is($handle->bar, 'RAB', 'moose accessor works properly (setting)');

SKIP: {
    my $fh = IO::File::Mouse->new(baz => 'BAZ');
    open $fh, "+>", undef
        or skip "couldn't open a temporary file", 3;
    is($fh->baz, 'BAZ', "accessor works");
    $fh->baz('ZAB');
    is($fh->baz, 'ZAB', "accessor works (writing)");
    $fh->print("foo\n");
    print $fh "bar\n";
    $fh->seek(0, 0);
    my $buf;
    $fh->read($buf, 8);
    is($buf, "foo\nbar\n", "filehandle still works as normal");
}
IO::File::Mouse->meta->make_immutable;
SKIP: {
    my $fh = IO::File::Mouse->new(baz => 'BAZ');
    open $fh, "+>", undef
        or skip "couldn't open a temporary file", 3;
    is($fh->baz, 'BAZ', "accessor works");
    $fh->baz('ZAB');
    is($fh->baz, 'ZAB', "accessor works (writing)");
    $fh->print("foo\n");
    print $fh "bar\n";
    $fh->seek(0, 0);
    my $buf;
    $fh->read($buf, 8);
    is($buf, "foo\nbar\n", "filehandle still works as normal");
}
