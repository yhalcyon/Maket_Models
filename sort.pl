#! /usr/bin/perl

print "Checking the original data:\n";

if(-e "div_yield.csv"){
    unlink("div_yield.csv");
}
if(-e "return.txt"){
    unlink("return.txt");
}
if(-e "rand_return.txt"){
    unlink("rand_return.txt");
}
if(-e "cagr.txt"){
    unlink("cagr.txt");
}

open FILE, "original_data.csv" or  die "Cannot get the file:($!)";
open HW3, "hw3_data.csv" or die "Cannot find the file:($!)";
open RETURN, "annual_return.csv" or die "Cannot find the file:($!)";
open KEEP, ">>", "div_yield.csv" or die "Cannot get the file:($!)";
open DOGSofDOW_RETURN, ">>", "return.txt" or die "Cannot get the file:($!)";
open RAND_RETURN, ">>", "rand_return.txt" or die "Cannot get the file:($!)";
open CAGR, ">>", "cagr.txt" or die "Cannot get the file:($!)";

my $i = -1;
my $j = 0;
my $k = 0;
my $m = 0;
my $l = 0;
my @div_yield = ();
my $flag = 0;
my $old_compname = 'aa';
my $old_year = 0;
my $old_price = 0.0;
my $close_price = 0.0;
my %ending_hash = ();
my %start_hash = ();
my @comp_list = ();
my $total_div = 0.0;
while (chomp(my $hw3_lines = <HW3>)){
    my @data_elements = split(',',$hw3_lines);
    my $start_date = substr($data_elements[1],-4,4);
    my $ending_date = substr($data_elements[2],-4,4);
    my $hw3_compname = $data_elements[3];
    $start_hash{$hw3_compname} = $start_date;
    $ending_hash{$hw3_compname} = $ending_date;
}

my @annual_return = ();
my %return_index = ();
my $return_flag = 0;
while (chomp(my $return_lines = <RETURN>)){
    my @return_elements = split(',',$return_lines);
    my $return_comp = $return_elements[0];
    for $i(0 .. 34){
	$annual_return[$return_flag][$i] = $return_elements[$i+1];
    }
    $return_index{$return_comp} = $return_flag;
    $return_flag += 1;
}

while ( chomp (my $lines = <FILE>)){
    $flag += 1;
    my @element = split(',', $lines);
    my $date = $element[1];
    my $data_year = substr($date,0,4);
    my $compname = $element[2];
    my $paydat = $element[3];
    my $div = $element[4];
    my $prc = $element[5];

    if(!$ending_hash{$compname}){
	next;
    }
    if($ending_hash{$compname} ne '-'){
	if($data_year >= $ending_hash{$compname}){
	    next;
	}
    }
    #print "$flag\n";
    if( $flag == 1){
	$i = 0;
	$old_compname = $compname;
	$comp_list[$i] = $compname;
	$j = $data_year - 1979;
	$total_div = 0.0;
	$old_year = $data_year;
    }
    if($data_year == $old_year){
	if ($div != ''){
	    $total_div = $total_div + $div;
	}
    }
    if($data_year != $old_year || $compname ne $old_compname){
	$j = $old_year - 1979;
	$close_price = $old_price;
#	print "$old_year $old_compname $total_div $close_price\n"; 
	$div_yield[$i][$j] = $total_div/$close_price;
	$total_div = 0.0; 
	if ($div != ''){
	    $total_div = $div;
	} 
	if($compname ne $old_compname){
	    $i += 1;
	    $comp_list[$i] = $compname;
	}
    }
    $old_price = $prc;
    $old_year = $data_year;
    $old_compname = $compname;
}
#reccord the data for the last year of the last company
$j = $old_year - 1979;
$close_price = $old_price;
$div_yield[$i][$j] = $total_div/$close_price;

