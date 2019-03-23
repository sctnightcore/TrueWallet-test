use FindBin qw( $RealBin );
use Data::Dumper qw(Dumper);
use lib "$RealBin/lib";
use api;

main();
sub main {
	my $tw = api->new();
	my $tw_test_login = $tw->tw_Login('','');
	my $tw_test_profile = $tw->tw_getProfile();
	print "====================\n";
	print "Name:$tw_test_profile->{fullname}\n";
	print "ThaiID:$tw_test_profile->{thaiId}\n";
	print "Mobilenumber:$tw_test_profile->{mobilenumber}\n";
	print "Email:$tw_test_profile->{email}\n";
	print "Balance:$tw_test_profile->{balance}\n";
	print "====================\n";
	my $tw_test_activity = $tw->tw_getActivity('2018-12-28','2019-01-05');
	my $k = 0;
	foreach my $i ( @$activity ) {
		print "====================\n";		
		print "[".$k++."] ID:$_->{report_id}\n";
		print "[".$k++."] Amount:$_->{amount}\n";
		print "[".$k++."] Date Time:$_->{date_time}\n";
		print "====================\n";	
	}
}