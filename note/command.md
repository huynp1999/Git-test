check port:

    netstat -plntu | grep 3000
    ufw allow 3000

byobu new windows + command:

    j=1 ;for i in 85 72 82 73 69; do byobu new-window -n vm$j ssh ubuntu@192.168.54.$i -t 'sudo -s'; (( j += 1 ));done
    
ceph-deploy osd create:

    for i in `cat /etc/hosts | grep ceph| awk '{print $2}'`; do for j in b c; do ceph-deploy osd create --data /dev/vd$j $i; done; done

mount.nfs: Stale file handle

    umount /mnt
