package GenData;

use strict;
use Utils;



my $oldestDate = "1921-00-00";
my $latestDate = "2050-01-01";
my $ph = "\t";
my $fixedFieldNumber = 6;


# Generate Raw data: rawFinalData.txt
sub GenRawData($)
{
    my ($inFilePath, $tmpFinalDataFile) = @_;
    
    opendir(DIR, $inFilePath) or die "Can not open $inFilePath. $!\n";
    open(FINALOUT, ">$tmpFinalDataFile") or die("Cannot write to $tmpFinalDataFile: $!\n");
    
    my @allItems=grep(!/^\.\.?$/,readdir(DIR)); 
    
    my $count = 1;
    foreach(@allItems) {
        my $inFileName = $_;
        my $inFile = $inFilePath.$inFileName;
        
        open(INFILE, $inFile) or die("Cannot read $inFile: $!\n");
        
        my @lineSet = ();
        
        my $flag = "OUTSECTION";
        while(<INFILE>) {
        
            my $line = $_;
            
            if ($line =~ /^\t\<tr\>/ and $line !~ /\<\/tr\>/ and $flag eq "OUTSECTION") {
                $flag = "INSECTION";
            }
            
            if ($line =~ /^\s*\<\/tr\>/ and $line !~ /\<tr\>/ and $flag eq "INSECTION") {
                $flag = "OUTSECTION";
                push @lineSet, '#';
            }
            
            if ($flag eq "INSECTION") {
                $line =~ s/\<.*?\>//g;    
                if ($line !~ /^\s*$/ and $line !~ /&nbsp/) {
                    $line =~ s/\s*//g;
                    push @lineSet, $line;
                }
            }
        
        }
        
        close(INFILE);
        
        my $placeholder = "\t";
        my $longLine = join $placeholder, @lineSet;
        my @newLineSet  = split '#', $longLine;
        foreach (@newLineSet) {
            my $newLine = $_;
            $newLine =~ s/^\s+//;
            $newLine =~ s/\s+$//;
            my @tmpArray = split /$placeholder/, $newLine;
            if (scalar(@tmpArray) >= 5) {
                $tmpArray[2] =~ s/(.*?)\-(.*?)/${1}${placeholder}${2}/;
                $newLine = join $placeholder, @tmpArray;
                print FINALOUT $newLine, "\n";
            }
        }
        
        $count++;
    }
    
    close(FINALOUT);
    closedir(DIR);
}


# Generate FinalData.txt or DeltaFinalData.txt under ./midfiles
sub GenFirstFinalData() 
{
    my ($tmpFinalDataFile, $finalDataFile) = @_;
    
    my @dataLines = ();
    open(INFILE, "<$tmpFinalDataFile") or die "Cannot read $tmpFinalDataFile: $!\n";
    while(<INFILE>){
    
        chmod(my $line = $_);
        $line =~ s/\n$//;
        push @dataLines, $line;  
    } 
    close(INFILE);
    
    open(OUTFILE, ">", $finalDataFile) or die "Cannot write $finalDataFile: $!\n";
    foreach my $row (sort {$a cmp $b} @dataLines) {
    
        my @fields = split /$ph/, $row;
        
        # Filter out wrong lines
        if (scalar(@fields) != $fixedFieldNumber) {
            print STDERR "BB Wrong Line: $row\n";
            next;
        }
        
        print OUTFILE $row, "\n";
    }
    close(OUTFILE);
    
    # unlink($tmpFinalDataFile);
}

# Detect and fix errors 
sub DetectErrorAndGenCleanFinalData 
{
    my ($inputFile, $outputFile) = @_;
    my $fixedFieldsNum = 6;
    
    open(INPUT, "<$inputFile") or die "Cannot open $inputFile: $!\n";
    open(OUTPUT, ">$outputFile") or die "Cannot write $inputFile: $!\n";
    
    my $lineNum = 1;
    my $thisLine = <INPUT>;
    if (defined $thisLine) {
        my $nextLine = "";
        my @thisLineFields = ();
        my @nextLineFields = ();
        
        while (<INPUT>) {
            $nextLine = $_;
            
            @thisLineFields = split /\s+/, $thisLine;
            @nextLineFields = split /\s+/, $nextLine;
            
            if (scalar @thisLineFields != $fixedFieldsNum) {
                print "Wrong Line $lineNum: $thisLine\n";
            }
            
            my $i = 0;
            # 0 means the same
            my $flag = 0;
            # Don't compare the last field
            for ($i = 0; $i < $fixedFieldsNum-1; $i++) {
                if ($thisLineFields[$i] cmp $nextLineFields[$i]) {
                    $flag = 1;
                    last;
                }
            }
            
            # If more than 2 lines are the same, always record the last one only
            # Also, all the line numebrs will be printed out. 
            if (!$flag) {
                print STDERR "Line $lineNum: the basic information of this line is the same as next line's. \n";
            }
            else {
                
                # Filter out older or future games
                if (Utils::CompareDate($thisLineFields[0],$oldestDate) < 0 or Utils::CompareDate($thisLineFields[0], $latestDate) > 0) {
                    # Do nothing;
                }
                else {
                    if (length $thisLineFields[0] > 10) {# time is fixed lenght - 10
                        $thisLineFields[0] = substr($thisLineFields[0], 0, 10);
                    }
                    
                    $thisLine = join "\t", @thisLineFields;
                
                    my $result = 0;
                    if ($thisLineFields[4] =~ /黑.*?胜/)    { $result = 1; }
                    elsif ($thisLineFields[4] =~ /白.*?胜/) { $result = 2; }
                    elsif ($thisLineFields[4] =~ /和棋/)    { $result = 0; }
                    else { $result = -1; }
                    
                    my $steps = 0;
                    if ($thisLineFields[5] =~ /(\d+)手/) {
                        $steps = $1;
                    }
                    
                    chomp($thisLine);
                    $thisLine = $thisLine . $ph . $result . $ph . $steps . "\n";
                    print OUTPUT $thisLine;
                }
            }
            
            $thisLine = $nextLine;
            $lineNum ++;
        }
    }
    
    close INPUT;
    close OUTPUT;
}

