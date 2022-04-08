alias terminator='IBUS_NO_SNOOPER_APPS=python2 terminator'
function scr() { bash /home/huy/sc.sh $@; }

if [ "$1" = "-i" ]; then
	/home/huy/Downloads/IPMIView_2.19.0_build.210401_bundleJRE_Linux_x64/IPMIView20

elif [ "$1" = "-r" ]; then
	rclone copy /home/huy/note/ remote:LinuxDocs

elif [ "$1" = "-d" ]; then
	for i in {61..90}; do ssh-keygen -f "/home/huy/.ssh/known_hosts" -R "192.168.54.$i"; done

else
	ssh ubuntu@192.168.54.$1 'sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/'
	ssh -A -t root@192.168.54.$1 'byobu; bash -l'
fi
