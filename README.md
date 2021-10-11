    <img src="https://.png" alt="drawing" width="200"/>


    |   |  | |
    | --- |:------:|:-----:|
    |     |      | |
    |     |      | |
    |     |      |
    |     |      |
    |     |      |
    |     |      |
    
    sed -i 's/prohibit-password/yes/g; s/#PermitRootLogin/PermitRootLogin/g;' /etc/ssh/sshd_config && systemctl restart ssh[d]
    
    useradd ansibledeploy; echo '123' | passwd ansibledeploy --stdin
    echo "ansibledeploy ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ansibledeploy
    chmod 0440 /etc/sudoers.d/ansibledeploy
    
    
    cat << EOF >> ceph.conf
    public network = 10.10.10.0/24
    cluster network = 10.10.11.0/24
    osd objectstore = bluestore
    mon_allow_pool_delete = true
    osd pool default size = 3
    osd pool default min size = 1
    EOF

#### aa
### a
##### a

Trên thực tế, các OSD thuộc nhiều host có thể bị lỗi cùng một lúc. Quá trình phục hồi có thể sẽ gây nghẽn mạng hoặc ảnh hưởng tới việc phục vụ dữ liệu tới client. Ceph đưa ra một số tuỳ chỉnh sau để cân bằng những yếu tố trên:
- `osd recovery delay start` sau khi quá trình re-peer hoàn tất, sẽ delay một khoảng thời gian (second) rồi mới tiến hành recover object.
- `osd recovery thread timeout` set timeout cho 1 quá trình recovery
- `osd recovery max active` giới hạn số lượng recovery request của một OSD, tránh việc OSD bị overload và không thể đáp ứng được các request.
- `osd recovery max chunk` giới hạn khối lượng của từng khúc dữ liệu phục hồi, tránh việc nghẽn cổ chai mạng.  
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
