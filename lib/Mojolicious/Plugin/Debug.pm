package Mojolicious::Plugin::Debug;

use Mojo::Base 'Mojolicious::Plugin';

sub register {
	my( $plugin, $app, $conf ) =  @_;

	$app->hook( after_dispatch => \&dump_request );
	my $r =  $app->routes;
	$r->post( '/set_breakpoint', \&set_breakpoint );
}



use Mojo::File();
use Data::Dump();
sub dump_request {
	my( $c ) =  @_;

	my $e =  $c->stash( 'exception' )   or return;


	open my $fh, '>request.debug';

	$c->req->url->query(''); # Only for PerlCon
	print $fh Data::Dump::pp({
		package => $e->frames->[0][0],
		# Mojo::File->new( $e->frames->[0][1] )->realpath."",
		file    => $e->frames->[0][1],
		line    => $e->frames->[0][2],
		method  => $c->req->method,
		url     => $c->req->url->to_abs,
		headers => $c->req->headers->to_hash,
		body    => $c->req->body,
	});
}


sub set_breakpoint {
	my $c =  shift;

	my $f =  $c->param( 'file' );
	my $l =  $c->param( 'line' );

	# Make sure file is loaded
	# require $f; # Module reloading breaks C3 inheritance
	if( my $e =  Mojo::Loader::load_class( $c->param( 'package' ) ) ) {
		return $c->render( text => $e );
	}

	# Set breakpiont
	DB::Commands::get_command( 'breakpoint' )->( "$f:$l" );

	$c->render( text => 'OK' );
}



1;
