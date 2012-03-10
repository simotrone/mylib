use Test::More;
use Test::Exception;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;

use_ok('Trone::Plug');

throws_ok { my $plug = Trone::Plug->new() } qr/need `source' attribute/,
        "Constructor fail. Need `source' attribute";
throws_ok { my $plug = Trone::Plug->new(source => 'pippo://something') } qr/need `type' attribute/,
        "Constructor fail. Need `type' attribute";

#
# testing links.txt
my $plug_file_links = Trone::Plug->new(
        source => "$FindBin::Bin/extra/links.txt",
        type   => 'file',
);
isa_ok($plug_file_links, 'Trone::Plug');
#diag Dumper $plug_file;

isa_ok($plug_file_links->factory, 'Trone::Plug::Fs');
#diag Dumper [$plug_file->factory->read];


#
# testing quotes.txt
my $plug_file_quotes = Trone::Plug->new(
        source => "$FindBin::Bin/extra/quotes.txt",
        type   => 'file',
        separator => "\n\n",
);
isa_ok($plug_file_quotes,          'Trone::Plug');
isa_ok($plug_file_quotes->factory, 'Trone::Plug::Fs');
diag Dumper [$plug_file_quotes->factory->read];

#
# testing Mysql
# quotes
my $plug_mysql_quotes = Trone::Plug->new(
        source => 'sim@localhost/test',
        type   => 'mysql',
        table  => 'quotes',
        fields => [qw/author text/],
);
isa_ok($plug_mysql_quotes,'Trone::Plug');
isa_ok($plug_mysql_quotes->factory, 'Trone::Plug::Mysql');
#diag Dumper $plug_mysql_quotes->factory;
diag Dumper [$plug_mysql_quotes->factory->results];

# links
my $plug_mysql_links = Trone::Plug->new(
        source => 'sim@localhost/test',
        type   => 'mysql',
        table  => 'links',
        fields => [qw/href tags title/],
);
isa_ok($plug_mysql_links,'Trone::Plug');
isa_ok($plug_mysql_links->factory, 'Trone::Plug::Mysql');
#diag Dumper $plug_mysql_quotes->factory;
diag Dumper [$plug_mysql_links->factory->results];

done_testing();
