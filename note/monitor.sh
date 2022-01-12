mon="vita1 vita2 vita3 vita4 vita5"
osd="vita2 vita3"

if [ "$1" = "-e" ]; then

echo "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEETCD"
etcdctl --write-out=table --endpoints=$ep endpoint status
etcdctl --endpoints=$ep endpoint health
for i in $mon; do ssh root@$i 'echo "===============================$HOSTNAME===========================================================================" && systemctl status etcd > test && tail -2 test'; done

elif [ "$1" = "-m" ]; then

echo "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMON"
for i in $mon; do ssh root@$i 'echo "===============================$HOSTNAME===========================================================================" && systemctl status vitastor-mon > test && tail -2 test'; done

else

act=`etcdctl --endpoints=$ep get --prefix /vitastor/pg/state | grep "active" | wc -l`
deg=`etcdctl --endpoints=$ep get --prefix /vitastor/pg/state | grep "degrade" | wc -l`
mis=`etcdctl --endpoints=$ep get --prefix /vitastor/pg/state | grep "mis" | wc -l`
inc=`etcdctl --endpoints=$ep get --prefix /vitastor/pg/state | grep "incom" | wc -l`
pee=`etcdctl --endpoints=$ep get --prefix /vitastor/pg/state | grep "peering" | wc -l`
echo "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOSD | active=$act | degraded=$deg | misplaced=$mis | incompleted=$inc | peering=$pee"
for i in $osd; do ssh root@$i 'echo "===============================$HOSTNAME===========================================================================" && for i in `cat /root/osd`; do systemctl status $i > test && tail -1 test; done'; done

fi
