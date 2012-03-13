package Trone::Links::Source::Base;

use strict;
use warnings;
use Carp;

sub new {
        my $class = shift;
        bless { links => undef }, $class;
}

sub clean {
        my $self = shift;
        $self->{links} = undef;
        return $self;
}

sub links {
        my $self = shift;
        $self->read unless defined $self->{links} and scalar @{$self->{links}};
        return @{$self->{links}};
}

sub read { croak "Method `read' not implemented in subclass ". caller }

1;
