package Trone::Quotes;

use strict;
use warnings;
use Carp;
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
                _driver => undef,
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

sub _driver {
        my ($self, $val) = @_;
        return $self->{_driver} unless $val;
        $self->{_driver} = $val;
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
        $self->_source($source);

        my $caller = caller;
        my $uctype = ucfirst $type;
        # create Trone::Quotes::Source::*
        $self->_driver("${caller}::Source::$uctype");

        $self->_clean();

        my $plug = Trone::Plug->new(
                source => $self->_source,
                driver => $self->_driver,
        );

        # $plug->factory->quotes method returns quotes (for each source plugin).
        @{$self->{cached}->{quotes}} = map { $_ } $plug->factory->quotes;

        return $self;
}

1;
__END__
=head1 NAME

QUOTES - Manage and show Quote objects

=head1 SYNOPSIS

        # $quotes is a Quotes object
        my $quotes = Quotes->new(input => 'file://file_name');
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

=item $quotes = Quotes->new(input => 'file://file_name');

The constructor return a Quotes object. It needs a filename to parse and get data.
The source text file format is described in DESCRIPTION section.

The Quotes object is empty until list method is fired up.

=item $quote = Quote->new(author => 'the author', text => 'the quote');

The constructor return a Quote object.

If author is not given, 'Anonymous' is registered.

=back

=head1 QUOTES ATTRIBUTE

=over 4

=item $str = $quotes->input

Return the `input' attribute. It's just a getter.

=back

=head1 QUOTES METHODS

=over 4

=item @quotes = $quotes->list()

The list method trigger the source file reading and returns an array composed by
Quote objects.

=item $arr_ref = $quotes->dump()

dump() returns data as array reference.

This can be useful if caller want simple Perl data struct instead Quote object.

        [
          {
            author => "author one",
            text   => "text one",
          },
          { ... }
        ]

=back

