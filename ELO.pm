package ELO;

use strict;

sub GetThisGameScore($$$$)
{
    my ($r1, $r2, $K, $W) =@_;
    return $K * ($W - (1 / (1 + 10 ** (($r2-$r1-0)/400)))); 
}

sub AdjustK($$)
{
    my ($score, $currentGameNum) = @_;
    my $value = 40;
    if ($score < 1800)    { $value = 40; } 
    elsif ($score < 1900) { $value = 38 }
    elsif ($score < 2000) { $value = 36; }
    elsif ($score < 2050) { $value = 34; }
    elsif ($score < 2100) { $value = 32; }
    elsif ($score < 2150) { $value = 30; }
    elsif ($score < 2200) { $value = 28; }
    elsif ($score < 2250) { $value = 26; }
    elsif ($score < 2300) { $value = 24; }
    elsif ($score < 2350) { $value = 22; }
    elsif ($score < 2400) { $value = 20; }
    elsif ($score < 2450) { $value = 18; }
    elsif ($score < 2500) { $value = 16; }
    elsif ($score < 2550) { $value = 14; }
    elsif ($score < 2600) { $value = 12; }
    elsif ($score < 2650) { $value = 10; }
    elsif ($score < 2700) { $value = 8; }
    elsif ($score < 2750) { $value = 6; }
    elsif ($score < 2800) { $value = 4; }
    else                 { $value = 3; }
    
    my $factor = 1;
    if ($currentGameNum < 50)     { $factor = 1.1; }
    elsif ($currentGameNum < 100) { $factor = 1.05; }
    else                          { $factor = 1; }
    
    return ($value * $factor);
}

sub GetTimeFactor($$)
{
    my ($date, $latestDate) = @_;
    my @dateArray = split(/\-/, $date);
    my @latestArray = split(/\-/, $latestDate);
    
    my $yearSub = $latestArray[0] - $dateArray[0];
    my $monSub = $latestArray[1] - $dateArray[1];
    my $daySub = $latestArray[2] - $dateArray[2];
    
    my $rc = 1;
    
    if ($yearSub >= 20 ) { $rc = 0.84; }
    if ($yearSub >= 15 ) { $rc = 0.86; }
    elsif ($yearSub >= 10 ) { $rc = 0.89; }
    elsif ($yearSub >= 9 ) { $rc = 0.90; }
    elsif ($yearSub >= 8 ) { $rc = 0.91; }
    elsif ($yearSub >= 7 ) { $rc = 0.92; }
    elsif ($yearSub >= 6 ) { $rc = 0.93; }
    elsif ($yearSub >= 5 ) { $rc = 0.94; }
    elsif ($yearSub >= 4 ) { $rc = 0.95; }
    elsif ($yearSub >= 3 ) { $rc = 0.96; }
    elsif ($yearSub >= 2 ) { $rc = 0.97; }
    elsif ($yearSub >= 1 ) { $rc = 0.98; }
    elsif ($yearSub == 0 and $monSub >= 6) { $rc = 0.99; }
    else  { $rc = 1; }
    
    return $rc;
}

sub GetStrongFactor($$)
{
    my ($gameName, $date) = @_;
    my $strongFactor = 1;
    
    if ($gameName =~ /����/ 
        or (($gameName =~ /BC��/ or $gameName =~ /BC���ÿ�/)and $gameName !~ /����/)
        or $gameName =~ /Ӧ��/
        or $gameName =~ /��ʿͨ/
        or $gameName =~ /����/
        or $gameName =~ /LG��/
        or $gameName =~ /����/
        or $gameName =~ /����/
        or $gameName =~ /���ޱ�/ or $gameName =~ /���޵��ӿ�����/
        or $gameName =~ /�ΰٺ�/
        ) {
           
        if ($gameName =~ /��һ��/
            or $gameName =~ /��1��/
            or $gameName =~ /32ǿ/
            or $gameName =~ /��ʮ��ǿ/) { $strongFactor = 1.02; }
            
        elsif ($gameName =~ /�ڶ���/
               or $gameName =~ /��2��/)   { $strongFactor = 1.06; }
        
        elsif ($gameName =~ /������/ 
            or $gameName =~ /ʮ��ǿ/
            or $gameName =~ /16ǿ/)     { $strongFactor = 1.1; }
            
        elsif ($gameName =~ /��ǿ/ 
            or $gameName =~ /8ǿ/)      { $strongFactor = 1.15; }
            
        elsif ($gameName =~ /��ǿ/ 
            or $gameName =~ /�����/ 
            or $gameName =~ /4ǿ/)      { $strongFactor = 1.2; }
            
        elsif ($gameName =~ /����/)     { $strongFactor = 1.35; }
        
        else                            { $strongFactor = 1; }
    }
    
    elsif ($gameName =~ /Ů��/) {
       $strongFactor = 0.97; 
       if ($gameName =~ /�ձ�/) { 
           $strongFactor = 0.96;
       }
    }
    
    elsif ($gameName =~ /Ԫ��/) {
       $strongFactor = 0.97; 
    }
    
    elsif (/̨��/)   { 
          if ($gameName =~ /����/) { $strongFactor = 1; }
          else                     { $strongFactor = 0.96; }
    }
    
    elsif ($gameName =~ /�ձ�/)   { 
        if ($date > "2000-00-00") {
                if ($gameName =~ /����/) { $strongFactor = 1.05; }
                else                     { $strongFactor = 0.97; }
        }
        else {      $strongFactor = 1;  # �ձ� <= 2000-00-00  
        }
    }
    
    elsif ($gameName =~ /����/) {
        if ($gameName =~ /ʮ��ǿ/
            or $gameName =~ /16ǿ/)     { $strongFactor = 1; }
            
        elsif ($gameName =~ /��ǿ/ 
            or $gameName =~ /8ǿ/)      { $strongFactor = 1.03; }
            
        elsif ($gameName =~ /��ǿ/ 
            or $gameName =~ /�����/ 
            or $gameName =~ /4ǿ/
            or ($gameName =~ /Χ��.*?����/)) { $strongFactor = 1.08; }
            
        elsif ($gameName =~ /����/)     { $strongFactor = 1.2; }
        
        else                            { $strongFactor = 1; }
    }
    
    else { # �й� or �к� or ���� or ���� 

        if ($gameName =~ /ʮ��ǿ/
            or $gameName =~ /16ǿ/)     { $strongFactor = 1.02; }
            
        elsif ($gameName =~ /��ǿ/ 
            or $gameName =~ /8ǿ/)      { $strongFactor = 1.06; }
            
        elsif ($gameName =~ /��ǿ/ 
            or $gameName =~ /�����/ 
            or $gameName =~ /4ǿ/
            or ($gameName =~ /Χ��.*?����/)) { $strongFactor = 1.1; }
            
        elsif ($gameName =~ /����/)     { $strongFactor = 1.25; }
        
        else                            { $strongFactor = 1; }
    }
    
    return $strongFactor;
}

1;
