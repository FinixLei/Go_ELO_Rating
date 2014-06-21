# Step 1: get web pages
echo "Get Web pages........";
./GetWeb.sh;
# perl ./GetWeb.pl

 # Step 2: generate ./FocusFinalData.txt
echo "Generate Final Data...";
perl GenFinalData.pl;

# Step 3: Analyze ./FocusFinalData.txt to generate players.txt which is the sorted player list
echo "Analyzing........";
perl Analyze.pl > players.txt;

# Step 4: Compare with the last player list to generate 20130622.txt which contains the trends of the players
echo "Generating new score list.......";
perl GenNewList.pl ./history/20130731.txt ./players.txt  normalMode > ./history/20130802.txt;
perl GenNewList.pl ./history/20130731_debug.txt ./players.txt  debugMode > ./history/20130802_debug.txt;


############## Delta Analyze #####################

# # Step 1: Get Delta Web Pages
# ./GetDeltaWebPages.sh 2
# 
# # Step 2: generate ./FocusFinalData.txt
# echo "Generate Delta Final Data...";
# # perl GenDeltaFinalData.pl;
# 
# ## Step 3: Analyze ./FocusFinalData.txt to generate players.txt which is the sorted player list
# echo "Analyzing........";
# # perl Analyze.pl > players.txt;
# # perl Analyze.pl 2011-01-01 > ./history/20110101.txt;
# # perl Analyze.pl 2012-01-01 > ./history/20120101.txt;
# # perl Analyze.pl 2012-07-01 > ./history/20120701.txt;
# # perl Analyze.pl 2013-01-01 > ./history/20130101.txt;
# # perl Analyze.pl 2013-07-01 > ./history/20130701.txt;
# 
# 
# ## Step 4: Compare with the last player list to generate 20130622.txt which contains the trends of the players
# echo "Generating new score list.......";
# perl GenNewList.pl ./history/20130729.txt ./players.txt  normalMode > ./history/20130731.txt;
# perl GenNewList.pl ./history/20130729_debug.txt ./players.txt  debugMode > ./history/20130731_debug.txt;





##################### Do Predict ###################
# perl Predict.pl ./PredictInput.txt ./history/20130711_debug.txt > PredictResult.txt




############ Generate Old Data ####################
# echo "Analyzing........";
# perl Analyze.pl 2012-12-31 > ./history/20121231.txt;
# perl Analyze.pl 2013-01-01 > ./history/20130101.txt;
# perl GenNewList.pl ./history/20121231.txt ./history/20130101.txt debugMode > ./history/20130101_debug.txt;
# 
# perl Analyze.pl > players.txt; # 0626
# 
# perl GenNewList.pl ./history/20130101_debug.txt ./players.txt  normalMode > ./history/20130626_normal.txt;
# perl GenNewList.pl ./history/20130101_debug.txt ./players.txt  debugMode > ./history/20130626_debug.txt;