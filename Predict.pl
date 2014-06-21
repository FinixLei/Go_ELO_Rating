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
                if ($fields[0] !~ /��/ and $fields[2] !~ /��/) {
                    push @pairs, $fields[0];
                    push @pairs, $fields[2]; 
                }
            }
            else {
                if ($fields[$vsIndex-2] !~ /��/ and $fields[$vsIndex+1] !~ /��/) {
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
        $str = "Ԥ�⣺����ʤ����ʤ������Ϊ60%";
    }
    elsif ($loseNum - $winNum < 50) {
        $str = "Ԥ�⣺ʤ�������ɣ�ʤ������Ϊ75%";
    }
    elsif ($loseNum - $winNum < 80) {
        $str = "Ԥ�⣺ʤ�������ɣ�ʤ������Ϊ90%";
    }
    else {
        $str = "Ԥ�⣺ʤ�������ɣ�ʤ�����ʼ���Ϊ100%";
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
                    $result .= "--> $A ��δ��񣬲���Ԥ��\n";
                } 
                else {
                    $index += 2;
                    next;
                }
            }
            elsif (!defined($players{$B})) {
                if ($mode ne "simple") {
                    $result .= "--> $B ��δ��񣬲���Ԥ��\n";
                }
                else {
                    $index += 2;
                    next;
                }
            }
            elsif ($players{$A}->{Num} < $players{$B}->{Num}) {
                $result .= $players{$A}->{Num} . " VS " . $players{$B}->{Num}. "   ";
                $result .= "--> $A ����ʤ����" . &GetPredictString($players{$A}->{Num}, $players{$B}->{Num}) . "\n";
            }
            elsif ($players{$A}->{Num} > $players{$B}->{Num}) {
                $result .= $players{$A}->{Num} . " VS " . $players{$B}->{Num}. "   ";
                $result .= "--> $B ����ʤ����" . &GetPredictString($players{$B}->{Num}, $players{$A}->{Num}) . "\n";
            }
            elsif ($players{$A}->{Num} == $players{$B}->{Num}) {
                if ($mode ne "simple") {
                    $result .= "--> ���ߵȼ�����ͬ������Ԥ�⣡\n";
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
