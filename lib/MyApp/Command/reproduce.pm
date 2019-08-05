package MyApp::Command::reproduce;
use Mojo::Base 'Mojolicious::Command';


has description => 'Reproduces exception of saved bad request';
has usage => sub { shift->extract_usage };


use Mojo::URL;
use Mojo::UserAgent;
use Mojo::Transaction::HTTP;
sub run {
	my( $self, @args ) =  @_;

	my $req =  do 'request.debug'
		or die "No saved request found";

	my $ua =  Mojo::UserAgent->new;
	$ua->inactivity_timeout(0);
	$ua->request_timeout(0);

	my $url =  Mojo::URL->new( '/set_breakpoint' )->base( $req->{ url }->base );
	my $tx  =  $ua->build_tx( POST => $url->to_abs, {}, form => {
		package => $req->{ package },
		file    => $req->{ file },
		line    => $req->{ line },
	});
	$tx = $ua->start($tx);

	for( 1..50 ) {
		print "Sending request $_\n";
		$tx =  $ua->build_tx( $req->@{qw/ method url headers body /} );
		$tx =  $ua->start( $tx );
	}
}

1;


=head1 SYNOPSIS

  Usage: APPLICATION reproduce [OPTIONS]

  Options:
    NONE

=cut
