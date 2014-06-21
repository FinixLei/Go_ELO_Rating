use strict; 

package Utils;

sub CompareDate($$) 
{
    my ($date1, $date2) = @_;
    my @array1 = split(/\-/, $date1);
    my @array2 = split(/\-/, $date2);
    
    my ($year1, $mon1, $day1) = @array1;
    my ($year2, $mon2, $day2) = @array2;
    
    return $year1-$year2 if ($year1 != $year2);
    return $mon1-$mon2 if ($mon1 != $mon2);
    return $day1-$day2 if ($day1 != $day2);
    return 0;
}

1;
