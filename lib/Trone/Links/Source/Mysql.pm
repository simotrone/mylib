package Trone::Links::Source::Mysql;

use strict;
use warnings;
use Carp;
use DBI;
use base 'Trone::Links::Source::Base';
use Trone::Links::Link;

sub new {
        my ($class, %attr) = @_;

        croak "$class need `input' attribute" unless defined $attr{input};

        # manage input attribute
        # input -> user:password@localhost/database
        my ($user, $passwd, $host, $dbname) =
                $attr{input} =~ m{^
                        ([^:]*)           # "username"
                        (?:               # don't group
                            :             # :
                            ([^@]*)       # "password"
                        )?                # optional
                        \@                # @
                        (localhost|[^/]*) # "host_name"
                        /                 # /
                        ([a-zA-Z0-9]*)    # "database_name"
                        $}x;

        my $self = $class->SUPER::new();

        $self->{credentials} = {
                host   => $host   || 'localhost',
                dbname => $dbname || undef,
                dbuser => $user   || $ENV{USER} || undef,
                dbpass => $passwd || undef,
        };
        return $self;
}

sub read { shift->fetch() }

sub dbh {
        my $self = shift;

        return $self->{dbh} //= do {
		my $credentials   = $self->{credentials};

                my $db_name = $credentials->{dbname};
                my $db_user = $credentials->{dbuser};
                my $db_pass = $credentials->{dbpass};

                my $data_src = "dbi:mysql:$db_name";
                my $attr     = { RaiseError => 1, AutoCommit => 0 };

                DBI->connect($data_src, $db_user, $db_pass, $attr)
                        or die $DBI::errstr;
        };
}

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
