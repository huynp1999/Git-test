# Lab tích hợp Ceph và Openstack
## 1. Chuẩn bị môi trường
### 1.1 Mô hình mạng và phần cứng
![image](https://user-images.githubusercontent.com/83684068/133953976-3ec0e5d1-6914-426c-addd-0d458ecef523.png)

|  Host name | Management IP (ens33)  | Cluster IP (ens35) | Disk |
| --- |:------:|:-----:|:-----:|
|  Openstack   |  192.168.1.21  | 10.10.10.21 | 3 x 20GB (sda, sdb, sdc) |
|  Ceph02   |   192.168.1.22   | 10.10.10.22 |  3 x 20GB (sda, sdb, sdc) |
|  Ceph03   |   192.168.1.23   | 10.10.10.23 |  3 x 20GB (sda, sdb, sdc) |

Quy hoạch hệ thống:

    - OS: Centos Linux 8 64 bit, kernel Linux
    - Phiên bản OpenStack Train
    - Phiên bản Ceph Nautilus (14.2)
    - Các dải mạng: 
        - ens: cung cấp mạng ra ngoài internet
        - ens: dành cho replicated giữa các node Ceph
    - Ổ cứng:
        - sda: dành cho OS
        - sdb: sử dụng làm journal (Journal là một lớp cache khi client ghi dữ liệu, thực tế thường dùng ổ SSD dành cho cache)
        - sdc, sdd: dành cho OSD (nơi chứa dữ liệu)

Cấu hình trong `/etc/host"`:

    192.. ops
    192   ceph01
    122   ceph02

## 2. Cài đặt Openstack
Timezone:

    yum -y install chrony
### 2.1 Cài đặt các repo 

    yum install -y epel-release
    yum update -y
    yum install -y centos-release-openstack-train  vim
    yum install -y python-openstackclient openstack-selinux 
    yum upgrade -y
### 2.2 Cài đặt SQL database

    yum -y install mariadb mariadb-server python2-PyMySQL
    
