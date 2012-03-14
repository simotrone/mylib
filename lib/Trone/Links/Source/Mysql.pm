package Trone::Links::Source::Mysql;

use strict;
use warnings;
use Carp;
use base 'Trone::Links::Source::Base';
use Trone::Links::Link;
use Trone::Plug::Mysql;

sub new {
        my ($class, %attr) = @_;

        croak "$class need `input' attribute" unless defined $attr{input};

        my $self = $class->SUPER::new();
        $self->{dbh} = Trone::Plug::Mysql->new($attr{input})->dbh;

        return $self;
}

sub read { shift->fetch() }
sub dbh  { shift->{dbh} }

sub fetch {
        my $self = shift;

        my $sth = $self->dbh->prepare("SELECT href,title,tags FROM links")
                or die $DBI::errstr;
        $sth->execute or die $DBI::errstr;

        $self->clean;
        
        while (my $r = $sth->fetchrow_hashref) {
                my @tags = split /,/, lc $r->{tags};

                my $l = Trone::Links::Link->new(
                        href  => $r->{href},
                        title => $r->{title},
                        tags  => [@tags],
                );

                push @{$self->{links}}, $l;
        }

        $self->dbh->disconnect;
        return $self;
}

1;
