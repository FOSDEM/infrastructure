#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use JSON;
use LWP::UserAgent;

my $dbname = 'sreview';

my $api_token = '{{ pretalx_sreview_api_token }}';

# Connect to PostgreSQL
my $dbh = DBI->connect("dbi:Pg:dbname=$dbname","sreview",'', { RaiseError => 1, AutoCommit => 1 })
    or die "Could not connect to database: $DBI::errstr";

# Prepare SQL query
my $sql = q{
    SELECT upstreamid, title, slug, rooms.outputname, state
    FROM talks
    JOIN rooms ON room = rooms.id
    WHERE state in ('done', 'transcribing') AND event = 21
};
my $sth = $dbh->prepare($sql);
$sth->execute();

# Initialize HTTP client
my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->agent("Perl VideoLinker/1.0");

# Process query results
while (my $row = $sth->fetchrow_hashref) {
    my $id         = $row->{upstreamid};
    my $slug       = $row->{slug};
    my $outputname = $row->{outputname};
    my $state      = $row->{state};

    my $av1_link = "https://video.fosdem.org/{{ fosdem_year }}/$outputname/$slug.av1.webm";
    my $mp4_link = "https://video.fosdem.org/{{ fosdem_year }}/$outputname/$slug.mp4";
    my $vtt_link = "https://video.fosdem.org/{{ fosdem_year }}/$outputname/$slug.vtt";
    my @payload = (
    { description => "Video recording (AV1/WebM)", link => $av1_link },
    { description => "Video recording (MP4)", link => $mp4_link }
);
    if ($state eq 'done') {
        push @payload, { description => "Video recording subtitle file (VTT)", link => $vtt_link };
    }
    my $encoded_payload = encode_json(\@payload);
    my $url = "https://pretalx.fosdem.org/fosdem-{{ fosdem_year }}/p/videolink/$id/";
    my $response = $ua->post($url,    
        'Authorization' => "Token $api_token",  Content => $encoded_payload);

    if ($response->is_success) {
        print "Uploaded successfully for talk ID $id: ".$response->decoded_content ."\n";
    } else {
        print "Response content:\n" . $response->decoded_content . "\n";
        warn "Failed to upload for talk ID $id: " . $response->status_line . "\n";

    }
    #last; # while testing run only one record
}

# Cleanup
$sth->finish;
$dbh->disconnect;

