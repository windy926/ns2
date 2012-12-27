import sys
import os
import random

times = 10

result = []
outf = open("result.txt", "w")

loss_rate = 0.001
for j in range(times):
	#run simulator
	fname = "pkt_" + str(j) + ".tr"
	cmd = 'ns time.tcl %s %d %f %d' % (fname, 200, loss_rate, random.randint(0, 100000000)) 
	os.system(cmd)

	#analyze the result
	inf = open(fname)
	pkt_num = 0.0
	begin = 0.0
	end = 0.0
	drop = 0.0
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
		else:
			break
	t1 = (end-begin) * (end - begin) * 3 / (2 * loss_rate * pkt_num * pkt_num)
	t2 = (end-begin) * (end - begin) * 3 / (2 * drop  * pkt_num)
	print cmd + ": " + str(t1)# + "\t" + str(t2)
	
