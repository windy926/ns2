import sys
import os
import random

maxIndex = 50
times = 50
step = 10

result = []
outf = open("result.txt", "w")

for i in range(1, maxIndex+1):
	rtt = 0.0
	end_time = i * step
	#fname = "~/tmp/pkt_" + str(i) + ".tr"
	fname = "pkt_" + str(i) + ".tr"
	for j in range(times):
		#run simulator
		cmd = 'ns time.tcl %s %d %f %d' % (fname, end_time, 0.01, random.randint(0, 100000000)) 
		os.system(cmd)

		#analyze the result
		inf = open(fname)
		pkt_num = 0
		begin = 0
		end = 0
		drop = 0
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
		t1 = (end-begin) * (end - begin) * 3 / (2 * 0.01 * pkt_num * pkt_num)
		t2 = (end-begin) * (end - begin) * 3 / (2 * drop  * pkt_num)
		print cmd + ": " + str(t1)# + "\t" + str(t2)
		rtt += t1
	rtt /= times
	result.append(rtt)
	print rtt
	outf.write(str(end_time) + "\t" + str(rtt) + "\n")
	
