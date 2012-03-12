package Trone::Quotes::Source::File;

use strict;
use warnings;
use Carp;
use IO::File;
use Trone::Quotes::Quote;

sub new {
        my ($class, %attr) = @_;

        croak "$class need `input' attribute" unless defined $attr{input};
        croak "$class attribute `input' have to exist" unless -f $attr{input};

        bless {
                file   => $attr{input},
                quotes => undef,
        }, $class;
}

sub file  { shift->{file} }
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

sub read {
        my $self = shift;

        local $/ = "\n\n";

        my $fh = IO::File->new($self->file, 'r');
        croak "Can't read file ".$self->file unless defined $fh;

        $fh->binmode('utf8');

        $self->clean;

        for my $record ($fh->getlines) {
                my ($author, $text) = split /\n/, $record, 2;

                unless (defined $text) {
                        $text = $author;
                        undef $author;
                }
                $text =~ s/[\n]+$//;

                next unless defined $text;

                my $q = Trone::Quotes::Quote->new(text => $text);
                $q->author($author) if defined $author;

                push @{$self->{quotes}}, $q;
        }

        $fh->close;
        return $self;
}

1;
