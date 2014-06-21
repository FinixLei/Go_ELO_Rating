i=1;
maxPages=850;

while [ $i -le $maxPages ] 
do
    echo $i;
    wget -q --tries=10 http://www.hoetom.com/matchlatest_2011.jsp?pn=$i -O ./webpages/${i}.txt
    # sleep 1;
    i=$(($i+1));
done