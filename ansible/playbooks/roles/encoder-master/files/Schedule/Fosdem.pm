package SReview::Schedule::Fosdem::Speaker;

use Moose;
use SReview::Schedule::Penta;

extends 'SReview::Schedule::Base::Speaker';

has 'pretalx_data' => (
	is => 'ro',
	isa => 'HashRef',
	lazy => 1,
	builder => '_build_pretalx_data',
);

sub _build_pretalx_data {
	my $self = shift;

	my $rv = $self->talk_object->pretalx_data->{speakers}{$self->upstreamid};
        die "Could not find speaker called " . $self->name . " with upstream id " . $self->upstreamid . " for talk " . $self->talk_object->title . " in pretalx data" unless $rv;
        return $rv;
}

sub _load_email {
	my $self = shift;

	return $self->pretalx_data->{email};
}

package SReview::Schedule::Fosdem::Track;

use Moose;

extends 'SReview::Schedule::Base::Track';

has 'pretalx_data' => (
	is => 'ro',
	isa => 'HashRef',
	lazy => 1,
	builder => '_build_pretalx_data',
);

sub _build_pretalx_data {
        my $self = shift;
	my $rv = $self->talk_object->pretalx_data->{track};

        die "Could not find track for talk " . $self->talk_object->title . " in pretalx data" unless $rv;

        return $rv;
}

sub _load_email {
	return shift->pretalx_data->{email};
}

sub _load_upstreamid {
	return shift->pretalx_data->{id};
}

package SReview::Schedule::Fosdem::Talk;

use Moose;

extends 'SReview::Schedule::Penta::Talk';

has 'pretalx_data' => (
	is => 'ro',
	isa => 'HashRef',
	lazy => 1,
	builder => '_build_pretalx_data',
);

has '_subtitle' => (
        is => 'rw',
        isa => 'Str',
        trigger => \&_clear_subtitle,
);

has '+title' => (
	trigger => \&_set_title,
);

has '+subtitle' => (
	predicate => 'has_subtitle',
        clearer => '_clear_subtitle',
);

sub _parse_title {
        my $self = shift;
        my $new_title = shift;
        my $subtitle = undef;

	if($new_title =~ /^\[?(REPLACEMENT|RESCHEDULED)[:\]]? (?<title>.*)/) {
		$new_title = $+{title};
	}

	if($new_title =~ /^(?<title>[^:-?]+[?]*)[:\s-]*(?<subtitle>.*$)/) {
                if(length($+{title}) >= 10) {
                        $subtitle = $+{subtitle};
                        $new_title = $+{title};
                }
	}
        return ($new_title, $subtitle);
}

sub _load_title {
        my $self = shift;
        my $title = $self->SUPER::_load_title;

        ($title, my $subtitle) = $self->_parse_title($title);
        $self->_subtitle($subtitle) if $subtitle;

        return $title;
}

sub _set_title {
	my ($self, $new_title) = @_;
        my $parsed_title;
        my $subtitle;

        ($parsed_title, $subtitle) = $self->_parse_title($new_title);
        $self->title($parsed_title) if $new_title ne $parsed_title;
        $self->_subtitle($subtitle) if $subtitle;
}

sub _load_subtitle {
        return shift->_subtitle;
}

sub _load_filtered {
        my $self = shift;
        if(!defined($self->event_object->root_object->pretalx_data->{$self->upstreamid})) {
                return 1;
        }
        return 0;
}

sub _build_pretalx_data {
	my $self = shift;

	my $data = $self->event_object->root_object->pretalx_data->{$self->upstreamid};

        if(!defined($data)) {
                return {};
        }
	$data->{speakers} = {};
	foreach my $speaker(@{$data->{persons}}) {
		$data->{speakers}{$speaker->{person_id}} = $speaker;
	}
	return $data;
}

sub _set_altname {
	my $self = shift;
	my $room = shift;
	
	$room->altname($self->pretalx_data->{conference_room});
	$room->outputname($self->pretalx_data->{conference_room});
}

has '+room' => (
	trigger => \&_set_altname,
);

package SReview::Schedule::Fosdem;

use Moose;
use Mojo::UserAgent;

extends 'SReview::Schedule::Penta';

has 'pretalx_url' => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

has 'pretalx_api_key' => (
	is => 'ro',
	isa => 'Str',
	required => 1,
);

has 'pretalx_data' => (
	is => 'ro',
	isa => 'HashRef',
	lazy => 1,
	builder => '_build_pretalx_data',
);

sub _build_pretalx_data {
	my $self = shift;
	my $ua = Mojo::UserAgent->new;
	my $res = $ua->get($self->pretalx_url => {"Authorization" => "Token " . $self->pretalx_api_key})->result;
	die "Could not fetch pretalx data: " . $res->message unless $res->is_success;
	my $data = $res->json;
	my $rv = {};
	foreach my $talk(@{$data->{talks}}) {
		$rv->{$talk->{event_id}} = $talk;
	}
	return $rv;
}

sub _load_speaker_type {
	return "SReview::Schedule::Fosdem::Speaker";
}

sub _load_track_type {
	return "SReview::Schedule::Fosdem::Track";
}

sub _load_talk_type {
	return "SReview::Schedule::Fosdem::Talk";
}

1;
