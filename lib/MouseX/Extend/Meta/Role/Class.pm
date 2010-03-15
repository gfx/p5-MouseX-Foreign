package MouseX::Extend::Meta::Role::Class;
use Mouse::Role;
use Mouse::Util::MetaRole;

has foreign_superclass => (
    is  => 'rw',
    isa => 'ClassName',

    lazy => 1,
    builder => '_build_foreign_superclass',
);

sub _build_foreign_superclass {
    my($meta) = @_;

    my @isa = $meta->linearized_isa;
    shift @isa; # discard this class
    foreach my $super(@isa) {
        if(my $foreign_super = $super->meta->can('foreign_superclass') && $super->meta->foreign_superclass){
            return $foreign_super;
        }
    }
    $meta->throw_error("You cannot refer foreign_superclass before it is given or inherited from superclasses");
}

around superclasses => sub {
    my $next = shift;
    my $meta = shift;

    return $meta->$next() unless @_;

    push @_, 'Mouse::Object' if !grep{ $_->isa('Mouse::Object') } @_;
    $meta->$next(@_);

    my $foreign_class = 0;

    foreach my $base(@_){
        if(!($base->can('meta') && $base->meta->isa('Mouse::Meta::Class'))){
            if(++$foreign_class > 1){
                $meta->throw_error("Multiple inheritance from foreign classes (@_) is not supported");
            }

            local $SIG{__WARN__} = sub{}; # XXX: avoid 'Prototype mismatch' warnings

            $meta = Mouse::Util::MetaRole::apply_metaroles(
                for => $meta,

                class_metaroles => {
                    constructor => ['MouseX::Extend::Meta::Role::Method::Constructor'],
                    destructor  => ['MouseX::Extend::Meta::Role::Method::Destructor'],
                }
            );

            $meta->foreign_superclass($base);

            # XXX: FIXME
            $meta->add_method(
                new => $meta->constructor_class->_generate_constructor($meta),
            );
            $meta->add_method(
                DESTROY => $meta->destructor_class->_generate_destructor($meta),
            );
        }
    }
};

no Mouse::Role;
1;
__END__

=head1 NAME

MouseX::Extend::Meta::Role::Class - The MouseX::Extend meta class role

=head1 VERSION

This document describes MouseX::Extend version 0.001.

=head1 DESCRIPTION

MouseX::Extend::Meta::Role::Class is the meta class role for MouseX::Extend.

=head1 SEE ALSO

L<MouseX::Extend>

=cut
