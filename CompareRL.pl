# 给定A、B、C三个集合：
# 1. 前10、20、30、50、100里，两两有多少交集？
#    
# 2. 先以N版等级分为准，对每一名棋手，列出在其他2版等级分中的差异，比如：
#       N版     L版    S版
#    1. 时越    +4     +2
#    
#    然后用所有100人的绝对值之和来表示相差程度。   
#    若遇到某人在N版出现，而在L或S版未出现，则标记为NoneShow
#    
#    再以L版等级分为准，做类似计算. 这样三个等级分只要计算2次：
#       L版     N版    S版
#    1. 周睿羊  +8     +4
#    

use strict;
use Data::Dumper;

my ($ref_N_Num2Name, $ref_N_Name2Num) = (undef, undef);
my ($ref_L_Num2Name, $ref_L_Name2Num) = (undef, undef);
my ($ref_S_Num2Name, $ref_S_Name2Num) = (undef, undef);

sub read_rankinglist
{
    my $inFile = shift;
    my %num2Name = ();
    my %name2Num = ();
    
    open INFILE, "<$inFile" or die "Cannot open $inFile. $!\n";
    
    while (<INFILE>) {
        chomp(my $line = $_);
        my @fields = split /\s+/, $line;
        if (scalar(@fields) >= 2 ) {
            $num2Name{$fields[0]} = $fields[1];
            $name2Num{$fields[1]} = $fields[0];
        }
    }
    
    close INFILE;
    return (\%num2Name, \%name2Num);
}

sub get_all_rankinglists 
{
    ($ref_N_Num2Name, $ref_N_Name2Num) = &read_rankinglist("./nmcgw_rankinglist.txt");
    ($ref_L_Num2Name, $ref_L_Name2Num) = &read_rankinglist("./longshare_rankinglist.txt");
    ($ref_S_Num2Name, $ref_S_Name2Num) = &read_rankinglist("./S_rankinglist.txt");
}


sub get_range_difference
{
    my $range = shift;
    
    # Compare N and L first
    my $sameCount = 0;
    my $index = 1;
    my $differencePercentage = 0;
    for ($index = 1; $index <= $range; $index ++) {
        
        my $name2NumInAnother = $ref_N_Name2Num->{$ref_L_Num2Name->{$index}};
        if (defined($name2NumInAnother) and $name2NumInAnother <= $range) {
            $sameCount ++;
        }
    }
    $differencePercentage = ($range - $sameCount) / $range * 100;
    $differencePercentage = sprintf("%.1f", $differencePercentage);
    my $print_str = "For top " . $range . ", N and L has the same " . $sameCount . " people. The difference percentage is $differencePercentage\%\n";
    print $print_str;
    print OUTFILE "前$range名中，nm版 和 龙版 相同的人数是 $sameCount 人，不同率为 $differencePercentage\%\n";
    
    # Compare N and S then
    $sameCount = 0;
    $index = 1;
    $differencePercentage = 0;
    for ($index = 1; $index <= $range; $index ++) {
        
        my $name2NumInAnother = $ref_N_Name2Num->{$ref_S_Num2Name->{$index}};
        if (defined($name2NumInAnother) and $name2NumInAnother <= $range) {
            $sameCount ++;
        }
    }
    $differencePercentage = ($range - $sameCount) / $range * 100;
    $differencePercentage = sprintf("%.1f", $differencePercentage);
    $print_str = "For top " . $range . ", N and S has the same " . $sameCount . " people. The difference percentage is $differencePercentage\%\n";
    print $print_str;
    print OUTFILE "前$range名中，nm版 和 随版 相同的人数是 $sameCount 人，不同率为 $differencePercentage\%\n";
    
    # Compare L and S then
    $sameCount = 0;
    $index = 1;
    $differencePercentage = 0;
    for ($index = 1; $index <= $range; $index ++) {
        
        my $name2NumInAnother = $ref_L_Name2Num->{$ref_S_Num2Name->{$index}};
        if (defined($name2NumInAnother) and $name2NumInAnother <= $range) {
            $sameCount ++;
        }
    }
    $differencePercentage = ($range - $sameCount) / $range * 100;
    $differencePercentage = sprintf("%.1f", $differencePercentage);
    $print_str = "For top " . $range . ", L and S has the same " . $sameCount . " people. The difference percentage is $differencePercentage\%\n\n";
    print $print_str;
    print OUTFILE "前$range名中，随版 和 龙版 相同的人数是 $sameCount 人，不同率为 $differencePercentage\%\n\n";
}


