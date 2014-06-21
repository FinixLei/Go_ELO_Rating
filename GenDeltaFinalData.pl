use strict;
use GenData;

my $inFilePath = "./webpages_delta/";
my $deltaDataFile = "./midfiles/DeltaData.txt";
my $finalDataFile = "./midfiles/FinalData.txt";
my $tmpFinalDataFile = "./midfiles/tmpFinalData.txt";
my $cleanFinalDataFile = "./midfiles/CleanFinalData.txt";
my $focusFinalDataFile = "./FocusFinalData.txt";

##### Main Body #####

print "Handling Delta web pages data......\n";
&GenData::GenRawData($inFilePath, $deltaDataFile);

print "Merge original FinalData.txt and DeltaData.txt to tmpFinalData.txt....\n";
&GenData::MergeFinalDataAndDeltaData($finalDataFile, $deltaDataFile, $tmpFinalDataFile); 

print "Detect and Fix errors to generate CleanFinalData.txt.....\n";
&GenData::DetectErrorAndGenCleanFinalData($tmpFinalDataFile, $cleanFinalDataFile);

print "Do filter and generate the final focus data file ...\n";
&GenData::FilterFinalData($cleanFinalDataFile, $focusFinalDataFile);

