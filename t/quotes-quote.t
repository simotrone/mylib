use Test::More;
use Test::Deep;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";

BEGIN { use_ok('Trone::Quotes::Quote'); }

# Quote object constructor
my $quote = Trone::Quotes::Quote->new();
isa_ok($quote, 'Trone::Quotes::Quote');
is($quote->author, 'Anonymous', "Default author is Anonymous");

# Quote setting
ok($quote->author('my favourite author')->text('my favourite citation'), 'New Quote object ready');

# Quote accessors
like($quote->author, qr/favourite author/,   "The setters' chain works for author");
like($quote->text,   qr/favourite citation/, "The setters' chain works for text");


done_testing();
