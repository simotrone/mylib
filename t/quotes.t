use Test::More;
use Test::Deep;
use Data::Dumper;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";

BEGIN { use_ok('Trone::Quotes'); }

# constructor
my $quotes = Trone::Quotes->new(input => "file://$FindBin::Bin/extra/quotes.txt");
isa_ok($quotes, 'Trone::Quotes');

# list
is($quotes->list, 5, 'We have 5 quotes');

isa_ok($_, 'Trone::Quotes::Quote') for $quotes->list;

# dump
cmp_deeply(
        $quotes->dump,
        [
                { author => 'author1',            text => 'text1' },
                { author => 'author2 with space', text => 'text2 with space' },
                { author => 'author3 with space', text => 'text3 with \n
as this
and this' },
                { author => 'author4 japanese',   text => '読んでばか' },
                { author => 'author5 normal',     text => 'final text5' }
        ],
        'dump() give right data structure form file'
);

# constructor mysql
my $quotes_my = Trone::Quotes->new(input => 'mysql://sim@localhost/test');
isa_ok($quotes_my, 'Trone::Quotes');
is($quotes_my->list, 2, 'We have 2 quotes');

cmp_deeply(
        $quotes_my->dump,
        [
                { author => 'Pippo', text => 'I like become super-goofy. Yuk' },
                { author => 'Topolino', text => 'The detective is here!' },
        ],
        'dump() give right data struct form db'
);

done_testing();
