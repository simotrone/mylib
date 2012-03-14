package Trone::Quotes::Source::Mysql;

use strict;
use warnings;
use Carp;
use base 'Trone::Quotes::Source::Base';
use Trone::Quotes::Quote;
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

        my $sth = $self->dbh->prepare("SELECT author,text FROM quotes")
                or die $DBI::errstr;
        $sth->execute or die $DBI::errstr;

        $self->clean;
        
        while (my $r = $sth->fetchrow_hashref) {
                my $q = Trone::Quotes::Quote->new(text => $r->{text});
                $q->author($r->{author}) if defined $r->{author};

                push @{$self->{quotes}}, $q;
        }

        $self->dbh->disconnect;
        return $self;
}

1;
