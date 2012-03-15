package Trone::Plug;

use strict;
use warnings;
use v5.014;    # non-destructive substitution
use Carp;

sub new {
        my ($class,%attr) = @_;

        my $source = delete $attr{source};
        my $driver = delete $attr{driver};
        
        croak "$class need `source' attribute" unless $source;
        croak "$class need `driver' attribute" unless $driver;

        # Load DRIVER at runtime
        croak "Problem loading $driver - $@" unless eval {
                my $pkg = "$driver.pm" =~ s{::}{/}gr;   # 5.14.0
                require $pkg;
                $driver->import() if defined &{"${driver}::import"};
                1;
        };

        bless {
                factory => sub { $driver->new(input => $source) },
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
            driver => 'My::Driver',
        );

        # or

        my $plug = Trone::Plug->new(
            source => 'user:pass@localhost/dbname',
            type   => 'My::DB::Driver',
        );

        # After is possible manipulate a Plug::* instance

        $plug->factory->...


=head1 METHODS

=over 4

=item $plug = Trone::Plug->new();

=item $plug->factory()

=back
