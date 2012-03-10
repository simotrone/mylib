package Trone::Plug::Fs;

use strict;
use warnings;
use Carp;
use IO::File;

sub new {
        my ($class, %attr) = @_;

        croak "$class need `input' attribute" unless defined $attr{input};
        croak "$class attribute `input' have to exist" unless -f $attr{input};

        bless {
                file      => $attr{input},
                separator => $attr{separator} || $/,
        }, $class;
}

sub file      { shift->{file} };
sub separator { shift->{separator} };

sub read {
        my $self = shift;

        local $/ = $self->separator;

        my $fh = IO::File->new($self->file, 'r');
        croak "Can't read file ".$self->file unless defined $fh;

        $fh->binmode('utf8');

        my @rows = $fh->getlines;

        $fh->close;

        return @rows;
}


1;
