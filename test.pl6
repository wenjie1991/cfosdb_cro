use DB::SQLite;
use JSON::Fast;
use Template::Mustache;

say Template::Mustache.render('say {{{w}}}', {w => "<hello>"});

my $sqlite-db = DB::SQLite.new(:filename("../../database/cFosDB.db"));

my $full_name = "nucleus accumbens";

my $out = $sqlite-db.query(qq:to/END/);
select * from brain_area_behavior inner join brain_area_annotation on brain_area_behavior.brain_code = brain_area_annotation.brain_code where brain_area_behavior.behavior like "pain%" AND brain_area_annotation.full_name = "{$full_name}";
END
#say $out.hashes;

#qq[("{<a b c d>.join('", "')}")].say
my @h = $out.hashes;

my %edges;
my %nodes;

for @h -> %r {
	my $edge = {
		source => %r<behavior>,
		target => %r<brain_code>
	};
	%edges{$edge.values.join("")} = {
		source => %r<behavior>,
		target => %r<brain_code>
	};

	my $behavior = %r<behavior>;
	my $brain_area = %r<brain_code>;

	if (%nodes{$behavior}) {
		%nodes{$behavior}<value>++; } else {
		%nodes{$behavior} = {
			id => %r<behavior>,
			name => %r<condition>,
			value => 1,
			category => 0,
			label => {"normal" => {"show" => "false"}},
			color => "red"
		}
	}

	if (%nodes{$brain_area}) {
		%nodes{$brain_area}<value>++;
	} else {
		%nodes{$brain_area} = {
			id => %r<brain_area>,
			name => %r<condition>,
			value => 1,
			category => 1,
			label => {"normal" => {"show" => "false"}},
			color => "red"
		}
	}
}

say to-json %nodes.values;
say to-json %edges.values;
