use Cro::HTTP::Router;
use Query;

my $response = Response.new();

sub routes() is export {
    route {
        get -> {
            content 'text/html', $response.index();
        }
		get -> "index.html" {
            content 'text/html', $response.index();
        }
		get -> "search2", :@name {
            content 'text/html', @name.map({$_.values}).join();
        }
		post -> "search" {
			request-body -> %parameter {
				content 'text/html', $response.search(%parameter);
			}
        }
		get -> "search", :%parameter {
			content 'text/html', $response.search(%parameter);
		}
		get -> "browser" {
            content 'text/html', $response.browser();
        }
		get -> "download" {
            content 'text/html', $response.download();
        }
		get -> "help" {
            content 'text/html', $response.help();
        }
		get -> 'css', *@path {
			static 'css', @path;
		}
		get -> 'images', *@path {
			static 'images', @path;
		}
		get -> 'fonts', *@path {
			static 'fonts', @path;
		}
		get -> 'js', *@path {
			static 'js', @path;
		}
		get -> 'json', *@path {
			static 'json', @path;
		}
    }
}


