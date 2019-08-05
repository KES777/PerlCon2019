package MyApp;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
	my $app = shift;

	# Add another namespace to load commands from
	push @{ $app->commands->namespaces }, 'MyApp::Command';

	# Load configuration from hash returned by config file
	my $config = $app->plugin('Config');
	$app->plugin('Debug');

	# Configure the application
	$app->secrets($config->{secrets});

	# Router
	my $r = $app->routes;

	# Normal route to controller
	$r->get ('/'        )->to('example#form'          );
	$r->post('/die'     )->to('example#exception'     );
	$r->post('/die_rand')->to('example#exception_rand');
}

1;
