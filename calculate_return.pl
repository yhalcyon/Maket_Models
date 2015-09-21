#! /usr/bin/perl

use List::Util qw(sum);

if(-e "return_data.csv"){
unlink "return_data.csv";
}
open FILE, "Return_original.csv" or die "Cannot find the file:($!)";
open KEEP, ">>", "return_data.csv" or die "Cannot get the file:($!)";

my $flag = 0;
my $year_old = 0;
my $year_num = 0;
my @arr_f = ();
my @arr_l = ();
my $asset = 0;;
while (chomp(my $lines = <FILE>)){
    my @element = split(",", $lines);
    my $year = $element[2];
    my $price = $element[3];
    my $div = $element[4];	
    my $price_l = $element[5];
    my $div_l = $element[6];
    if($flag == 0){
	push @arr_f, $price+$div;
	push @arr_l, $price_l;
	$flag = 1;
    }
    if($year eq $year_old){
	push @arr_f, $price+$div;
	push @arr_l, $price_l;
    }
    else{
	my $aver1 = sum(@arr_f)/@arr_f;
	my $aver2 = sum(@arr_l)/@arr_l;
	my $return_rate = $aver1/$aver2;
	if($year_old == 1970){
		$asset = 100000;
	}
	else{
		$asset = $asset*$return_rate;
	}
	$return_rate = ($return_rate-1.0)*100;
	if($year_old != 0){
		print KEEP "$year_old,$return_rate,$asset\n";
	}
	@arr_f = ();
	@arr_l = ();
	push @arr_f, $price+$div;
	push @arr_l, $price_l;
    }
    $year_old = $year;
}
my $aver1 = sum(@arr_f)/@arr_f;
my $aver2 = sum(@arr_l)/@arr_l;
my $return_rate = $aver1/$aver2;
$asset = $asset*$return_rate;
$return_rate = ($return_rate-1.0)*100;
print KEEP "$year_old,$return_rate,$asset\n";

close FILE;
close KEEP;
