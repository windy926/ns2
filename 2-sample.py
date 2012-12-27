import sys
import os
import random

from math import sqrt

fname = "pkt_solo.tr"
loss_rate = 0.01

cmd = 'ns rtt.tcl %s 100 %f 100ms 28524726' % (fname, loss_rate) 
os.system(cmd)

#analyze the result
inf = open(fname)
pkt_num = 0.0
begin = 0.0
end = 0.0
drop = 0.0

real_cwnd = []
last = 0
count = 0
while True:
	line = inf.readline()
	if line:
		columns = line.split(" ")
		if(columns[0] == "d"):
			drop += 1
		if(columns[0] != "+"):
			continue
		if(begin == 0):
			begin = float(columns[1])
		end = float(columns[1])
		pkt_num += 1
		if(float(columns[1]) > last + 0.1):
			#outf.write(str(count) + "\t" + str(float(columns[1]) - last) + "\n")
			real_cwnd.append(count)
			#print str(count)
			count = 1
			last = float(columns[1])
		else:
			count += 1
	else:
		break
		
print "end time:\t" + str(end)
print "begin time:\t" + str(begin)
print "packet number:\t" + str(pkt_num)
print "drop packet:\t" + str(drop)

rtt = (end-begin) * (end - begin) * 3 / (2 * loss_rate * pkt_num * pkt_num)
rtt = sqrt(rtt)
print rtt

v = 3 * (end-begin) / (2 * rtt * loss_rate * pkt_num)
print v

v /= 0.75

estimate_cwnd = []
l = len(real_cwnd)
cur = (v / 2)
for i in range(0, l):
	estimate_cwnd.append(cur)
	cur = cur + 1
	if(cur > v):
		cur = (v/2)

outf = open("result.txt", "w")		
for i in range(0, l):
	outf.write(str(real_cwnd[i]) + "\t" + str(estimate_cwnd[i]) + "\n")