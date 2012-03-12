package Trone::Quotes::Source::Mysql;

use strict;
use warnings;
use Carp;
use DBI;
use Trone::Quotes::Quote;

sub new {
        my ($class, %attr) = @_;

        croak "$class need `input0 attribute" unless defined $attr{input};

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

        bless {
		credentials => {
                        host   => $host   || 'localhost',
			dbname => $dbname || undef,
			dbuser => $user   || $ENV{USER} || undef,
			dbpass => $passwd || undef,
		},
                dbh    => undef,
                quotes => undef,
        }, $class;
}

sub clean {
        my $self = shift;
        $self->{quotes} = undef;
        return $self;
}

sub quotes {
        my $self = shift;
        $self->fetch() unless defined $self->{quotes} and scalar @{$self->{quotes}};
        return @{$self->{quotes}};
}

sub dbh {
        my $self = shift;

        return $self->{dbh} //= do {
		my $credentials   = $self->{credentials};

                my $db_name = $credentials->{dbname};
                my $db_user = $credentials->{dbuser};
                my $db_pass = $credentials->{dbpass};

                my $data_src      = "dbi:mysql:$db_name";
                my $attr     	  = { RaiseError => 1, AutoCommit => 0 };

                DBI->connect($data_src, $db_user, $db_pass, $attr)
                        or die $DBI::errstr;
        };
}

sub fetch {
        my $self = shift;
        
        my $sth = $self->dbh->prepare("SELECT author,text FROM quotes")
                or die $DBI::errstr;
        $sth->execute or die $DBI::errstr;

        while (my $r = $sth->fetchrow_hashref) {
                my $q = Trone::Quotes::Quote->new(text => $r->{text});
                $q->author($r->{author}) if defined $r->{author};

                push @{$self->{quotes}}, $q;
        }

        $self->dbh->disconnect;
        return $self;
}

1;
