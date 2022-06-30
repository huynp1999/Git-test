check port đã hoạt động chưa:

    netstat -plntu | grep 3000
nếu chưa hoặc bị fw chặn:
    
    ufw allow 3000

byobu new windows + command:

    byobu new-window -n vm1 ssh ubuntu@192.168.54.85 -t 'sudo -s'
