use strict;

## Usage ##
#  perl Predict.pl ./PredictInput.txt ./history/20130622.txt > PredictResult.txt
#

my ($inFile, $dataFile) = @ARGV;

my %players = ();
my @pairs = ();


sub GetPredictInput()
{
    open(INFILE, "<$inFile") or die "Cannot read $inFile: $!\n";
    
    while(<INFILE>) {
        chmod(my $line = $_);
        $line =~ s/\n$//;
        
        if ($line =~ /.*?VS.*?/) {
        
            my @fields = split /\s+/, $line;
            my $vsIndex = 0;
            foreach (@fields) {
                if (/^VS$/i) {
                    last;
                }
                $vsIndex ++;
            }
            
            if ($vsIndex < 1) { next; }
            elsif ($vsIndex == 1 and defined $fields[2]) {
                if ($fields[0] !~ /队/ and $fields[2] !~ /队/) {
                    push @pairs, $fields[0];
                    push @pairs, $fields[2]; 
                }
            }
            else {
                if ($fields[$vsIndex-2] !~ /队/ and $fields[$vsIndex+1] !~ /队/) {
                    push @pairs, $fields[$vsIndex-2];
                    push @pairs, $fields[$vsIndex+1]; 
                }
            }
        }
    }
    
    # print @pairs;
    close INFILE;
}


sub GetPlayers() 
{
    open(INFILE, "<$dataFile") or die "Cannot read $dataFile: $!\n";
    
    while(<INFILE>) {
        chmod (my $line = $_);
        $line =~ s/\n$//;
        
        my @fields = split /\t/, $line;
        if (scalar @fields < 3) {
            print STDERR "GG Wrong Line: $line\n";
            next;
        }
        
        my ($num, $name, $score) = @fields;
        
        if (!defined($players{$name})) {
            $players{$name}->{Num} = $num;
            $players{$name}->{Score} = $score;
        }
        else {
            print STDERR "Duplicated Name Line: $line\n";
        }
    }
    
    close INFILE;
}

sub GetPredictString($$)
{
    my ($winNum, $loseNum) = @_;
    my $str = "";
    
    if ($loseNum - $winNum < 20) {
        $str = "预测：艰难胜出，胜出概率为60%";
    }
    elsif ($loseNum - $winNum < 50) {
        $str = "预测：胜出较轻松，胜出概率为75%";
    }
    elsif ($loseNum - $winNum < 80) {
        $str = "预测：胜出很轻松，胜出概率为90%";
    }
    else {
        $str = "预测：胜出很轻松，胜出概率几乎为100%";
    }
    
    return $str;
}

sub DoPredict($)
{
    my $mode = shift;
    
    my $size = scalar(@pairs);
    my $index = 0;
    while($index < $size) {
    
        if (defined $pairs[$index+1]) {
            
            my ($A, $B) = ($pairs[$index], $pairs[$index+1]);
            my $result = "$A VS $B    ";
            
            if (!defined($players{$A})) {
                if ($mode ne "simple") {
                    $result .= "--> $A 尚未入榜，不做预测\n";
                } 
                else {
                    $index += 2;
                    next;
                }
            }
            elsif (!defined($players{$B})) {
                if ($mode ne "simple") {
                    $result .= "--> $B 尚未入榜，不做预测\n";
                }
                else {
                    $index += 2;
                    next;
                }
            }
            elsif ($players{$A}->{Num} < $players{$B}->{Num}) {
                $result .= $players{$A}->{Num} . " VS " . $players{$B}->{Num}. "   ";
                $result .= "--> $A 有望胜出！" . &GetPredictString($players{$A}->{Num}, $players{$B}->{Num}) . "\n";
            }
            elsif ($players{$A}->{Num} > $players{$B}->{Num}) {
                $result .= $players{$A}->{Num} . " VS " . $players{$B}->{Num}. "   ";
                $result .= "--> $B 有望胜出！" . &GetPredictString($players{$B}->{Num}, $players{$A}->{Num}) . "\n";
            }
            elsif ($players{$A}->{Num} == $players{$B}->{Num}) {
                if ($mode ne "simple") {
                    $result .= "--> 二者等级分相同，不做预测！\n";
                }
                else {
                    $index += 2;
                    next;
                }
            }
            else { # unexpected case, do nothing. 
            }
            
            print $result, "\n";
        }
        
        $index += 2;
    }

}


## Main Body ##
&GetPredictInput();
&GetPlayers();
&DoPredict("simple");