sub get_diff_num
{
    my $range = shift;
    
    my ($total_N, $total_L, $total_S) = (0, 0, 0);
    my ($total_noshow_N, $total_noshow_L, $total_noshow_S) = (0, 0, 0);

    # Set N as standard first
    my $index = 1;
    for ($index = 1; $index <= $range; $index ++) {
    
        my ($diff_L, $diff_S) = (undef, undef);
        
        my $num_L = $ref_L_Name2Num->{$ref_N_Num2Name->{$index}};
        if (defined($num_L) and $num_L <= $range) {
            $diff_L = $num_L - $index;
            $total_L += abs($diff_L);
        }
        else {
            $diff_L = "NoShow";
            $total_noshow_L ++;
        }
        
        my $num_S = $ref_S_Name2Num->{$ref_N_Num2Name->{$index}};
        if (defined($num_S) and $num_S <= $range) {
            $diff_S = $num_S - $index;
            $total_S += abs($diff_S);
        }
        else {
            $diff_S = "NoShow";
            $total_noshow_S ++;
        } 
        $diff_L = "+".$diff_L if ($diff_L > 0);
        $diff_S = "+".$diff_S if ($diff_S > 0);
        print OUTFILE "$index\t" . $ref_N_Num2Name->{$index} . "\t$diff_L\t$diff_S\n";
    }
    print "Take nmcgw rankinglist as standard:\n";
    print "Total Diff L of top $range is: $total_L; There are $total_noshow_L No Show. \n";
    print "Total Diff S of top $range is: $total_S; There are $total_noshow_S No Show. \n";
    print "---------------------------------------------------------------------------------------------\n\n";
    print OUTFILE "以nm等级分为标准:\n";
    print OUTFILE "对前$range名棋手，龙版与nm版差异量为: $total_L; 共有$total_noshow_L人未在龙版前$range名出现. \n";
    print OUTFILE "对前$range名棋手，随版与nm版差异量为: $total_S; 共有$total_noshow_S人未在随版前$range名出现. \n";
    print OUTFILE "---------------------------------------------------------------------------------------------\n\n";
     
    # Set L as standard first
    ($total_N, $total_L, $total_S) = (0, 0, 0);
    ($total_noshow_N, $total_noshow_L, $total_noshow_S) = (0, 0, 0);
    my $index = 1;
    for ($index = 1; $index <= $range; $index ++) {
    
        my ($diff_N, $diff_S) = (undef, undef);
        
        my $num_N = $ref_N_Name2Num->{$ref_L_Num2Name->{$index}};
        if (defined($num_N) and $num_N <= $range) {
            $diff_N = $num_N - $index;
            $total_N += abs($diff_N);
        }
        else {
            $diff_N = "NoShow";
            $total_noshow_N ++;
        }
        
        my $num_S = $ref_S_Name2Num->{$ref_L_Num2Name->{$index}};
        if (defined($num_S) and $num_S <= $range) {
            $diff_S = $num_S - $index;
            $total_S += abs($diff_S);
        }
        else {
            $diff_S = "NoShow";
            $total_noshow_S ++;
        } 
        
        $diff_N = "+".$diff_N if ($diff_N > 0);
        $diff_S = "+".$diff_S if ($diff_S > 0);
        print OUTFILE "$index\t" . $ref_L_Num2Name->{$index} . "\t$diff_N\t$diff_S\n";
    }
    print "Take longshare rankinglist as standard:\n";
    print "Total Diff N of top $range is: $total_N; There are $total_noshow_N No Show. \n";
    print "Total Diff S of top $range is: $total_S; There are $total_noshow_S No Show. \n";
    print "---------------------------------------------------------------------------------------------\n\n";
    print OUTFILE "以龙版等级分为标准:\n";
    print OUTFILE "对前$range名棋手，nm版与龙版差异量为: $total_N; 共有$total_noshow_N人未在nm版前$range名出现. \n";
    print OUTFILE "对前$range名棋手，随版与龙版差异量为: $total_S; 共有$total_noshow_S人未在随版前$range名出现. \n";
    print OUTFILE "---------------------------------------------------------------------------------------------\n\n";
    
    # Set S as standard first
    ($total_N, $total_L, $total_S) = (0, 0, 0);
    ($total_noshow_N, $total_noshow_L, $total_noshow_S) = (0, 0, 0);
    my $index = 1;
    for ($index = 1; $index <= $range; $index ++) {
    
        my ($diff_N, $diff_L) = (undef, undef);
        
        my $num_N = $ref_N_Name2Num->{$ref_S_Num2Name->{$index}};
        if (defined($num_N) and $num_N <= $range) {
            $diff_N = $num_N - $index;
            $total_N += abs($diff_N);
        }
        else {
            $diff_N = "NoShow";
            $total_noshow_N ++;
        }
        
        my $num_L = $ref_L_Name2Num->{$ref_S_Num2Name->{$index}};
        if (defined($num_L) and $num_L <= $range) {
            $diff_L = $num_L - $index;
            $total_L += abs($diff_L);
        }
        else {
            $diff_L = "NoShow";
            $total_noshow_L ++;
        } 
        
        $diff_N = "+".$diff_N if ($diff_N > 0);
        $diff_L = "+".$diff_L if ($diff_L > 0);
        print OUTFILE "$index\t" . $ref_S_Num2Name->{$index} . "\t$diff_N\t$diff_L\n";
    }
    print "Take suibianxiaxia rankinglist as standard:\n";
    print "Total Diff N of top $range is: $total_N; There are $total_noshow_N No Show. \n";
    print "Total Diff L of top $range is: $total_L; There are $total_noshow_L No Show. \n";
    print "---------------------------------------------------------------------------------------------\n\n";
    print OUTFILE "以随版等级分为标准:\n";
    print OUTFILE "对前$range名棋手，nm版与随版差异量为: $total_N; 共有$total_noshow_N人未在nm版前$range名出现. \n";
    print OUTFILE "对前$range名棋手，龙版与随版差异量为: $total_S; 共有$total_noshow_S人未在龙版前$range名出现. \n";
    print OUTFILE "---------------------------------------------------------------------------------------------\n\n";
}


#####################
# Main
#####################

my $outFile = "./test_output.txt";
open(OUTFILE, ">$outFile") or die "Cannot open $outFile: $!\n";
    
&get_all_rankinglists();

# &get_range_difference(10);
# &get_range_difference(20);
# &get_range_difference(30);
# &get_range_difference(50);
# &get_range_difference(100);
# print OUTFILE "###########################################################\n\n";
# 
# &get_diff_num(20);
&get_diff_num(50);
# &get_diff_num(100);

close OUTFILE;

