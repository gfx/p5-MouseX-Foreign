package MouseX::Extend::Meta::Role::Method::Constructor;
use Mouse::Role;

around _generate_constructor => sub {
    my($next, $class, $meta, $option) = @_;

    my $super_new = $meta->foreign_superclass->can('new')
        or $meta->throw_erorr($meta->foreign_superclass . " has no constructor");

    my $foreign_buildargs = $meta->name->can('FOREIGNBUILDARGS');
    my $need_buildall     = !$meta->foreign_superclass->can('BUILDALL');

    return sub {
        my $class = shift;
        my $instance;

        if($foreign_buildargs){
            $instance = $class->$super_new($class->$foreign_buildargs(@_));
        }
        else{
            $instance = $class->$super_new(@_);
        }

        my $args = $class->BUILDARGS(@_);
        $instance->meta->_initialize_object($instance, $args);

        $instance->BUILDALL($args) if $need_buildall;

        return $instance;
    };
};

no Mouse::Role;
1;
__END__

=head1 NAME

MouseX::Extend::Meta::Role::Method::Constructor - The MouseX::Extend meta method constructor role

=head1 VERSION

This document describes MouseX::Extend version 0.001.

=head1 DESCRIPTION

MouseX::Extend::Meta::Role::Method::Constructor is the meta method constructor role for MouseX::Extend.

=head1 SEE ALSO

L<MouseX::Extend>

=cut
