set ns [new Simulator]

set f_nam [open nam.tr w]
$ns namtrace-all $f_nam

set f_pkt [open pkt.tr w]
$ns trace-all $f_pkt

set n0 [$ns node]
set n1 [$ns node]

$ns duplex-link $n0 $n1 1Gb 200ms RED
$ns queue-limit $n0 $n1 10000

#n0 config
set tcp [new Agent/TCP/Newreno]
$tcp set fid_ 1
$tcp set window_ 8000
$tcp set packetSize_ 1024

$ns attach-agent $n0 $tcp

set ftp [new Application/FTP]
$ftp set type_ FTP
$ftp attach-agent $tcp

#n1 config
set sink [new Agent/TCPSink]
$ns attach-agent $n1 $sink


$ns connect $tcp $sink


set f_cwnd [open cwnd.tr w]

proc finish {} {
	global f_nam f_pkt f_cwnd ns
	$ns flush-trace
	close $f_nam
	close $f_pkt
	close $f_cwnd
	exec nam nam.tr &
	exit 0
}

proc Record {} {
	global f_cwnd tcp ns
	set intval 0.1
	set now [$ns now]
	set cwnd [$tcp set cwnd_]
	set window [$tcp set window_]
	puts $f_cwnd "$now $cwnd $window"
	$ns at [expr $now + $intval] "Record"
}

$ns at 0.1 "Record"

$ns at 1.0 "$ftp start"
$ns at 10.0 "$ftp stop"

$ns at 13.0 "finish"

$ns run

