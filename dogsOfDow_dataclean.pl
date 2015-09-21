#! /usr/bin/perl 

use strict;

###################################################
# The perl code for resorting the data
# ################################################

 print "Checking the original data:\n";

 if(-e "sorted_data.csv"){
      unlink("sorted_data.csv");
  }

 open FILE, "original_data.csv" or  die "Cannot get the file:($!)";
 open KEEP, ">>", "sorted_data.csv" or die "Cannot get the file:($!)";

 my $i = -1;
 my @sort_data = ();
 my $flag = 0;
 my $old_permno = 0;
 my $old_compname = 'aa';
 my $old_year = 0;
 my $old_price = 0.0;
 while ( chomp (my $lines = <FILE>)){
     $flag += 1;
     my @element = split(',', $lines);
     my $permno = $element[0];
     my $date = $element[1];
     my $data_year = substr($date,0,4);
     my $ticker = $element[2];
     my $compname = $element[3];
     my $paydat = $element[4];
     my $distcd = $element[5];
     my $div = $element[6];
     my $facpr = $element[7];
     my $prc = $element[8];
     
	if( $flag == 1){
		$i = 0;
		$old_compname = $compname;
	     $permno_list[$i] = $permno;
	     $comp_list[$i] = $compname;
		$j = $data_year - 1979;
		$total_div = 0.0;
		$old_year = $data_year;
	}
     if($data_year == $old_year){
	     if (isnumber $div){
	         $total_div = $total_div + $div;
	      }
     }
    else if(($data_year != $old_year)||($compname ne $old_compname)){
	   $j = $old_year - 1979;
	   $close_price = $old_price;
	   $sort_data[$i][$j] = $total_div/$close_price;
          if (isnumber $div){
	         $total_div = $div;
	      }
		else{
		$total_div = 0.0;
		}

      	if($compname ne $old_compname){
	     $i += 1;
	     $permno_list[$i] = $permno;
	     $comp_list[$i] = $compname;
        }
     }
     $old_price = $price;
	$old_year = $data_year;
	$old_compname = $compname;
}
#reccord the data for the last year of the last company
$j = $old_year - 1979;
$close_price = $old_price;
$sort_data[$i][$j] = $total_div/$close_price;


for $i (0 .. 35){
	for $j (0 .. 74){
print KEEP "$sort_data[$i][$j],";
}
print KEEP "\n";
}

close FILE;
close KEEP;
