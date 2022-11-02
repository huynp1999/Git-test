# Role Cephadm Server

Inputs

- File inventory để khai báo các hostname và IP, kèm theo chức năng của host đó trong cụm. File này có thể ở format yaml, JSON,…
File sẽ bao gồm:
    - chức năng host (ví dụ mon, mgr, osd,…)
    - hostname (trùng với hostname của server) và IP

```yaml
rules: 2
rule_name:
  - HDD1: hdd
  - SSD1: ssd
nodes:
  - name: ceph-mon-1
    bind_ip_address: 192.168.1.1
    services_install: 
      - mon
      - mgr
  - name: ceph-mon-2
    bind_ip_address: 192.168.1.2
    services_install: 
      - mon
      - mgr
  - name: ceph-mon-3
    bind_ip_address: 192.168.1.3
    services_install: 
      - mon
      - mgr
  - name: ceph-data-1
    bind_ip_address: 192.168.1.4
    device_class: hdd
    services_install: 
      - osd
  - name: ceph-data-2
    bind_ip_address: 192.168.1.5
    device_class: hdd
    services_install: 
      - osd
  - name: ceph-data-3
    bind_ip_address: 192.168.1.6
    device_class: hdd
    services_install: 
      - osd
  - name: ceph-data2-1
    bind_ip_address: 192.168.1.7
    device_class: ssd
    services_install: 
      - osd
  - name: ceph-data2-2
    bind_ip_address: 192.168.1.8
    device_class: ssd
    services_install: 
      - osd
  - name: ceph-data2-3
    bind_ip_address: 192.168.1.9
    device_class: ssd
    services_install: 
      - osd
```

- `ceph_version_name` (bắt buộc, mặc định = quincy)
    
    Là version của ceph sẽ được cài đặt là tên của version như là octopus, pacific, quincy
    
- `ceph_public_network` (bắt buộc)
    
    Dải mạng để thông mạng với các server compute
    Ví dụ: `192.168.1.0/24` 
    Đối với nhiều dải mạng, giá trị có thể là `192.168.1.0/24,192.168.2.0/24,192.168.1.0/24`
    
- `mon_host` (bắt buộc)
Là list IP của host có chức năng mon
List này có thể lấy từ inventory
Ví dụ: `192.168.1.1,192.168.1.2,192.168.1.3`
- `mon_inital_members` (bắt buộc)
Là list hostname của host có chức năng mon
List này có thể lấy từ inventory
Ví dụ: `ceph-mon-01,ceph-mon-02,ceph-mon-03`
- `ceph_private_network` (tùy chọn, mặc định  = `ceph_public_network`)
    
    Dải ip để thông mạng giữa các server storage mới nhau
    Nếu không khai báo, mặc định sử dụng theo `ceph_public_network`
    
- `ceph_autotune_memory_target_ratio` (mặc định = 0.7)
    
    Tỉ lệ số lượng ram lấy của host để chia cho các osd
    
- `ceph_osd_pool_default_size` (mặc định = 3)
Kích thước của pool khi tạo, mặc định = 3 là replicate , đảm bảo phần HA, chọn = 2 nếu như ưu tiên về hiệu năng
- `device_class`: (mặc định = hdd)
Khai báo các host data đang chứa SSD hay HDD. Nếu các host data chứa SSD, set giá trị bằng ssd, tương tự với NVME,…

Process

1. Tại tất cả các node trong inventory
- `apt install python3 lvm2 docker.io -y`
1. Tại node mon đầu tiên (ceph-mon-01), cài đặt cephadm
- `curl --silent --remote-name --location https://github.com/ceph/ceph/raw/<ceph_version_name>/src/cephadm/cephadm`
- `chmod +x cephadm`
- `./cephadm add-repo --release <ceph_version_name>`
- `./cephadm install`
1. Tại node mon đầu tiên, tạo key ssh và copy qua tất cả các host thuộc Ceph cluster. `node_ips` là các IP của các host đã được khai báo trong inventory
- `ssh-keygen`
- `ssh-copy-id -f -i /root/.ssh/id_rsa.pub root@<node_ips>`
1. Tại node mon đầu tiên, tạo file `cluster.yaml` bao gồm hostname, IP và chức năng node đã được khai báo trong file inventory ở input
- Những field nào liên quan tới hostname hay IP thì lấy từ inventory ra
- Labels là chức năng của host đã được khai báo trong inventory
    - Ví dụ host `ceph-mon-01` nằm trong cả 2 chức năng mon và mgr thì sẽ có label là:
        - `mon`
        - `mgr`
        - và một label mặc định `_admin`
