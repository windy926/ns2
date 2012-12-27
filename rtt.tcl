if {$argc != 5} {
	puts "Usage: rtt.tcl [trace-file] [send-time] [loss-rate] [delay] [seed]"
}

set pkt_fname [lindex $argv 0]
set end_time [lindex $argv 1]
set loss_rate [lindex $argv 2]
set delay [lindex $argv 3]
set seed [lindex $argv 4]

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

$ns duplex-link $n0 $n1 1Gb $delay DropTail
$ns trace-queue $n0 $n1 $f_pkt
$ns queue-limit $n0 $n1 1000000
$ns queue-limit $n1 $n0 1000000

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

set f_cwnd [open cwnd.tr w]
proc Record {} {
	global f_cwnd tcp ns 
	set intval 0.1 
	set now [$ns now] 
	set cwnd [$tcp set cwnd_]
	puts $f_cwnd "$now $cwnd"
	$ns at [expr $now + $intval] "Record" 
} 

$ns at 0.1 "Record" 

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
