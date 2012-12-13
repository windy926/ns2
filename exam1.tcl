set ns [new Simulator]
set tracefd [open example1.tr w]
$ns trace-all $tracefd
set namtracefd [open example1.nam w]
$ns namtrace-all $namtracefd
proc finish {} {
	global ns tracefd namtracefd
	$ns flush-trace
	close $tracefd
	close $namtracefd
	exec nam example1.nam &
	exit 0
}
set n0 [$ns node]
set n1 [$ns node]
$ns duplex-link $n0 $n1 1Mb 10ms DropTail
set udp0 [new Agent/UDP]
$ns attach-agent $n0 $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 500
$cbr0 set intrval_ 0.005
$cbr0 attach-agent $udp0
set null0 [new Agent/Null]
$ns attach-agent $n1 $null0
$ns connect $udp0 $null0
$ns at 0.5 "$cbr0 start"
$ns at 4.5 "$cbr0 stop"
$ns at 5.0 "finish"
$ns run
