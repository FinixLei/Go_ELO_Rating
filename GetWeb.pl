use strict;
use threads;
use Thread::Semaphore;

sub GetWebPages 
{
    my $tid = shift;
    my $start = $tid * 100; 
    my $end = ($tid + 1) * 100 - 1;
    
    my $i = $start;
    while ($i <= $end) {
        my $output_file = "./webpages/$i.txt";
        print "tid is $tid; output file is $output_file\n";
        `wget -q --tries=10 http://www.hoetom.com/matchlatest_2011.jsp?pn=$i -O $output_file`;
        $i ++;
    }
}



my @thread_pool = ();
my $pool_size = 10;
my $tid = 0;
for($tid = 0; $tid < $pool_size; $tid++) {
  push @thread_pool, threads->create('GetWebPages', $tid);
}

for my $thr (@thread_pool) {
  $thr->join();
}
