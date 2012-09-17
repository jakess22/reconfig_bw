#!/usr/bin/perl

use warnings;

$jobFile = "joblist.csv";       # used for most tests
$oneJobFile = "onejob.csv";    # just one long-running job for job kill tests
$jobLog = "job.log";
$faultLog = "fault.log";
$symptomLog = "error.log";
$testLog = "test.log";
$cleancmd = "rm $jobLog $faultLog $symptomLog $jobFile.time $oneJobFile.time $testLog 2> /dev/null";
$xmlDir = "xml";
$SSTloc = "../../../core";
$SSTargs = " --verbose --sdl-file=";

open JOBLOG, $jobFile;
1 while <JOBLOG>;
$numJobs = $. - 1;
close JOBLOG;

system( $cleancmd );


# testing with no faults


system( "echo \"testing with $xmlDir/4.nofaults.xml\n\" > $testLog" );
system( "$SSTloc/sst.x $SSTargs$xmlDir/4.nofaults.xml >> $testLog" );

die "Test 1 failed, fault[s] were generated.  See $testLog\n" if -e $faultLog;
die "Test 1 failed, symptom[s] were generated.  See $testLog\n" if -e $symptomLog;

open JOBLOG, $jobLog;
1 while <JOBLOG>;
die "Test 1 failed, not all jobs ran/completed.  See $testLog\n" if $. != 2*$numJobs; 
close JOBLOG;

print "test 1 passed\n";

system( $cleancmd );


# test with fault on one leaf node


system( "echo \"testing with $xmlDir/4.oneleaffault.xml\n\" > $testLog" );
system( "$SSTloc/sst.x $SSTargs$xmlDir/4.oneleaffault.xml >> $testLog" );

die "Test 2 failed, fault[s] were not generated.  See $testLog\n" unless -s $faultLog;
die "Test 2 failed, symptom[s] were not generated.  See $testLog\n" unless -s $symptomLog;

open JOBLOG, $jobLog;
1 while <JOBLOG>;
die "Test 2 failed, not all jobs ran/completed.  See $testLog\n" if $. != 2*$numJobs; 
close JOBLOG;

open FAULTLOG, $faultLog;
while( <FAULTLOG> ){
  m/[^,]+,([^,]+),[^,]+/;
  die "Test 2 failed, an incorrect node shows faults.  See $testLog\n" if $1 ne "1.1" and $1 ne "host";
}
close FAULTLOG;

open SYMPTOMLOG, $symptomLog;
while( <SYMPTOMLOG> ){
  m/[^,]+,([^,]+),([^,]+)/;
  die "Test 2 failed, an incorrect node shows symptoms.  See $testLog\n" if $1 ne "1.1" and $1 ne "host";
  die "Test 2 failed, a node shows a suppressed symptom.  See $testLog\n" if $2 eq "fault_b";
}
close SYMPTOMLOG;

print "test 2 passed\n";

system( $cleancmd );


# test with hierarcy faults


system( "echo \"testing with $xmlDir/4.oneparentfault.xml\n\" > $testLog" );
system( "$SSTloc/sst.x $SSTargs$xmlDir/4.oneparentfault.xml >> $testLog" );

die "Test 3 failed, fault[s] were not generated.  See $testLog\n" unless -s $faultLog;
die "Test 3 failed, symptom[s] were not generated.  See $testLog\n" unless -s $symptomLog;

open JOBLOG, $jobLog;
1 while <JOBLOG>;
die "Test 3 failed, not all jobs ran/completed.  See $testLog\n" if $. != 2*$numJobs; 
close JOBLOG;

open FAULTLOG, $faultLog;
while( <FAULTLOG> ){
  m/[^,]+,([^,]+),[^,]+/;
  die "Test 3 failed, an incorrect node shows faults.  See $testLog\n" if $1 ne "1.1" and $1 ne "1.2" and $1 ne "2.1" and $1 ne "host";
}
close FAULTLOG;

open SYMPTOMLOG, $symptomLog;
while( <SYMPTOMLOG> ){
  m/[^,]+,([^,]+),([^,]+)/;
  die "Test 3 failed, a leaf shows supressed symptoms.  See $testLog\n" if $1 eq "1.1" and $2 eq "fault_b";
  die "Test 3 failed, a parent shows supressed symptoms.  See $testLog\n" if $1 eq "2.1" and $2 eq "fault_a";
}
close SYMPTOMLOG;

print "test 3 passed\n";

system( $cleancmd );


# test that jobs are killed by a fatal fault - default job kill probability (1)


system( "echo \"testing with $xmlDir/1.leaffault_die_default.xml\n\" > $testLog" );
system( "$SSTloc/sst.x $SSTargs$xmlDir/1.leaffault_die_default.xml >> $testLog" );

die "Test 4 failed, fault[s] were not generated.  See $testLog\n" unless -s $faultLog;
die "Test 4 failed, symptom[s] were not generated.  See $testLog\n" unless -s $symptomLog;

open JOBLOG, $jobLog;
while( <JOBLOG> ){
  die "Test 4 failed, a job wasn't killed by a fatal fault.  See $testLog\n" if $_ =~ /10000000/;       # this should only show up in the log if the job ran correctly
}
die "Test 4 failed, not all jobs ran/completed.  See $testLog\n" if $. != 2; 
close JOBLOG;

print "test 4 passed\n";

system( $cleancmd );


# test that jobs are killed by a fatal fault - probability 1


system( "echo \"testing with $xmlDir/1.leaffault_die_1.xml\n\" > $testLog" );
system( "$SSTloc/sst.x $SSTargs$xmlDir/1.leaffault_die_1.xml >> $testLog" );

die "Test 5 failed, fault[s] were not generated.  See $testLog\n" unless -s $faultLog;
die "Test 5 failed, symptom[s] were not generated.  See $testLog\n" unless -s $symptomLog;

open JOBLOG, $jobLog;
while( <JOBLOG> ){
  die "Test 5 failed, a job wasn't killed by a fatal fault.  See $testLog\n" if $_ =~ /10000000/;       # this should only show up in the log if the job ran correctly
}
die "Test 5 failed, not all jobs ran/completed.  See $testLog\n" if $. != 2; 
close JOBLOG;

print "test 5 passed\n";

system( $cleancmd );


# test that jobs are not killed by nonfatal faults - probability 0


system( "echo \"testing with $xmlDir/1.leaffault_nodie.xml\n\" > $testLog" );
system( "$SSTloc/sst.x $SSTargs$xmlDir/1.leaffault_nodie.xml >> $testLog" );

die "Test 6 failed, fault[s] were not generated.  See $testLog\n" unless -s $faultLog;
die "Test 6 failed, symptom[s] were not generated.  See $testLog\n" unless -s $symptomLog;

open JOBLOG, $jobLog;
$successFlag = 0;
while( <JOBLOG> ){
  $successFlag = 1 if $_ =~ /10000000/;       # this should only show up in the log if the job ran correctly
}
die "Test 6 failed, a job was killed by a nonfatal fault.  See $testLog\n" if $successFlag == 0;
die "Test 6 failed, not all jobs ran/completed.  See $testLog\n" if $. != 2; 
close JOBLOG;

print "test 6 passed\n";

system( $cleancmd );

