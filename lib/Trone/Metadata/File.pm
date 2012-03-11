package Trone::Metadata::File;

use strict;
use warnings;
use Carp;
use File::Spec;
use File::stat;
use File::Basename;
use Cwd qw/abs_path/;

sub new {
        my ($class, %attr) = @_;

        croak "$class need `input' attribute"          unless defined $attr{input};
        croak "$class attribute `input' must to exist" unless -f $attr{input};

        my $fn = File::Spec->file_name_is_absolute($attr{input}) ? $attr{input} : File::Spec->rel2abs($attr{input});
        $fn = abs_path($fn);

        my ($bn, undef, $ext) = fileparse($fn, qr/\..*?$/);
        $ext =~ s/\.//;

        bless {
                file     => $fn,
                basename => $bn,
                ext      => $ext,
                cached => {
                        mtime => undef,
                        size  => undef,
                }
        }, $class;
}

sub file     { shift->{file} }

sub basename { shift->{basename} }
sub ext      { shift->{ext} }

sub mtime {
        my $self = shift;
        return $self->{cached}->{mtime} //= do { stat($self->file)->mtime };
}

sub size {
        my $self = shift;
        return $self->{cached}->{size} //= do { stat($self->file)->size };
}

1;
