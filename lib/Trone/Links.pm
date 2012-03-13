package Trone::Links;

use strict;
use warnings;
use v5.10;
use Carp;
use List::MoreUtils qw/uniq/;
use Trone::Plug;

sub new {
        my ($class, %attr) = @_;

        croak "$class constructor need `input' attribute." unless $attr{input};

        bless {
                input  => $attr{input},
                cached => {
                        links  => [],
                        tags   => [],
                },
                _source => undef,
                _driver => undef,
        }, $class;
}

sub input { shift->{input} }

sub list {
        my $self  = shift;
        my $links = $self->{cached}->{links};
        $self->_read unless scalar @$links;
        return @$links;
}

sub tags {
        my $self = shift;
        my $tags = $self->{cached}->{tags};
        $self->_get_tags unless scalar @$tags;
        return @$tags;
}

sub by_tag {
        my ($self, $tag) = @_;
        grep { $_->has_tag($tag) } $self->list;
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

# selective clean cache?
sub _clean {
        my $self = shift;
        @{$self->{cached}->{links}} = ();
        @{$self->{cached}->{tags}}  = ();
        return $self;
}

sub _read {
        my $self = shift;

        # file://path/to/file
        # mysql://user:pass@localhost/database

        my ($type, $source) = split /:\/\//, $self->input, 2;
        $self->_source($source);
        $self->_driver(caller ."::Source::". ucfirst $type);

        $self->_clean();

        my $plug = Trone::Plug->new(
                source => $self->_source,
                driver => $self->_driver,
        );

        @{$self->{cached}->{links}} = map { $_ } $plug->factory->links;

        return $self;
}

sub _get_tags {
        my $self = shift;
        my $tags = $self->{cached}->{tags};
        push @$tags, $_->tags for $self->list;
        @$tags = uniq @$tags;
        return $self;
}

1;
#
=head1 NAME

Links - manage links object

=head1 SYNOPSIS

  use Links;

  my $links = Links->new(input => 'path/to/file.txt');

  my @links    = $links->list;          # array of Link objects
  my @tags     = $links->tags;          # array of tags
  my @selected = $links->by_tag('blog') # array of Link objects with 'blog' tag.

  $links->clean                         # clean cached links and tags


=head1 DESCRIPTION

=head2 STORAGE FILE

The file pointed by input attribute need to be formatted as follow.

Every row is a single record and there are at most three fields separated with
blank space. Fields are:

  TAGS HYPERLINK TITLE

TAGS is an optional string composed by single words comma separated (eg: web,blog).
HYPERLINK is a single word starting with http:// or https:// (this is mandatory).
TITLE is an optional field, and cover all what is after HYPERLINK.

  tag0,tag1 http://my.link.to.something Title or description about link
  http://only.one.record
  http://with.title My title is here
  tag http://with.out.title

The file need at least C<http://> field per row; if there isn't, the row is a
comment. (It is possibile use empty line to separate different type of records.)


=head1 METHODS

=over 4

=item Link->new(input => 'file.txt')

Create a new Links object.
C<input> parameter is mandatory: it must to set to a readable file.

=item $links->list

The method return an array of Link objects.

=item $links->tags

Return the full array of tags got from all the Link objects' tag. No duplicated.

=item $links->by_tag($something)

Return an array of Link objects with $something tag.

=item $links->clean

The Links object cache actively links and tag after first calls with C<list()> or
C<tags()> methods.

Furthermore, can to be useful to clean the cache, and C<clean()> method is here for.

=back

=cut



