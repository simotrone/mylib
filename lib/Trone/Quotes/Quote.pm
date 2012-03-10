package Trone::Quotes::Quote;

use strict;
use warnings;

sub new {
        my ($class, %attr) = @_;

        bless {
                _author => $attr{author} || 'Anonymous',
                _text   => $attr{text}   || '',
        }, $class;
}

sub author {
        my ($self, $author) = @_;
        return $self->{_author} unless defined $author;
        $self->{_author} = $author;
        return $self;
}

sub text {
        my ($self, $text) = @_;
        return $self->{_text} unless defined $text;;
        $self->{_text} = $text;
        return $self;
}

1;
__END__
# my $q = Quote->new(author => 'name', text => 'blablabla');
# $q->author;
# $q->text;

=head1 QUOTE METHODS

=over 4

=item $quote = $quote->author('new author');

=item $author = $quote->author

Setter and getter to manage the citation author.
The setter return the object instance; the getter return the value.

=item $quote = $quote->text('new citation');

=item $text = $quote->text

Setter and getter to manage the citation.
The setter return the object instance; the getter return the value.

=back

=cut
