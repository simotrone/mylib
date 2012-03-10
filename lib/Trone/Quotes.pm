package Trone::Quotes;

use strict;
use warnings;
use v5.10;
use Carp;
use Trone::Quotes::Quote;
use Trone::Plug;

sub new {
        my ($class, %attr) = @_;

        croak "$class constructor need `input' attribute." unless $attr{input};

        bless {
                input   => $attr{input},
                cached  => {
                        quotes => [],
                },
                _source => undef,
                _type   => undef,
        }, $class;
}

sub input { shift->{input} }

sub list {
        my $self = shift;
        my $quotes = $self->{cached}->{quotes};
        $self->_read() unless scalar @$quotes;
        return @$quotes;
}

sub dump {
        my @arr;
        push @arr, {author => $_->author, text => $_->text} for shift->list;
        return \@arr;
}

sub _type {
        my ($self, $val) = @_;
        return $self->{_type} unless $val;
        $self->{_type} = $val;
        return $self;
}
sub _source {
        my ($self, $val) = @_;
        return $self->{_source} unless $val;
        $self->{_source} = $val;
        return $self;
}

sub _clean {
        my $self = shift;
        @{$self->{cached}->{quotes}} = ();
        return $self;
}

sub _read {
        my $self = shift;

        # file://path/to/file
        # mysql://user:pass@localhost/database

        my ($type, $source) = split /:\/\//, $self->input, 2;
        $self->_type($type);
        $self->_source($source);

        # Could be nice a sort of $self->_read_"$type" ...
        given ($type) {
                when (/file/)  { $self->_read_file() }
                when (/mysql/) { $self->_read_mysql() }
        }

        return $self;
}

sub _read_file {
        my $self = shift;

        $self->_clean();

        my @records = Trone::Plug->new(
                source    => $self->_source,
                type      => $self->_type,
                separator => "\n\n",
        )->factory->read;

        foreach (@records) {
                my ($author,$text) = split(/\n/, $_, 2);
                $text =~ s/[\n]+$//;

                my $quote = Trone::Quotes::Quote->new(
                        author => $author,
                        text   => $text
                );
                push @{$self->{cached}->{quotes}}, $quote;
        }

        return $self;
}

sub _read_mysql {
        my $self = shift;

        $self->_clean();

        my @records = Trone::Plug->new(
                source => $self->_source,
                type   => $self->_type,
                table  => 'quotes',
                fields => [qw/author text/],
        )->factory->results();

        foreach (@records) {
                my $quote = Trone::Quotes::Quote->new(
                        author => $_->{author},
                        text   => $_->{text}
                );
                push @{$self->{cached}->{quotes}}, $quote;
        }

        return $self;
}

1;
__END__
=head1 NAME

QUOTES - Manage and show Quote objects

=head1 SYNOPSIS

        # $quotes is a Quotes object
        my $quotes = Quotes->new(input => 'file_name');
        my @quotes = $quotes->list;

        # $quote is a Quote object
        foreach my $quote (@quotes) {
                my $author = $quote->author;
                my $text   = $quote->text;
        }

        my $quote = Quote->new();
        $quote->author('my favourite author')->text('my favourite citation');

=head1 DESCRIPTION

The Quotes object manage quotes in a simple text file following this scheme:

        author
        quote text

        second author
        another quote text

        etc.

=head1 CONSTRUCTORS

=over 4

=item $quotes = Quotes->new(input => 'file_name');

The constructor return a Quotes object. It needs a filename to parse and get data.
The source text file format is described in DESCRIPTION section.

The Quotes object is empty until list method is fired up.

=item $quote = Quote->new(author => 'the author', text => 'the quote');

The constructor return a Quote object.

If author is not given, 'Anonymous' is registered.

=back

=head1 QUOTES METHODS

=over 4

=item @quotes = $quotes->list

The list method trigger the source file reading and return an array composed by
Quote objects.

=back

