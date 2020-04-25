use DB::SQLite;
use JSON::Fast;
use Template::Mustache;

sub query(%parameter) {
	my $sqlite-db = DB::SQLite.new(:filename("./database/cFosDB.db"));

	my $out = $sqlite-db.query(qq:to/END/);
	SELECT * FROM brain_area_behavior JOIN brain_area_annotation ON brain_area_behavior.brain_code = brain_area_annotation.brain_code 
	WHERE	
	brain_area_behavior.behavior IN ("{%parameter<behavior>.join('","')}") 
		AND 
	brain_area_annotation.brain_code IN ("{%parameter<brain_area>.join('","')}") 
		AND
	brain_area_behavior.gender like "{%parameter<gender>}"
	;
	END

	return $out.hashes.Array;
}

#sub generate-network-data(@query-result) {
#    my @h = @query-result;

#    my %edges;
#    my %nodes;

#    for @h -> %r {

#        my $behavior = %r<condition>;
#        my $brain_area = %r<brain_code>;

#        my $edge = {
#            source => $behavior,
#            target => $brain_area
#        };
#        %edges{$edge.values.join("")} = $edge;

#        if (%nodes{$behavior}) {
#            %nodes{$behavior}<value>++;
#        } else {
#            %nodes{$behavior} = {
#                id => $behavior,
#                name => %r<condition>,
#                value => 1,
#                category => 0,
#                label => {"normal" => {"show" => "false"}},
#                color => "red"
#            }
#        }

#        if (%nodes{$brain_area}) {
#            %nodes{$brain_area}<value>++;
#        } else {
#            %nodes{$brain_area} = {
#                id => $brain_area,
#                name => %r<species> ~ ": " ~ %r<main>,
#                value => 1,
#                category => 1,
#                label => {"normal" => {"show" => "false"}},
#                color => "red"
#            }
#        }
#    }
#    return to-json({nodes => %nodes.values, links => %edges.values})
#}


class Response is export {
	my $templ = slurp "template/template.html";

	my $index = slurp "template/index.html";
	my $search = slurp "template/search.html";
	my $browser = slurp "template/browser.html";
	my $help = slurp "template/help.html";
	my $download = slurp "template/download.html";

	my @brain_area_annotation = from-json(slurp("lib/brain_area_annotation.json")).flat;

	has %!config;
	method index() {
		my %config = %!config;
		my $body = $index;
		%config<home_active> = 'class="active"';
		%config<body> = $body;
		my $harvest = Template::Mustache.render($templ, %config);
		return $harvest;
	}

	method search(%parameter) {
		my %config = %!config;
		my @sql-result = query(%parameter);
#        my $network-data = generate-network-data(@sql-result);
		my $network-data = to-json(@sql-result);
		my %search-result := {
			tr => @sql-result,
			brain_area => @brain_area_annotation,
			network_data => $network-data
		};
		my $body = Template::Mustache.render($search, %search-result);
		%config<search_active> = 'class="active"';
		%config<body> = $body;
		my $harvest = Template::Mustache.render($templ, %config);
		return $harvest;
	}

	method download() {
		my %config = %!config;
		my $body = $download;
		%config<download_active> = 'class="active"';
		%config<body> = $body;
		my $harvest = Template::Mustache.render($templ, %config);
		return $harvest;
	}

	method browser() {
		my %config = %!config;
		my $body = $browser;
		%config<browser_active> = 'class="active"';
		%config<body> = $body;
		my $harvest = Template::Mustache.render($templ, %config);
		return $harvest;
	}

	method help() {
		my %config = %!config;
		my $body = Template::Mustache.render($help, {tr => @brain_area_annotation});
		%config<help_active> = 'class="active"';
		%config<body> = $body;
		my $harvest = Template::Mustache.render($templ, %config);
		return $harvest;
	}
}

