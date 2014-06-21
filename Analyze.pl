use strict;
use Players;
use ELO;
use Utils;

my $dataFile = "./FocusFinalData.txt";
our %players = ();

my $oldestDate = "1981-00-00";
my $latestDate = "";
if (defined $ARGV[0]) {
    $latestDate = $ARGV[0]; 
}
else {
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon ++;
    $mon = sprintf("%02d", $mon);
    $mday = sprintf("%02d", $mday);
    $latestDate = "$year-$mon-$mday";
}

print STDERR "Latest date is $latestDate\n";

## Get and Init Players Information to %players
Players::GenPlayers(\%players);


# Read and analyze the result
open(INFILE, "<$dataFile") or die("Cannot read $dataFile: $!\n");

my $debugLineNum = 0;
my $ph = "\t";
while (<INFILE>) {
    $debugLineNum ++;
    
    chmod(my $line = $_);
    $line =~ s/\n$//;
    
    my @data = split /$ph/, $line;
    if (scalar(@data) <= 6) {
        print STDERR "AA Wrong line: $line\n";
        next;
    }
   
   my ($date, $gameName, $black, $white, $result, $steps) = @data;  
   
   next if (Utils::CompareDate($date, $oldestDate) < 0 or Utils::CompareDate($date, $latestDate) > 0); 
   
   $players{$black}->{currentGameNum} ++;
   $players{$white}->{currentGameNum} ++;
   
   my $strongFactor = ELO::GetStrongFactor($gameName, $date);
   my $timeFactor = ELO::GetTimeFactor($date, $latestDate);
   
   my $win_finalFactor = $strongFactor * $timeFactor;
   my $lose_finalFactor = 1 / ($strongFactor * $timeFactor);
   
   if ($result =~ /ºÚ.*?Ê¤/) {
       my $blackGet = ELO::GetThisGameScore($players{$black}->{score}, $players{$white}->{score}, $players{$black}->{current_K}, 1);
       my $whiteGet = ELO::GetThisGameScore($players{$white}->{score}, $players{$black}->{score}, $players{$white}->{current_K}, 0);
       $players{$black}->{score} += $win_finalFactor * $blackGet;
       $players{$white}->{score} += $lose_finalFactor * $whiteGet;
       $players{$black}->{current_K} = ELO::AdjustK($players{$black}->{score}, $players{$black}->{currentGameNum} );
       $players{$white}->{current_K} = ELO::AdjustK($players{$white}->{score}, $players{$white}->{currentGameNum} );
   }
   elsif ($result =~ /^°×.*Ê¤/) {
       my $blackGet = ELO::GetThisGameScore($players{$black}->{score}, $players{$white}->{score}, $players{$black}->{current_K}, 0);
       my $whiteGet = ELO::GetThisGameScore($players{$white}->{score}, $players{$black}->{score}, $players{$white}->{current_K}, 1);
       $players{$black}->{score} += $lose_finalFactor * $blackGet;
       $players{$white}->{score} += $win_finalFactor * $whiteGet;
       $players{$black}->{current_K} = ELO::AdjustK($players{$black}->{score}, $players{$black}->{currentGameNum} );
       $players{$white}->{current_K} = ELO::AdjustK($players{$white}->{score}, $players{$white}->{currentGameNum} );
   }
   elsif ($result =~ /ºÍÆå/) {
       my $blackGet = ELO::GetThisGameScore($players{$black}->{score}, $players{$white}->{score}, $players{$black}->{current_K}, 0.5);
       my $whiteGet = ELO::GetThisGameScore($players{$white}->{score}, $players{$black}->{score}, $players{$white}->{current_K}, 0.5);
       $players{$black}->{score} += $blackGet;
       $players{$white}->{score} += $whiteGet;
       $players{$black}->{current_K} = ELO::AdjustK($players{$black}->{score}, $players{$black}->{currentGameNum} );
       $players{$white}->{current_K} = ELO::AdjustK($players{$white}->{score}, $players{$white}->{currentGameNum} );
   }
   else {
       # unknown, do nothing 
   }
}

close(INFILE);

#Players::PrintPlayers("notAll", \%players);
Players::PrintSortedPlayers(\%players);
