package Trone::Links::Link;

use strict;
use warnings;
use Carp;
use List::MoreUtils qw/uniq firstval/;

sub new {
        my ($class,%attr) = @_;

        croak "$class need `href' attribute." unless $attr{href};

        my $self = bless {
                _href  => $attr{href},
                _title => undef,
                _tags  => [],
        }, $class;

        $self->title($attr{title})  if $attr{title};
        $self->tags(@{$attr{tags}}) if $attr{tags};
        return $self;
}

sub href {
        my ($self, $href) = @_;
        return $self->{_href} unless defined $href;
        $self->{_href} = $href;
        return $self;
}

sub title {
        my ($self, $title) = @_;
        return $self->{_title} unless defined $title;
        $self->{_title} = $title;
        return $self;
}

sub tags {
        my ($self, @tags) = @_;
        return @{$self->{_tags}} unless @tags;

        # push in tags every word passed as argument (also splitting
        # blank spaced argument)
        push @{$self->{_tags}}, map { split /\s+/,$_ } @tags;

        @{$self->{_tags}} = uniq @{$self->{_tags}};
        return $self;
}

sub has_tag {
        my ($self, $tag) = @_;
        return 0 unless defined $tag;
        return (firstval {$_ eq $tag} $self->tags) ? 1 : 0;
}

1;
__END__
=head1 NAME

Link - manage link object

=head1 SYNOPSIS

  use Link;

  my $link = Link->new(
    href  => 'http://www.example.com',
    title => 'Example domain',
    tags  => ['example','website']
  );
  
  my $href  = $link->href;               # http://www.example.com
  my $title = $link->title;              # Example domain
  my @tags  = $link->tags;               # example, website

  $link->has_tag('blog');                # 0
  $link->tags('blog')->has_tag('blog');  # 1

=head1 ATTRIBUTES

L<Link> has three attributes to define the object.

=over 4

=item $link->href 

=item $link->href('http://my.new.domain.com');

=item $link->title 

=item $link->title('My new title')

Set attribute if argument are passed (returning object ref),
or return Link's href/title.

=item $link->tags
=item $link->tags(qw/one two three/,'four five')

Return all the Link's tags as array when no arguments are specified.

If one (or more) parameter is passed add it to pre-existing Link's
tags without duplicate word already in.

Just single word (ie: no blank space in) is valid as tag.

=back

=head1 METHODS

L<Link> has two methods.

=over 4

=item Link->new(href => 'http://my.domain.com')

Create a new Link object.
C<href> parameter is mandatory.

The constructor can accept also C<title> (scalar) and
C<tags> (array ref) parameters.

=item $link->has_tag($something)

The method return 1 if $something is a Link's tag, 0 otherwise.

=cut

