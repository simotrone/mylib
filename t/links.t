use Test::More;
use Test::Exception;
use FindBin;
use lib "$FindBin::Bin/../lib";

BEGIN { use_ok('Trone::Links'); }

# constructor fail
throws_ok { my $no_l = Trone::Links->new() } qr/constructor need `input' attribute/,
        "Constructor fail. Need `input' attribute";

# constructor
my $links = Trone::Links->new(input => "file://$FindBin::Bin/extra/links.txt");
isa_ok($links,'Trone::Links');

# list
throws_ok { my $no_l = Trone::Links->new(input => "file://$FindBin::Bin/extra/not_readable.txt")->list } qr/Can't read file/,
        "list() access fails because file isn't readable";

is($links->list, 4, 'list() access works. 4 items');
isa_ok($_,'Trone::Links::Link') for $links->list;

# tags
is($links->tags, 3, 'tags() access works');
diag(join ", ", $links->tags);

# by_tag
is($links->by_tag(),       0, "by_tag() without arguments don't select links items");
is($links->by_tag('tag0'), 2, 'by_tag() select link given the right tag arg');



# mysql data
my $links_my = Trone::Links->new(input => 'mysql://sim@localhost/test');
is($links_my->list, 1, 'list() works. 1 item');
is($links_my->tags, 2, 'tags() works, 2 items');
diag(join ", ", $links_my->tags);

is($links_my->by_tag('engine'), 1, 'by_tag() select one link with the right tag arg');

done_testing();
