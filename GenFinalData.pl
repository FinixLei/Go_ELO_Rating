use strict;
use GenData;

my $inFilePath = "./webpages/";
my $rawFinalDataFile = "./midfiles/rawFinalData.txt";
my $finalDataFile = "./midfiles/FinalData.txt";
my $cleanFinalDataFile = "./midfiles/CleanFinalData.txt";
my $focusFinalDataFile = "./FocusFinalData.txt";

##### Main Body #####

print "Handling web pages data......\n";
&GenData::GenRawData($inFilePath, $rawFinalDataFile);
&GenData::GenFirstFinalData($rawFinalDataFile, $finalDataFile);

print "Detect and Fix errors to generate CleanFinalData.....\n";
&GenData::DetectErrorAndGenCleanFinalData($finalDataFile, $cleanFinalDataFile);

print "Do filter and generate the final focus data file ...\n";
&GenData::FilterFinalData($cleanFinalDataFile, $focusFinalDataFile);
