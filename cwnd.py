import sys

inf = open(sys.argv[1])
outf = open("ana_" + sys.argv[1], "w")

last = 0
count = 0

begin = 0
end = 0
pkt_num = 0
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
		if(float(columns[1]) > last + 0.1):
			outf.write(str(count) + "\n")
			#print str(count)
			count = 1
			last = float(columns[1])
		else:
			count += 1
	else:
		break

print end
print begin
print pkt_num		
begin = 1.8
rtt = (end-begin) * (end - begin) * 3 / (2 * 0.001 * pkt_num * pkt_num)
print rtt
