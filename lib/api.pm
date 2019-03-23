package api;
use strict;
use warnings;
use Data::Dumper qw(Dumper);
use JSON qw( decode_json encode_json);
use Digest::SHA1 qw(sha1 sha1_hex sha1_base64);
use HTTP::Tiny;
use constant { true => 0, false => 1 };
my $http = HTTP::Tiny->new;

sub new {
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
}

sub tw_Login {
	my ($self, $user, $pass) = @_;
	my %body = (username => "$user", password => sha1_hex($user.$pass), type => 'email');
	my $tw_login = $http->request( 'POST', 'https://mobile-api-gateway.truemoney.com/mobile-api-gateway/api/v1/signin', {
			Host => 'mobile-api-gateway.truemoney.com',
			headers => {
				'content-type' => 'application/json'
			},
			content => encode_json \%body
		}
	);
	if ($tw_login->{success}) {
		my $tw_Login_json = decode_json($tw_login->{content});
		$self->{login}->{token} = $tw_Login_json->{'data'}->{'accessToken'};
	} else {
		return false;
	}
}


sub tw_getProfile {
	my ( $self ) = @_;
	my $tw_getProfile = $http->request( 'GET', "https://mobile-api-gateway.truemoney.com/mobile-api-gateway/api/v1/profile/$self->{login}->{token}", {
			Host => 'mobile-api-gateway.truemoney.com'
	});

	if ($tw_getProfile->{success}) {
		my $tw_getProfile_json = decode_json($tw_getProfile->{content});
		$self->{profile}->{mobilenumber} = $tw_getProfile_json->{'data'}->{'mobileNumber'};
		$self->{profile}->{lastnameEn} = $tw_getProfile_json->{'data'}->{'lastnameEn'};
		$self->{profile}->{email} = $tw_getProfile_json->{'data'}->{'email'};
		$self->{profile}->{balance} = $tw_getProfile_json->{'data'}->{'currentBalance'};
		$self->{profile}->{firstnameEn} = $tw_getProfile_json->{'data'}->{'firstnameEn'};
		$self->{profile}->{thaiId} = $tw_getProfile_json->{'data'}->{'thaiId'};
		my $data = {
			mobilenumber => $self->{profile}->{mobilenumber},
			lastnameEn  => $self->{profile}->{lastnameEn},
			email => $self->{profile}->{email},
			balance => $self->{profile}->{balance},
			firstnameEn => $self->{profile}->{firstnameEn},
			thaiId => $self->{profile}->{thaiId},
			fullname => "$self->{profile}->{firstnameEn} $self->{profile}->{lastnameEn}"
		};
		return ($data);
	} else {
		return false;
	}
}


sub tw_getActivity {
	my ( $self, $start, $end ) = @_;
	
	my $limit = 25;
	my $tw_getActivity = $http->request( 'GET', "https://mobile-api-gateway.truemoney.com/mobile-api-gateway/user-profile-composite/v1/users/transactions/history?start_date=$start&end_date=$end&limit=$limit", {
			Host => 'mobile-api-gateway.truemoney.com',
			headers => {
				'Authorization' => $self->{login}->{token}
			}	
	});

	if ($tw_getActivity->{success}) {
		my $tw_getActivity_json = decode_json($tw_getActivity->{content});
		print Dumper($tw_getActivity_json);
		$self->{activity}->{report_id} = $tw_getActivity_json->{'data'}->{'activities'}->{'report_id'};
		$self->{activity}->{amount} = $tw_getActivity_json->{'data'}->{'activities'}->{'amount'};
		$self->{activity}->{date_time} = $tw_getActivity_json->{'data'}->{'activities'}->{'date_time'};
		my $data = {
			report_id => $self->{activity}->{report_id},
			amount => $self->{activity}->{amount},
			date_time => $self->{activity}->{date_time}
		};
		return ($data);
	} else {
		return false;
	}

}