    <img src="https://.png" alt="drawing" width="200"/>


    |   |  | |
    | --- |:------:|:-----:|
    |     |      | |
    |     |      | |
    |     |      |
    |     |      |
    |     |      |
    |     |      |
    
    sed -i 's/prohibit-password/yes/g; s/#PermitRootLogin/PermitRootLogin/g;' /etc/ssh/sshd_config && service ssh restart

    cat << EOF >> ceph.conf
    public network = 10.10.10.0/24
    cluster network = 10.10.11.0/24
    osd objectstore = bluestore
    mon_allow_pool_delete = true
    osd pool default size = 3
    osd pool default min size = 1
    EOF
    
  
# Huong dan Git
## Kieu chu
**in dam**
_nghieng_
**_dam nghieng_**
`test markdown`

## List
- text 1
- text 2
1. text 1
2. text 2

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9b/RAID_0.svg/800px-RAID_0.svg.png" alt="drawing" width="200"/>

## Link
[google](google.com)

## Code
```
abc
xyz
123
```
