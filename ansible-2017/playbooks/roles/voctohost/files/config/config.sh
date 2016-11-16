# FOSDEM vocto config

host=`hostname`

# The next part sucks, I know and I fully intend to rewrite it
# in a few years.

pfx="
aw1120 227.0.0.
aw1121 227.0.1.
aw1124 227.0.2.
aw1125 227.0.3.
aw1126 227.0.4.
h1301 227.1.0.
h1302 227.1.1.
h1308 227.1.2.
h1309 227.1.3.
h2213 227.1.4.
h2214 227.1.5.
h2215 227.1.6.
janson 227.2.0.
k1105 227.3.0.
k3201 227.3.1.
k3401 227.3.2.
k4201 227.3.3.
k4401 227.3.4.
k4601 227.3.5.
ua2114 227.4.0.
ua2220 227.4.1.
ub2252a 227.4.2.
ud2120 227.4.3.
ud2218a 227.4.4.
";

prefix=`echo "$pfx" | grep "$host"|awk '{print $2}'`


# cam is .1, pres is .2
CAM=udp://$pfx.1:9000
PRES=udp://$pfx.2:9000
HOST=$host

#tunables

URLPARAMS='?timeout=10000000&buffer_size=81921024&fifo_size=178481'
RECDIR="/opt/vocto/recordings"

mkdir -p ${RECDIR}
