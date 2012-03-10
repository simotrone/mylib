use strict;
use warnings;
use Test::More;

my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";

use FindBin;
use lib "$FindBin::Bin/lib";

BEGIN {
        use_ok('Trone::Quotes');
}

# constructor
my $quotes = Trone::Quotes->new(
        input => "file://$FindBin::Bin/extra/quotes.txt",
);
isa_ok($quotes, 'Trone::Quotes');

my @quotes = $quotes->list;
diag($_->author .' : '. $_->text) for @quotes;

done_testing();
