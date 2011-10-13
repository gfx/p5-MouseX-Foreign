package MouseX::NonMoose::Meta::Role::Method::Destructor;
use Mouse::Role;

around _generate_destructor => sub {
    my($next, undef, $meta) = @_;

    my $foreign_superclass = $meta->foreign_superclass;

    my $super_destroy;
    if(!$foreign_superclass->can('DEMOLISHALL')){
        $super_destroy = $foreign_superclass->can('DESTROY');
    }

    return sub {
        my($self) = @_;
        $self->DEMOLISHALL();

        if(defined $super_destroy) {
            $self->$super_destroy();
        }
        return;
    };
};

no Mouse::Role;
1;
