check port đã hoạt động chưa:

    netstat -plntu | grep 3000
nếu chưa hoặc bị fw chặn:
    
    ufw allow 3000

byobu new windows + command:

    j=1 ;for i in 85 72 82 73 69; do byobu new-window -n vm$j ssh ubuntu@192.168.54.$i -t 'sudo -s'; (( j += 1 ));done
