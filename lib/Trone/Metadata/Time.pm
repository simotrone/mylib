package Trone::Metadata::Time;

use base Time::localtime;

sub new {
        my $class = shift;
        my $unixtime = shift || time;

        bless [localtime($unixtime),$unixtime], $class;
}

sub mon  {    1 + shift->SUPER::mon  }
sub year { 1900 + shift->SUPER::year }
sub wday { (qw/Sun Mon Tue Wed Thu Fri Sat/)[shift->SUPER::wday]; }

sub unix { shift->[9] }

sub hm   {
        my $s = shift;
        sprintf("%02d:%02d", $s->hour, $s->min);
}
sub dmy  {
        my $s = shift;
        join '.', $s->mday, $s->mon, $s->year;
}
sub iso_8601 {
	my $s = shift;
	sprintf("%04d-%02d-%02dT%02d:%02d", $s->year,$s->mon,$s->mday, $s->hour,$s->min);
}

1;
__END__
=head1 NAME

Trone::Metadata::Time - Simple Time container based on unix timestamp.

=head1 SYNOPSIS

        $t = Trone::Metadata::Time->new();
        $t->year;      # 2012              
        $t->unix;      # 1331482035        
        $t->iso_8601;  # 2012-03-11T17:07  

        $t = Trone::Metadata::Time->new(123456789);
        $t->year;      # 1973
        $t->unix;      # 123456789
        $t->iso_8601   # 1973-11-29T22:33

=head1 DESCRIPTION

Trone::Metadata::Time extends Time::localtime Perl object (see man) adjusting
simple things about output.

        $t->mon  returns a $month+1
        $t->year returns a $year+1900
        $t->wday returns the right three letter weekday string.

Trone::Metadata::Time add also a new attribute that returns unix timestamp.

=head1 CONSTRUCTOR

=over 4

=item Trone::Metadata::Time->new();

Implicitly select "now" unix timestamp.

=item Trone::Metadata::Time->new(unix_timestamp);

=back

=head1 ATTRIBUTES

=head2 The new (or overrided) attributes.

=over 4

=item $t->mon

Returns mon (1-12).

=item $t->year

Returns true year (original+1900).

=item $t->wday

Returns stringified week day: Sun Mon Tue Wed Thu Fri Sat.

=item $t->unix

Returns unix timestamp (seconds since 1-1-1970 + tz hour gap).

=back

=head2 The Time::localtime attributes not overrided.

=over 4

=item $t->sec

=item $t->min

=item $t->hour

=item $t->mday

=item $t->yday

=item $t->isdst

=back

=head1 METHODS

=over 4

=item $t->hm()

Returns a string as HH:MM

=item $t->dmy()

Returns a string as d.m.yyyy

=item $t->iso_8601()

Returns the iso 8601 string date: yyyy-mm-ddTHH:MM

=back

=cut
