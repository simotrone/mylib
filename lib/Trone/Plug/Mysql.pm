package Trone::Plug::Mysql;

use strict;
use warnings;
use Carp;
use DBI;

sub new {
        my ($class, $input) = @_;

        croak "$class need `input' attribute" unless defined $input;

        # manage input attribute
        # input -> user:password@localhost/database
        my ($user, $passwd, $host, $dbname) =
                $input =~ m{^
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
                dbh => undef,
        }, $class;
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



1;
