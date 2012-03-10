package Trone::Plug::Mysql;

use strict;
use warnings;
use DBI;
use Carp;

sub new {
        my ($class,%attr) = @_;

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

        bless {
		credentials => {
                        host   => $host   || 'localhost',
			dbname => $dbname || undef,
			dbuser => $user   || $ENV{USER} || undef,
			dbpass => $passwd || undef,
		},
                table   => $attr{table}  || undef,
                fields  => $attr{fields} || [],
                dbh     => undef,
                results => undef,
        }, $class;
}

sub results {
        my $self = shift;
        $self->fetch() unless $self->{results};
        return @{$self->{results}};
}

sub dbh {
        my $self = shift;

        return $self->{dbh} //= do {
		my $credentials   = $self->{credentials};

                my $database_name = $credentials->{dbname};
                my $username 	  = $credentials->{dbuser};
                my $password 	  = $credentials->{dbpass};

                my $data_src      = "dbi:mysql:$database_name";
                my $attr     	  = { RaiseError => 1, AutoCommit => 0 };

                DBI->connect($data_src, $username, $password, $attr)
                        or die $DBI::errstr;
        };
}

sub fetch {
        my $self = shift;
        
        my @fields = @{$self->{fields}};
        my $table  = $self->{table};
        return $self unless scalar @fields;
        return $self unless $table;

        my $fields = join ', ', @fields;
        my $sth = $self->dbh->prepare("SELECT $fields FROM $table")
                or die $DBI::errstr;
        $sth->execute or die $DBI::errstr;

        while (my $r = $sth->fetchrow_hashref) {
                push @{$self->{results}}, $r;
        }

        $self->dbh->disconnect;
        return $self;
}


1;
