package Trone::Links::Source::File;

use strict;
use warnings;
use Carp;
use IO::File;
use base 'Trone::Links::Source::Base';
use Trone::Links::Link;

sub new {
        my ($class, %attr) = @_;

        croak "$class need `input' attribute" unless defined $attr{input};
        croak "$class attribute `input' have to exist" unless -f $attr{input};

        my $self = $class->SUPER::new();
        $self->{file} = $attr{input};
        return $self;
}

sub file { shift->{file} }

sub read {
        my $self = shift;

        my $fh = IO::File->new($self->file, 'r');
        croak "Can't read file ".$self->file unless defined $fh;

        $fh->binmode('utf8');

        $self->clean;

        my $re = qr{https?://[^\s]+};

        for ($fh->getlines) {
                next unless m/$re/;
                # avoid rows without `$re' in.

                chomp;

                # tag0,tag1 http://my.example.domain/path/to/res Title of Resource
                my ($tags, $href, $title) = m/^
                        ([^\s]*)        # tags
                                (?:\s+)?
                        ($re)           # http
                                (?:\s+)?
                        (.*)            # title
                $/x;
                
                my @tags = split /,/, lc $tags;

                my $l = Trone::Links::Link->new(
                        href => $href, title => $title, tags => [@tags]
                );

                push @{$self->{links}}, $l;
        }

        $fh->close;
        return $self;
}

1;
