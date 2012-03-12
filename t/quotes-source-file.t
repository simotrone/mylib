use Test::More;
use FindBin;
use lib "$FindBin::Bin/../lib";

BEGIN { use_ok('Trone::Quotes::Source::File') }

my $qsf = Trone::Quotes::Source::File->new(input => "$FindBin::Bin/extra/quotes.txt");
isa_ok($qsf,'Trone::Quotes::Source::File');

my @quotes = $qsf->quotes;
is(scalar @quotes, 5, 'We have 5 quotes');
isa_ok($_, 'Trone::Quotes::Quote') for @quotes;

ok($qsf->clean, 'clean data');
is($qsf->quotes, 5, 'We have 5 quotes again');

done_testing();
