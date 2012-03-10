use Test::More;
use Test::Exception;
use Data::Dumper;
use FindBin;
use lib "$FindBin::Bin/../lib";

BEGIN { use_ok('Trone::Plug::Mysql'); }

throws_ok { my $my = Trone::Plug::Mysql->new() } qr/need `input' attribute/,
        "Constructor fail. Need `input' attribute";


my $myQuotes = Trone::Plug::Mysql->new(
        input  => 'sim:@localhost/test',
        fields => [qw/author text/],
        table  => 'quotes',
);
isa_ok($myQuotes,'Trone::Plug::Mysql');

diag Dumper $myQuotes->fetch;

my $myLinks = Trone::Plug::Mysql->new(
        input  => 'sim:@localhost/test',
        fields => [qw/href title tags/],
        table  => 'links',
);
isa_ok($myLinks,'Trone::Plug::Mysql');

diag Dumper $myLinks->fetch;

done_testing();
