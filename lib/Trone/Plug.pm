package Trone::Plug;

use strict;
use warnings;
use Carp;

use Trone::Plug::Fs;
use Trone::Plug::Mysql;

# Plug namespace ?
my $types = {
        'file'  => 'Trone::Plug::Fs',
        'mysql' => 'Trone::Plug::Mysql',
};

sub new {
        my ($class,%attr) = @_;

        my $source = delete $attr{source};
        my $type   = delete $attr{type};
        
        croak "$class need `source' attribute" unless $source;
        croak "$class need `type' attribute"   unless $type;

        my $plug = $types->{$type};
        croak "`$type' type isn't valid."      unless $plug;

        my %opts = %attr;

        bless {
                factory => sub { $plug->new(%opts, input => $source) },
        }, $class;
}

sub factory { shift->{factory}->() };



1;

__END__
=head1 NAME

Trone::Plug - Interface to many extract Plugins

=head1 SYNOPSIS

        my $plug = Trone::Plug->new(
            source => '/path/to/my/file',
            type   => 'file',
        );

        # or

        my $plug = Trone::Plug->new(
            source => 'user:pass@localhost/dbname',
            type   => 'mysql',
        );

        # After is possible manipulate a Plug::* instance

        $plug->factory->...


=head1 METHODS

=over 4

=item $plug = Trone::Plug->new();

=item $plug->factory()

=back