## Filter Final data to generate ./FocusFinalData.txt
sub FilterFinalData()
{
    my ($inputFile, $outputFile) = @_;    
    my $countGames = 0;
    
    open(INFILE, "<$inputFile") or die("Cannot read $inputFile: $!\n");
    open(OUTFILE, ">$outputFile") or die("Cannot write $outputFile: $!\n");
    
    while(<INFILE>) {
        
        my $line = $_;
        
        my @data = split /$ph/, $line;
        
        # Filter out older or future games
        if (Utils::CompareDate($data[0],$oldestDate) < 0 or Utils::CompareDate($data[0], $latestDate) > 0) {
            next;
        }
        
        # Filter out Internet games
        if ($data[1] =~ /升降级对局/ 
            or $data[1] =~ /\d+友谊对局/ 
            or $data[1] =~ /Tom/i or $data[1] =~ /新浪/ or $data[1] =~ /Sina/i
            or $data[1] =~ /月排行赛/ or $data[1] =~ /网络/ or $data[1] =~ /业余/ or $data[1] =~ /国际城市赛/
            or $data[1] =~ /欧洲/ or $data[1] =~ /东洋生命杯/ or $data[1] =~ /清风/ or $data[1] =~ /弈城/ 
            or $data[1] =~ /爱在地球毁/ or $data[1] =~ /日月杀人狂/ or $data[1] =~ /林之虎/ or $data[1] =~ /bdmaster/
            or $data[1] =~ /一生求道/ or $data[1] =~ /9D/i
            or $data[1] =~ /棋友会/ or $data[1] =~ /风雨会/ or $data[1] =~ /韩国杀手会/
            or $data[1] =~ /多面打/  or $data[1] =~ /围棋会所/
            or $data[1] =~ /黄河杯/ or $data[1] =~ /国学杯/ or $data[1] =~ /晚报杯/ or $data[1] =~ /省运动会/
            or $data[1] =~ /爱国杯/ or $data[1] =~ /IGS/ or $data[1] =~ /KGS/ or $data[1] =~ /熊津杯/ 
            or $data[1] =~ /大学生/ or $data[1] =~ /迎国庆/ or $data[1] =~ /唐门/
            or $data[1] =~ /聂道/ or $data[1] =~ /马道/ or $data[1] =~ /东洋证券杯种子选拔赛/ 
            or $data[1] =~ /中法擂台赛/ or $data[1] =~ /混双/ or $data[1] =~ /春晓指导棋/
            or $data[1] =~ /2004加/ or $data[1] =~ /两岸交流赛/
            ) 
        {
            next;
        }
        
        print OUTFILE $line;
        $countGames++;
        
    }
    
    close INFILE;
    close OUTFILE;
    
    print "There are $countGames games counted.\n";
}


sub MergeFinalDataAndDeltaData
{
    my ($finalDataFile, $deltaDataFile, $outputFile) = @_;
    
    open(FINALDATA, "<$finalDataFile") or die "Cannot open $finalDataFile: $!\n";
    open(DELTADATA, "<$deltaDataFile") or die "Cannot open $deltaDataFile: $!\n";
    open(OUTPUT, ">$outputFile") or die "Cannot open $outputFile: $!\n";
    
    my @finalData = <FINALDATA>;
    my @deltaData = <DELTADATA>;
    
    close FINALDATA;
    close DELTADATA;
    
    my @outputData = (@finalData, @deltaData);
    
    foreach my $row (sort {$a cmp $b} @outputData) {
    
        my @fields = split /$ph/, $row;
        # Filter out wrong lines
        if (scalar(@fields) != $fixedFieldNumber) {
            print STDERR "CC Wrong Line: $row\n";
            next;
        }
        
        print OUTPUT $row;
    }
    
    close OUTPUT;
}

1;