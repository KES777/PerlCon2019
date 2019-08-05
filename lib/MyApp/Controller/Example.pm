package MyApp::Controller::Example;
use Mojo::Base 'Mojolicious::Controller';


sub exception {
	die;
}


sub exception_rand {
	my $c =  shift;

	if( rand()*100 < 10  ||  $c->param( 'high' ) ) {
		die;
	}

	$c->render( text => 'OK' );
}

1;
