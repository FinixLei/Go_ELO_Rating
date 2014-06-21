use strict; 

my ($oldData, $newData, $mode) = @ARGV;
my $ph = "\t";
my %players = ();


sub SortPlayers($)
{
    my $playersInfo = shift;
    my %info = ();
    
    foreach (@$playersInfo) {
        chmod(my $line = $_);
        my @fields = split $ph, $line; 
        my $num = $fields[0]; 
        $info{$num} = $line;
    }
    
    # my @numbers = sort(sub{$a<=>$b;}, keys(%info));
    foreach my $key (sort {$a<=>$b;} keys(%info)) {
        print $info{$key}, "\n";
    }
}

sub PrintPlayers
{
    my $mode = shift;
    my @playerArray = ();
    foreach my $name (keys %players) {
        my $info = $players{$name}->{newNum} . "\t" . $name . "\t" . 
                   $players{$name}->{newScore} . "\t" . $players{$name}->{numChange} . "\t" . 
                   $players{$name}->{scoreChange};
                   
        if ($mode eq "debugMode") {
            if ($players{$name}->{gameNumChange} >= 0) {
                $info .= "\t" . $players{$name}->{gameNum} . "\t" .
                         "(+" . $players{$name}->{gameNumChange} . ")";
            }
            else {
                $info .= "\t" . $players{$name}->{gameNum} . "\t" .
                         "(" . $players{$name}->{gameNumChange} . ")";
            }
        } 
        push @playerArray, $info if (defined($players{$name}->{scoreChange}) and defined ($players{$name}->{numChange}));
    }
    
    my @playersInfo = ();
    foreach my $item (sort {$a<=>$b} @playerArray) {
        push @playersInfo, $item;
    }
    
    &SortPlayers(\@playersInfo);
}

sub GetOldData 
{
    open(INFILE, "<$oldData") or die "Cannot read $oldData: $!\n";
    
    while(<INFILE>) {
        chmod (my $line = $_);
        $line =~ s/\n$//;
        
        my @fields = split $ph, $line;
        if (scalar @fields < 3) {
            print STDERR "DD Wrong Line: $line\n";
            next;
        }
        
        my ($num, $name, $score, $lastNumChange, $lastScoreChange, $oldGameNum) = @fields;
        
        if (!defined($players{$name})) {
            $players{$name}->{oldNum} = $num;
            $players{$name}->{oldScore} = $score;
            $players{$name}->{oldGameNum} = $oldGameNum;
        }
        else {
            print STDERR "Duplicated Name Line: $line\n";
        }
    }
    
    close INFILE;
}

sub GetNewData
{
    open(INFILE, "<$newData") or die "Cannot read $newData: $!\n";
    
    while(<INFILE>) {
        chmod (my $line = $_);
        $line =~ s/\n$//;
        
        my @fields = split $ph, $line;
        if (scalar @fields < 3) {
            print STDERR "EE Wrong Line: $line\n";
            next;
        }
        
        my ($num, $name, $score, $gameNum) = @fields;
        
        if (defined($players{$name})) {
            $players{$name}->{newNum} = $num;
            $players{$name}->{newScore} = $score;
            $players{$name}->{scoreChange} = sprintf("%.2f", $players{$name}->{newScore} - $players{$name}->{oldScore});
            $players{$name}->{numChange} = $players{$name}->{oldNum} - $players{$name}->{newNum};
            $players{$name}->{gameNum} = $gameNum;
            $players{$name}->{gameNumChange} = $players{$name}->{gameNum} - $players{$name}->{oldGameNum};
        }
        else {
            $players{$name}->{newNum} = $num;
            $players{$name}->{newScore} = $score;
            $players{$name}->{scoreChange} = "---";
            $players{$name}->{numChange} = "Èë°ñ";
            $players{$name}->{gameNum} = $gameNum;
            $players{$name}->{gameNumChange} = 0;
        }
        
        if ($players{$name}->{numChange} != "Èë°ñ") {
            if ($players{$name}->{numChange} > 0) {
                $players{$name}->{numChange} = "+" . $players{$name}->{numChange};
            }
            elsif ($players{$name}->{numChange} == 0) {
                $players{$name}->{numChange} = "---";
            }
            else { # Do nothing.
            }
        }
        
        if ($players{$name}->{scoreChange} != "---") {
            if ($players{$name}->{scoreChange} > 0) {
                $players{$name}->{scoreChange} = "+" . $players{$name}->{scoreChange};
            }
            else { # Do nothing.
            }
        }
    }
    
    close INFILE;
}


&GetOldData();
&GetNewData();
&PrintPlayers($mode);
