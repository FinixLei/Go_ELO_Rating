i=1;
endPage=$1;

while [ $i -le $endPage ] 
do
    echo $i;
    wget -q --tries=10 http://www.hoetom.com/matchlatest_2011.jsp?pn=$i -O ./webpages_delta/${i}.txt
    i=$(($i+1));
done