- Đối với `service_type` là osd:
    - Phần placement dùng để khai báo các host chứa chức năng osd
        - `host_pattern`: khai báo theo regex
        - `hosts`: khai báo theo từng hostname chỉ định. Ví dụ:
        
        ```yaml
        placement:
          hosts:
            - ceph-data-01
            - ceph-data-02
        ```
        
    - Phần spec dùng để chỉ định add osd vào các device nằm trên các host vừa khai báo
        - `data_devices`: dùng để chỉ định add osd vào các device.
        Value mặc định `all: true`
        - `crush_device_class:` sẽ có giá trị là
            - `ssd` đối với các host chứa có device_class là ssd
            - `hdd` đối với các host chứa có device_class là hdd
        - `objectstore: bluestore` : option này mặc định luôn có

```yaml
service_type: host
hostname: ceph-mon-01
addr: 192.168.1.1
labels:
- _admin
- mon
- mgr
---
service_type: host
hostname: ceph-mon-02
addr: 192.168.1.2
labels:
- _admin
- mon
- mgr
---
service_type: host
hostname: ceph-mon-03
addr: 192.168.1.3
labels:
- _admin
- mon
- mgr
---
service_type: host
hostname: ceph-hdd-01
addr: 192.168.1.4
labels:
- _admin
- osd
---
service_type: host
hostname: ceph-hdd-02
addr: 192.168.1.5
labels:
- _admin
- osd
---
service_type: host
hostname: ceph-hdd-03
addr: 192.168.1.6
labels:
- _admin
- osd
---
service_type: host
hostname: ceph-ssd-01
addr: 192.168.1.7
labels:
- _admin
- osd
---
service_type: host
hostname: ceph-ssd-02
addr: 192.168.1.8
labels:
- _admin
- osd
---
service_type: host
hostname: ceph-ssd-03
addr: 192.168.1.9
labels:
- _admin
- osd
---
service_type: mgr
service_name: mgr
placement:
  hosts:
  - ceph-mon-01
  - ceph-mon-02
  - ceph-mon-03
---
service_type: mon
service_name: mon
placement:
  hosts:
  - ceph-mon-01
  - ceph-mon-02
  - ceph-mon-03
---
service_type: osd
service_name: osd
placement:
  hosts:
  - ceph-hdd-01
  - ceph-hdd-02
  - ceph-hdd-03
spec:
  crush_device_class: hdd
  data_devices:
    all: true
  objectstore: bluestore
---
service_type: osd
service_name: osd
placement:
  hosts:
  - ceph-ssd-01
  - ceph-ssd-02
  - ceph-ssd-03
spec:
  crush_device_class: ssd
  data_devices:
    all: true
  objectstore: bluestore
```

1. Tại node mon đầu tiên (ceph-mon-01), khởi tạo cluster bằng file cluster.yaml được tạo ở bước 4
- `cephadm bootstrap --mon-ip <first_mon_ip> --ssh-private-key /root/.ssh/id_rsa --ssh-public-key /root/.ssh/id_rsa.pub --ssh-user root --skip-dashboard --apply-spec cluster.yaml`
    - `<first_mon_ip>` ví dụ theo inventory sẽ là `192.168.1.1`
    - `ssh-private-key`, `ssh-public-key` là đường dẫn tới ssh private key và public key đã được gen ở bước 2
1. Tại node mon đầu tiên (ceph-mon-01), sau khi cluster lên với đầy đủ các thành phần (check `ceph -s`), tiếp tục set các config
- `/usr/sbin/cephadm shell`
- `ceph orch apply mon --unmanaged`
- `ceph orch apply mgr --unmanaged`
- `ceph config set mon public_network *<*ceph_public_network*>*`
- `ceph config set mon cluster_network *<*ceph_private_network*>*`
- `ceph config set osd osd_pool_default_size <ceph_osd_pool_default_size>`
- `ceph config set mgr mgr/cephadm/autotune_memory_target_ratio <ceph_autotune_memory_target_ratio>`

Outputs:

Kiểm tra cụm đã lên với đầy đủ các thành phần:

- `ceph -s`

Ví dụ đối với inventory như input thì phải có đủ:

- 3 mon
- 3 mgr
- 3 osd

![https://user-images.githubusercontent.com/83684068/195814816-50efff7e-8f99-4534-b511-8731a188ddfd.png](https://user-images.githubusercontent.com/83684068/195814816-50efff7e-8f99-4534-b511-8731a188ddfd.png)

- Health ok
