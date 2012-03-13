package Trone::Quotes::Source::Base;

use strict;
use warnings;
use Carp;

sub new {
        my $class = shift;
        bless {
                quotes => undef,
        }, $class;
}

sub clean {
        my $self = shift;
        $self->{quotes} = undef;
        return $self;
}

sub quotes {
        my $self = shift;
        $self->read unless defined $self->{quotes} and scalar @{$self->{quotes}};
        return @{$self->{quotes}};
}

sub read { croak "Method `read' not implemented in subclass ". caller }

1;
