admin="ceph1 ceph2 ceph3"
mon="ceph1 ceph2 ceph3"
mds="ceph1 ceph2 ceph3"
osd="ceph1 ceph2 ceph3"
vd="b c"
version="17.2.1"
os="el8"

for i in $admin; do ssh root@$i 'sed -i -e "s|mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*; sed -i -e "s|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*; sed -i -e "s|baseurl=http://mirror.vccloud.vn|baseurl=http://vault.centos.org|g" /etc/yum.repos.d/CentOS-*'; done
echo "########################################"
echo "DONE fix repo"
echo "########################################"
for i in $admin; do ssh root@$i 'yum install python2 wget -y'; done
yum install python2-pip -y
pip2 install ceph-deploy
echo "########################################"
echo "DONE install python2 pip cephdeploy"
echo "########################################"
mkdir /root/ceph-pkgs
cd /root/ceph-pkgs
wget https://download.ceph.com/rpm-$version/$os/x86_64/ -O index.html
for i in `cat index.html  | grep $version-0.$os.x86_64 | awk -F ">" '{print $2}' | awk -F "<" '{print $1}' | grep -v "debug\|test\|resource\|rbd-fuse\|rbd-nbd\|rbd-mirror\|python34\|rados-objclass\|devel\|cephfs-java\|fuse\|ceph-radosgw\|index.html\|compat\|jni1"`;do wget https://download.ceph.com/rpm-$version/$os/x86_64/${i};done
for i in ceph-mgr-modules-core ceph-volume; do wget https://download.ceph.com/rpm-$version/$os/noarch/$i-$version-0.$os.noarch.rpm
echo "########################################"
echo "DONE download ceph packages"
echo "########################################"
for i in $admin; do scp -r /root/ceph-pkgs root@$i:/root; done
for i in $admin; do ssh root@$i 'yum --nogpgcheck localinstall /root/ceph-pkgs/*.rpm -y'; done
echo "########################################"
echo "DONE install ceph packages on all hosts"
echo "########################################"
mkdir /root/ceph-cluster
cd /root/ceph-cluster
ceph-deploy new $mon
echo "########################################"
echo "DONE new"
echo "########################################"
cat << EOF >> ceph.conf

public_network = 10.5.88.0/22
cluster_network = 10.5.88.0/22
mon_allow_pool_delete = true
EOF
echo "########################################"
echo "DONE config"
echo "########################################"
ceph-deploy mon create-initial
sleep 10
echo "########################################"
echo "DONE mon init"
echo "########################################"
ceph-deploy admin $admin
ceph-deploy mgr create $mon
ceph-deploy mds create $mds
echo "########################################"
echo "DONE admin, mgr and mds"
echo "########################################"
for i in $osd; do for j in $vd; do ssh root@$i "ceph-volume lvm zap /dev/vd$j --destroy"; done; done
for i in $osd; do for j in $vd; do ssh root@$i "wipefs -af /dev/vd$j"; done; done
echo "########################################"
echo "DONE zap all disks"
echo "########################################"
for i in $osd; do for j in $vd; do ceph-deploy osd create --data /dev/vd$j $i; done; done
echo "########################################"
echo "DONE add osds"
echo "########################################"

echo "########################################"
echo "DONE deploy ceph cluster !!!"
echo "########################################"
