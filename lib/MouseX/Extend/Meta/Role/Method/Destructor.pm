package MouseX::Extend::Meta::Role::Method::Destructor;
use Mouse::Role;

around _generate_destructor => sub {
    my($next, $class, $meta) = @_;

    my $super_destroy;
    if(!$meta->foreign_superclass->can('DEMOLISHALL')){
        $super_destroy = $meta->foreign_superclass->can('DESTROY');
    }

    return sub {
        my($self) = @_;
        $self->DEMOLISHALL();

        if($super_destroy){
            $self->$super_destroy();
        }
        return;
    };
};

no Mouse::Role;
1;
__END__

=head1 NAME

MouseX::Extend::Meta::Role::Method::Destructor - The MouseX::Extend meta method destructor role

=head1 VERSION

This document describes MouseX::Extend version 0.001.

=head1 DESCRIPTION

MouseX::Extend::Meta::Role::Method::Destructor is the meta method destructor role for MouseX::Extend.

=head1 SEE ALSO

L<MouseX::Extend>

=cut
