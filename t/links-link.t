use Test::More;
use Test::Exception;
use FindBin;
use lib "$FindBin::Bin/../lib";

BEGIN { use_ok('Trone::Links::Link'); }

# constructor fail
throws_ok { my $l0 = Trone::Links::Link->new() } qr/need `href' attribute/, "Constructor fail. Need `href' attribute";
ok(my $l1 = Trone::Links::Link->new(href => 'http://www.minimal.com'), 'Minimal construction.');

# constructor
my $link = Trone::Links::Link->new(
        href  => 'http://www.example.com',
        title => 'My title',
        tags  => ['one']
);
isa_ok($link,'Trone::Links::Link');

# href
is($link->href(),                               'http://www.example.com', 'href() access works');
is($link->href('http://www.changed.com')->href, 'http://www.changed.com', 'href() set works');

# title
is($link->title('My new title')->title, 'My new title', 'title() works as setter and getter');
diag($link->href, " ", $link->title);

# tags
is($link->tags,                      1, 'tags() access works. 1 tags');
is($link->tags(qw/two three/)->tags, 3, 'tags() set works. 3 tags');
is($link->tags('one','four')->tags,  4, "tags() setter not duplicate. 4 tags");
is($link->tags("just   a\t sentence")->tags, 7, "tags() setter split on blank space. 7 tags");
diag(join ",", $link->tags);

# has_tag
is($link->has_tag('one') , 1, 'one is among tags');
is($link->has_tag('five'), 0, "five isn't among tags");
is($link->has_tag(),       0, 'empty list return false');

done_testing();