print KEEP "COMP_NAME,";
for $j (0 .. 35){
    my $year = $j + 1979;
    print KEEP "$year,";
}
print KEEP "\n";
for $i (0 .. 71){
    print KEEP "$comp_list[$i],";
    for $j (0 .. 35){
	my $year = $j + 1979;
	if($year < $start_hash{$comp_list[$i]}){
	    $div_yield[$i][$j] = 0;
	}
	if($ending_hash{$comp_list[$i]} ne '-'){
	    if($year >= $ending_hash{$comp_list[$i]}){
		$div_yield[$i][$j] = 0;
	    }
	    if($year == $ending_hash{$comp_list[$i]}){
		$div_yield[$i][$j] = 0;
	    }
	}
	print KEEP "$div_yield[$i][$j],";
    }
    print KEEP "\n";
}    

### pick out the 10 companies with highest div yeild each year ###
my @unsorted = ();
my @sorted_comp = ();
for $j(0 .. 35){
    for $i(0 .. 71){
	$unsorted[$i] = $div_yield[$i][$j];
    }
    my @sorted_indexs =  sort{$unsorted[$b] <=> $unsorted[$a]} 0..71;
    my @sorted_values = @comp_list[@sorted_indexs];
    for $k(0 .. 9){
	$sorted_comp[$k][$j] = $sorted_values[$k];
    }
}

for $k(0 .. 35){
    for $j(0..9){
	print KEEP "$sorted_comp[$j][$k];";
    }
    print KEEP "\n";
}

for $j(0 .. 34){
    my $total_return = 0.0;
    for $k(0 .. 9){
	$i = $return_index{$sorted_comp[$k][$j]};
	$total_return += $annual_return[$i][$j];
    }
    $total_return /= 10.0;
    my $year = $j + 1980;
    print DOGSofDOW_RETURN "$year $total_return\n";
}

### randomly pick out 10 companies each year ###
my @strap_index = ();
my @length = ();
for $j(0 .. 34){
    my @index = ();
    my $range = 0;
    my $n = 0;
    for $i(0 .. 71){
	if($start_hash{$comp_list[$i]} <= $j+1979){
	    if($ending_hash{$comp_list[$i]} >= $j+1979 || $ending_hash{$comp_list[$i]} eq '-'){
		push @index, $i;
		$strap_index[$j][$n] = $i;
		$n += 1;
	    }
	}
    }
    my @random_index = ();
    $range = scalar(@index);
    $length[$j] = $range;
    while(scalar(@random_index) < 10){	
	my $random_number = int(rand($range));
	my $dup_flag = 0;
	for $l(0 .. scalar(@random_index)-1){
	    if($index[$random_number] == $random_index[$l]){
		$dup_flag = 1;
		next;
	    }
	}
	if($dup_flag == 1){
	    next;
	}
	push @random_index, $index[$random_number];
    }
    my $rand_total = 0.0;
    for $m(0 .. 9){
	$i = $return_index{$comp_list[$random_index[$m]]};
	$rand_total += $annual_return[$i][$j];
    }
    my $year = $j + 1980;
    $rand_total /= 10.0;
    print RAND_RETURN "$year $rand_total\n";
}

### boots strap test ###
for $i(0 .. 9999){
    my $cagr = 0;
    for $j(0 .. 34){
	my @random_index = ();
	my $range = $length[$j];
	while(scalar(@random_index) < 10){	
	    my $random_number = int(rand($range));
	    push @random_index, $strap_index[$j][$random_number];
	}
	my $rand_total = 0.0;
	for $m(0 .. 9){
	    $k = $return_index{$comp_list[$random_index[$m]]};
	    $rand_total += $annual_return[$k][$j];
	}
	$rand_total /= 10.0;
	if($j == 0){
	    $cagr = $rand_total * 0.01 + 1.00;
	}
	else{
	    $cagr *= ($rand_total * 0.01 + 1.00);
	}
    }
    $cagr = $cagr**(1.0/35.0);
    print CAGR "$i $cagr\n";
}
print "End of the calculations\n";

close FILE;
close KEEP;
close HW3;
close RETURN;
close DOGSofDOW_RETURN;
close RAND_RETURN;
close CAGR;
