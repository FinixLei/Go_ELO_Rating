package Players;

use strict;

my $dataFile = "./FocusFinalData.txt";
my $minGameNum = 30;

sub PrintPlayers($$) 
{
    my ($mode, $players) = @_;
    
    my $playerNum = 0;
    
    # print "GameNumber\tName\t\tScore\tFirstShowDate\n";
    foreach my $name (keys %{$players}) {
    
        if ($players->{$name}->{gameCount} >= $minGameNum) {
            $playerNum ++;
            
            if($mode eq "ALL") {
                print(sprintf("%.2f", $players->{$name}->{score}), "\t");
                print $players->{$name}->{winRate}."\t";
                
                print $name."\t";
                print $players->{$name}->{firstShow}."\t";
                
                print $players->{$name}->{gameCount}." = ".
                      $players->{$name}->{winGame}." + ".
                      $players->{$name}->{loseGame}." + ".
                      $players->{$name}->{drawGame}." + ".
                      $players->{$name}->{unknownGame};
                
                print "\n";
            }
            else # not "ALL" mode
            {
                if($players->{$name}->{gameCount} >= $minGameNum) {
                    print(sprintf("%.2f", $players->{$name}->{score}), "\t");
                    print $name;
                    print "\n";
                }
            }
        }
    }
    
    print "There are $playerNum players!\n";
}

sub PrintSortedPlayers($)
{
    my $players = shift;
    my %finalPlayers = ();
    
    foreach my $name (%$players) {
        if ($players->{$name}->{currentGameNum} >= $minGameNum) {
            $finalPlayers{$name} = $players->{$name}->{score};
        }
    }
  
    my $number = 1;
    my @keys = reverse sort {$finalPlayers{$a} <=> $finalPlayers{$b}} keys(%finalPlayers);
    foreach my $name (@keys) {
        if (defined $finalPlayers{$name}) {
            print $number . "\t" . $name . "\t" . sprintf("%.2f", $finalPlayers{$name}) . "\t" . $players->{$name}->{currentGameNum} . "\n";
        }
        $number ++;
    }
}

sub GetWinRate($)
{
    my $players = shift;
    
    open(INFILE, "<$dataFile") or die("Cannot read $dataFile: $!\n");

    my $ph = "\t";
    while (<INFILE>) {
        chmod(my $line = $_);
        $line =~ s/\n$//;
        
        my @data = split /$ph/, $line;
        if (scalar(@data) <= 6) {
            print STDERR "FF Wrong line: $line\n";
            next;
    }
    
    my ($data, $gameName, $black, $white, $result, $steps) = @data;
    
    if ($result =~ /ºÚ.*?Ê¤/) {
            $players->{$black}->{winGame} ++ if (defined($players->{$black})); 
            $players->{$white}->{loseGame} ++ if (defined($players->{$white}));
        }
        elsif ($result =~ /^°×.*Ê¤/) {
            $players->{$black}->{loseGame} ++ if (defined($players->{$black})); 
            $players->{$white}->{winGame} ++ if (defined($players->{$white}));
        }
        elsif ($result =~ /ºÍÆå/) {
            $players->{$black}->{drawGame} ++ if (defined($players->{$black})); 
            $players->{$white}->{drawGame} ++ if (defined($players->{$white}));
        }
        else {
            $players->{$black}->{unknownGame} ++ if (defined($players->{$black})); 
            $players->{$white}->{unknownGame} ++ if (defined($players->{$white}));
        }
    
    }

    foreach my $name (keys %$players) {
        $players->{$name}->{winRate} = sprintf("%.3f%", 100* $players->{$name}->{winGame} / $players->{$name}->{gameCount});
    }
}

sub InitPlayer($$$)
{
    my ($players, $name, $firstShowDate) = @_;
    
    if (!defined($players->{$name})) {
            $players->{$name} = {
                "firstShow" => $firstShowDate,
                "score" => 2200,
                
                "gameCount" => 1, 
                "winGame" => 0,
                "loseGame" => 0, 
                "drawGame" => 0,
                "unknownGame" => 0, 
                "winrate" => 0, 
                
                # ELO 
                "current_K" => 28, 
                "currentGameNum" => 0,
            };
        }
}

sub GenPlayers($) 
{
    my $players = shift;
    
    open(INFILE, "<$dataFile") or die("Cannot read $dataFile: $!\n");
    
    my $ph = "\t";
    while(<INFILE>) {
    
        my $line = $_;
        my @data = split /$ph/, $line;
        
        if (scalar(@data) < 6) {
            print STDERR "A Wrong Line: $line\n";
            next;
        }
        
        my ($firstShowDate, $gameName, $black, $white, $result, $steps) = @data;
        
        if (!defined($players->{$black})) {
            &InitPlayer($players, $black, $firstShowDate);
        } 
        else {
            $players->{$black}->{gameCount} ++;
        }
        
        if (!defined($players->{$white})) {
            &InitPlayer($players, $white, $firstShowDate);
        } 
        else {
            $players->{$white}->{gameCount} ++;
        }
    
    }
    
    close(INFILE);
    
    # Set the win - lose - draw - unknown game numbers
    &GetWinRate($players);
}

1;
