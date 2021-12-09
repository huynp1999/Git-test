vi /root/chrony.sh
for i in {1..10}; do chronyc -a makestep; sleep 2; done

vi /etc/systemd/system/chrony.service
[Unit]
Description="Makestep chrony"
Requires=network-online.target
After=network-online.target

[Service]
User=root
Group=root
PrivateTmp=yes
PrivateDevices=yes
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=bash /root/chrony.sh
Restart=on-failure
RestartSec=5
TimeoutStopSec=30
StartLimitBurst=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target

systemctl daemon-reload
systemctl restart chrony.service
systemctl enable chrony.service
systemctl status chrony.service
date
