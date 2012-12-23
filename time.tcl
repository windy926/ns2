if {$argc != 4} {
	puts "Usage: time.tcl [trace-file] [send-time] [loss-rate] [seed]"
}

set pkt_fname [lindex $argv 0]
set end_time [lindex $argv 1]
set loss_rate [lindex $argv 2]
set seed [lindex $argv 3]

set ns [new Simulator]

set f_nam [open nam.tr w]
$ns namtrace-all $f_nam
	
set n0 [$ns node]
#n0 config
set tcp [new Agent/TCP/Newreno]
$tcp set fid_ 1
$tcp set window_ 8000000
$tcp set packetSize_ 1024

$ns attach-agent $n0 $tcp

set ftp [new Application/FTP]
$ftp set type_ FTP
$ftp attach-agent $tcp

set n1 [$ns node]
#n1 config
set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink

set f_pkt [open $pkt_fname w]

$ns duplex-link $n0 $n1 1Gb 200ms RED
$ns trace-queue $n0 $n1 $f_pkt
$ns queue-limit $n0 $n1 1000000
Queue/RED thresh_ 100
Queue/RED maxthresh_ 1000
Queue/RED linterm_ 10

global defaultRNG 
$defaultRNG seed $seed

set lossModule [new ErrorModel]
$lossModule set rate_ $loss_rate
set lossVar [new RandomVariable/Uniform]
$lossVar set min_ 0.0
$lossVar set max_ 1.0
$lossModule ranvar $lossVar
$lossModule drop-target [new Agent/Null]

$ns lossmodel $lossModule $n0 $n1


$ns connect $tcp $sink

proc finish {} {
	global f_nam f_pkt ns
	$ns flush-trace
	close $f_nam
	close $f_pkt
#	exec nam nam.tr &
	exit 0
}

$ns at 1.0 "$ftp start"
$ns at [expr $end_time + 1] "$ftp stop"

$ns at [expr $end_time + 2] "finish"

$ns run
