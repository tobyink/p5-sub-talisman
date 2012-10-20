use Test::More;
use attributes ();

my $x;
{
	package Local::XXX;
	use Sub::Talisman qw( WWW XXX YYY ZZZ );

	sub foo :XXX(1,2,3) { $x };
	sub bar :XXX(1) :YYY :ZZZ { $x };
	sub baz : XXX YYY ZZZ lvalue { $x };
}

my $pkg = 'Local::XXX';

is_deeply(
	[ Sub::Talisman->get_attributes($pkg->can('foo')) ],
	[ map {"$pkg\::$_"} qw(XXX) ],
	'correct talismans for foo',
);

is_deeply(
	[ Sub::Talisman->get_attributes($pkg->can('bar')) ],
	[ map {"$pkg\::$_"} qw(XXX YYY ZZZ) ],
	'correct talismans for bar',
);

is_deeply(
	[ Sub::Talisman->get_attributes($pkg->can('baz')) ],
	[ map {"$pkg\::$_"} qw(XXX YYY ZZZ) ],
	'correct talismans for baz',
);

is_deeply(
	[ sort my @x = attributes::get($pkg->can('baz')) ],
	[ qw( XXX YYY ZZZ lvalue ) ],
	'correct attributes for baz',
);

is_deeply(
	[ sort Sub::Talisman->get_subs("$pkg\::XXX") ],
	[ map {"$pkg\::$_"} qw( bar baz foo ) ],
	'correct subs for :XXX',
);

is_deeply(
	[ sort Sub::Talisman->get_subs("$pkg\::YYY") ],
	[ map {"$pkg\::$_"} qw( bar baz ) ],
	'correct subs for :YYY',
);

is_deeply(
	[ sort Sub::Talisman->get_subs("$pkg\::ZZZ") ],
	[ map {"$pkg\::$_"} qw( bar baz ) ],
	'correct subs for :ZZZ',
);

is_deeply(
	Sub::Talisman->get_attribute_parameters($pkg->can('foo'), "$pkg\::XXX"),
	[ 1 .. 3 ],
	'correct parameters for foo :XXX',
);

is_deeply(
	Sub::Talisman->get_attribute_parameters($pkg->can('bar'), "$pkg\::XXX"),
	[ 1 ],
	'correct parameters for bar :XXX',
);

is(
	Sub::Talisman->get_attribute_parameters($pkg->can('baz'), "$pkg\::XXX"),
	undef,
	'correct parameters for baz :XXX',
);

ok(
	!$pkg->can('XXX'),
	'sub XXX was cleaned'
);

ok(
	!$pkg->can('YYY'),
	'sub YYY was cleaned'
);

ok(
	!$pkg->can('ZZZ'),
	'sub ZZZ was cleaned'
);

done_testing;
