#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use JSON;
use LWP::UserAgent;

my $dbname = 'sreview';
my $api_token = '{{ pretalx_sreview_api_token }}';

# Connect to PostgreSQL
my $dbh = DBI->connect("dbi:Pg:dbname=$dbname", "sreview", '', { RaiseError => 1, AutoCommit => 1 })
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

# Fetch existing data from Pretalx
my $existing_url = "https://pretalx.fosdem.org/fosdem-{{ fosdem_year }}/p/videolink/";
my $existing_response = $ua->get($existing_url, 'Authorization' => "Token $api_token");

my %existing_data;
if ($existing_response->is_success) {
    my $json_data = decode_json($existing_response->decoded_content);
    %existing_data = map { $_->{id} => $_ } @$json_data;
} else {
    warn "Failed to fetch existing data: " . $existing_response->status_line . "\n";
}


# Process query results
while (my $row = $sth->fetchrow_hashref) {
    my $upstreamid = $row->{upstreamid};
    my $slug       = $row->{slug};
    my $outputname = $row->{outputname};
    my $state      = $row->{state};

    my $base_path = "/srv/sreview/output/{{ fosdem_year }}/$outputname";
    my $av1_link = "https://video.fosdem.org/{{ fosdem_year }}/$outputname/$slug.av1.webm";
    my $mp4_link = "https://video.fosdem.org/{{ fosdem_year }}/$outputname/$slug.mp4";
    my $vtt_link = "https://video.fosdem.org/{{ fosdem_year }}/$outputname/$slug.vtt";

    # Get file sizes
    my $av1_size = -s "$base_path/$slug.av1.webm";
    my $mp4_size = -s "$base_path/$slug.mp4";

    my @new_payload = (
        { description => "Video recording (AV1/WebM) - ". human_readable_size($av1_size), link => $av1_link },
        { description => "Video recording (MP4) - ". human_readable_size($mp4_size), link => $mp4_link }
    );

    # if state = done also subtitles exist
    if ($state eq 'done') {
        push @new_payload, { description => "Video recording subtitle file (VTT)", link => $vtt_link };
    }

    my $encoded_new_payload = encode_json(\@new_payload);

    # Compare with existing data
    if (exists $existing_data{$upstreamid} && compare_hashes($existing_data{$upstreamid}->{video_links}, \@new_payload)) {
        print "No changes for talk ID $upstreamid, skipping upload.\n";
        next;
    }

    # Upload only if changed
    my $url = "https://pretalx.fosdem.org/fosdem-{{ fosdem_year }}/p/videolink/$upstreamid/";
    my $response = $ua->post($url, 
        'Authorization' => "Token $api_token", 
        Content => $encoded_new_payload
    );
    if ($response->is_success) {
        print "Uploaded successfully for talk ID $upstreamid: " . $response->decoded_content . "\n";
    } else {
        warn "Failed to upload for talk ID $upstreamid: " . $response->status_line . "\n";
    }
    # useful to stop after one record during testing
    #last;
}

# Function to compare two arrays of hashes (unordered)
sub compare_hashes {
    my ($old_links, $new_links) = @_;

    return 0 if scalar(@$old_links) != scalar(@$new_links);

    my %old_map = map { $_->{link} => $_->{description} } @$old_links;
    my %new_map = map { $_->{link} => $_->{description} } @$new_links;

    return 0 if keys %old_map != keys %new_map;

    foreach my $link (keys %old_map) {
        return 0 if !exists $new_map{$link} || $old_map{$link} ne $new_map{$link};
    }

    return 1;
}

sub human_readable_size {
    my $size = shift;
    return "0 B" unless defined $size;

    my @units = ("B", "KB", "MB", "GB", "TB");
    my $unit = 0;
    while ($size > 1024 && $unit < $#units) {
        $size /= 1024;
        $unit++;
    }
    return sprintf("%.1f %s", $size, $units[$unit]);
}
