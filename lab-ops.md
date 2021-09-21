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

## 2. Cài đặt môi trường cho Openstack
Timezone:

    yum -y install chrony
    
### 2.1 Cài đặt các repo 

    yum install -y epel-release
    yum update -y
    yum install -y centos-release-openstack-train vim wget
    yum install -y python-openstackclient openstack-selinux 
    yum upgrade -y
    
### 2.2 Cài đặt SQL database

    yum -y install mariadb mariadb-server python2-PyMySQL
    
Cấu hình Mariadb, tạo file `/etc/my.cnf.d/openstack.cnf` với nội dung sau:

    [mysqld]
    bind-address = [mngt net]

    default-storage-engine = innodb
    innodb_file_per_table = on
    max_connections = 4096
    collation-server = utf8_general_ci
    character-set-server = utf8
    
Enable và start MySQL:

    systemctl enable mariadb.service
    systemctl start mariadb.service
    
Thiết lập mật khẩu cho tài khoản root của Mariadb:

    mysql_secure_installation   
    
### 2.3 Cài đặt RabbitMQ

    yum install rabbitmq-server -y
  
Enable và start rabbitmq-server:

    systemctl start rabbitmq-server
    systemctl enable rabbitmq-server
    systemctl status rabbitmq-server

Tạo user `openstack` với mật khẩu là `huy123` và gán quyền:

    rabbitmqctl add_user openstack huy123
    rabbitmqctl set_permissions openstack ".*" ".*" ".*"
    rabbitmqctl set_user_tags openstack administrator
    
Kiểm tra user vừa tạo

    rabbitmqadmin list users

### 2.4 Cài đặt Memcached
    
    yum -y install memcached python-memcached

Cấu hình Memcached nhận mngt net của ctl:

    sed -i "s/-l 127.0.0.1,::1/-l [mngt net]/g" /etc/sysconfig/memcached
    
Enable và start memcached

    systemctl enable memcached.service
    systemctl start memcached.service

## 3. Cài đặt Openstack
### 3.1 Cài đặt Keystone
#### 3.1.1 Tạo database cho Keystone
Đăng nhập vào MySQL

    mysql -u root -p
    
Tạo database cho keystone và cấp quyền truy cập:

    CREATE DATABASE keystone;
    GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost'  IDENTIFIED BY 'huy123';
    GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'huy123';
    FLUSH PRIVILEGES;
    exit;
    
#### 3.1.2 Cài đặt và cấu hình keystone
Cài đặt các package:

    yum install -y openstack-keystone httpd mod_wsgi

Sao lưu file cấu hình trước khi chỉnh sửa:

    mv /etc/keystone/keystone.{conf,conf.backup}
    
Cấu hình `/etc/keystone/keystone.conf`:

    [database]
    connection = mysql+pymysql://keystone:huy123@ops/keystone
    ...
    [token]
    provider = fernet

Phân quyền lại config file

    chown root:keystone /etc/keystone/keystone.conf
    
Đồng bộ database cho keystone

    su -s /bin/sh -c "keystone-manage db_sync" keystone
    
Thiết lập Fernet key

    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

Thiết lập boostrap cho Keystone

    keystone-manage bootstrap --bootstrap-password huy123 \
    --bootstrap-admin-url http://ops:5000/v3/ \
    --bootstrap-internal-url http://ops:5000/v3/ \
    --bootstrap-public-url http://ops:5000/v3/ \
    --bootstrap-region-id RegionOne
    
#### 3.1.2 Cấu hình Apache cho Keystone
Cấu hình server name trong `/etc/httpd/conf/httpd.conf`:

    sed -i 's|#ServerName www.example.com:80|ServerName ops|g' /etc/httpd/conf/httpd.conf 
    
Tạo symlink cho keystone api:

    ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
    
Start và enable Apache:

    systemctl enable httpd.service
    systemctl restart httpd.service

#### 3.1.3 Tạo biến môi trường, domain, projects, users, và roles
Tạo file biến môi trường `openrc-admin` cho tài khoản quản trị:

    cat << EOF >> admin-openrc
    export export OS_REGION_NAME=RegionOne
    export OS_PROJECT_DOMAIN_NAME=Default
    export OS_USER_DOMAIN_NAME=Default
    export OS_PROJECT_NAME=admin
    export OS_USERNAME=admin
    export OS_PASSWORD=passla123
    export OS_AUTH_URL=http://10.10.10.61:5000/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_IMAGE_API_VERSION=2
    export PS1='[\u@\h \W(admin-openrc-r1)]\$ '
    EOF
    
Tạo file biến môi trường `openrc-demo` cho tài khoản demo:

    cat << EOF >> demo-openrc
    export export OS_REGION_NAME=RegionOne
    export OS_PROJECT_DOMAIN_NAME=Default
    export OS_USER_DOMAIN_NAME=Default
    export OS_PROJECT_NAME=demo
    export OS_USERNAME=demo
    export OS_PASSWORD=passla123
    export OS_AUTH_URL=http://10.10.10.61:5000/v3
    export OS_IDENTITY_API_VERSION=3
    export OS_IMAGE_API_VERSION=2
    export PS1='[\u@\h \W(demo-openrc-r1)]\$ '
    EOF

Sử dụng biến môi trường

    source admin-openrc 
    
Tạo service project:

    openstack project create --domain default --description "Service Project" service
    
Tạo demo project:

    openstack project create --domain default --description "Demo Project" demo
    
Tạo user `demo` và password `huy123`:

    openstack user create --domain default --password huy123 demo
    
Tạo roles `user`:

    openstack role create user
    
Thêm role `user` cho user `demo` trên project `demo`:

    openstack role add --project demo --user demo user

#### 3.1.4 Kiểm tra lại các bước cài đặt Keystone
Unset các biến môi trường:

    unset OS_AUTH_URL OS_PASSWORD
    
Kiểm tra xác thực trên project admin:

    openstack --os-auth-url http://ops:5000/v3 --os-project-domain-name Default \
    --os-user-domain-name Default --os-project-name admin --os-username admin token issue
    
Kiểm tra xác thực trên project demo:

    openstack --os-auth-url http://ops:5000/v3 --os-project-domain-name default \
    --os-user-domain-name default --os-project-name demo --os-username demo token issue

Sau khi kiểm tra xác thực xong source lại biến môi trường:

    source admin-openrc 
    
Nếu trong quá trình thao tác, xác thực token có vấn đề thì get lại token mới:

    openstack token issue
    
### 3.2 Cài đặt Glance (Images Service)
#### 3.2.1 Tạo database cho Glance
Đăng nhập vào MySQL

    mysql -u root -p
    
Tạo database cho keystone và cấp quyền truy cập:

    CREATE DATABASE glance;
    GRANT ALL PRIVILEGES ON glancee.* TO 'glance'@'localhost'  IDENTIFIED BY 'huy123';
    GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'huy123';
    FLUSH PRIVILEGES;
    exit;

#### 3.2.2 Tạo user glance, gán quyền và tạo endpoint API cho dịch vụ glance
Sử dụng biến môi trường:

    source admin-openrc
    
Tạo user `glance`:

    openstack user create --domain default --password huy123 glance

Thêm roles `admin` cho user `glance` trên project `service`:

    openstack role add --project service --user glance admin

Kiểm tra lại user `glance`:

    openstack role list --user glance --project service

Khởi tạo dịch vụ tên `glance`:

    openstack service create --name glance --description "OpenStack Image" image

Tạo các enpoint cho glane

    openstack endpoint create --region RegionOne image public http://ops:9292
    openstack endpoint create --region RegionOne image internal http://ops:9292
    openstack endpoint create --region RegionOne image admin http://ops:9292

#### 3.2.3 Cài đặt và cấu hình Glance
Cài đặt package:

    yum install -y openstack-glance
    
Backup 2 file cấu hình `glance-api` và `glance-registry`:

    mv /etc/glance/glance-api.{conf,conf.backup}
    mv /etc/glance/glance-registry.{conf,conf.bk}
    
Cấu hình file `/etc/glance/glance-api.conf`:

    ...
    [database]
    connection = mysql+pymysql://glance:huy123@ops/glance
    [glance_store]
    stores = file,http
    default_store = file
    filesystem_store_datadir = /var/lib/glance/images/
    ...
    [keystone_authtoken]
    auth_uri = http://ops:5000
    auth_url = http://ops:5000
    memcached_servers = ops:11211
    auth_type = password
    project_domain_name = Default
    user_domain_name = Default
    project_name = service
    username = glance
    password = huy123
    region_name = RegionOne
    ...
    [paste_deploy]
    flavor = keystone
    
Cấu hình file `/etc/glance/glance-registry.conf`:

    [database]
    connection = mysql+pymysql://glance:huy123@ops/glance
    ...
    [keystone_authtoken]
    auth_uri = http://ops:5000
    auth_url = http://ops:5000
    memcached_servers = ops:11211
    auth_type = password
    project_domain_name = Default
    user_domain_name = Default
    project_name = service
    username = glance
    password = huy123
    region_name = RegionOne
    ...
    [paste_deploy]
    flavor = keystone
    
Phân quyền lại 2 file cấu hình:

    chown root:glance /etc/glance/glance-api.conf
    chown root:glance /etc/glance/glance-registry.conf
    
Đồng bộ database cho glance:

    su -s /bin/sh -c "glance-manage db_sync" glance
    
Enable và restart Glance:

    systemctl enable openstack-glance-api.service openstack-glance-registry.service
    systemctl start openstack-glance-api.service openstack-glance-registry.service
    
#### 3.2.4 Kiểm tra lại cấu hình Glance
Download image cirros:

    wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
    
Upload image lên Glance:

    openstack image create "cirros" --file cirros-0.3.5-x86_64-disk.img --disk-format qcow2 --container-format bare --public
    
Kiểm tra danh sách image:

    openstack image list

### 3.3 Cài đặt Nova (Compute Service)
#### 3.3.1 Tạo database cho Nova
Đăng nhập vào MySQL'
    
    mysql -u root -p
    
Tạo database cho `nova_api`, `nov`, và `nova_cell0`:

    CREATE DATABASE nova_api;
    CREATE DATABASE nova;
    CREATE DATABASE nova_cell0;

Cấp quyền truy cập database:

    GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'huy123';
    GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'huy123';
    
    GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'huy123';
    GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'huy123';

    GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'huy123';
    GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'huy123';
    FLUSH PRIVILEGES;
    EXIT;

#### 3.3.2 Tạo user, service và các endpoint API cho nova
Sử dụng biến môi trường

    source admin-openrc

Tạo user `nova`

    openstack user create --domain default --password huy123 nova

Thêm role `admin` cho user `nova` trên project service:

    openstack role add --project service --user nova admin

Tạo dịch vụ `nova`:

    openstack service create --name nova --description "OpenStack Compute" compute

Tạo các endpoint cho dịch vụ compute

    openstack endpoint create --region RegionOne compute public http://ops:8774/v2.1
    openstack endpoint create --region RegionOne compute internal http://ops:8774/v2.1
    openstack endpoint create --region RegionOne compute admin http://ops:8774/v2.1

Tạo user `placement`:

    openstack user create --domain default --password huy123 placement

Thêm role `admin` cho user `placement` trên project service:

    openstack role add --project service --user placement admin

Tạo dịch vụ placement

    openstack service create --name placement --description "Placement API" placement

Tạo endpoint cho placement

    openstack endpoint create --region RegionOne placement public http://ops:8778
    openstack endpoint create --region RegionOne placement internal http://ops:8778
    openstack endpoint create --region RegionOne placement admin http://ops:8778  

#### 3.3.3 Cài đặt và cấu hình Nova
Cài đặt package:

    yum install -y openstack-nova-api openstack-nova-conductor openstack-nova-console \
    openstack-nova-novncproxy openstack-nova-scheduler openstack-nova-placement-api
    
    yum install -y openstack-nova-compute
    
Backup cấu hình Nova:
    
    cp /etc/nova/nova.{conf,conf.backup}
    cp /etc/httpd/conf.d/00-nova-placement-api.{conf,conf.bk}
    
Sửa file `/etc/nova/nova.conf`:

    [api_database]
    connection = mysql+pymysql://nova:huy123@ops/nova_api
    ...
    [database]
    connection = mysql+pymysql://nova:huy123@ops/nova
    ...
    [DEFAULT]
    enabled_apis = osapi_compute,metadata
    use_neutron = True
    firewall_driver = nova.virt.firewall.NoopFirewallDriver
    my_ip = ops
    transport_url = rabbit://openstack:huy123@ops
    ...
    [api]
    auth_strategy = keystone
    ...
    [keystone_authtoken]
    www_authenticate_uri = http://ops:5000/
    auth_url = http://ops:35357
    memcached_servers = ops:11211
    auth_type = password
    project_domain_name = default
    user_domain_name = default
    project_name = service
    username = nova
    password = huy123
    ...
    [vnc]
    enabled = true
    vncserver_listen = $my_ip
    vncserver_proxyclient_address = $my_ip
    novncproxy_base_url = http://ops:6080/vnc_auto.html
    ...
    [glance]
    api_servers = http://ops:9292
    ...
    [oslo_concurrency]
    lock_path = /var/lib/nova/tmp
    ...
    [placement]
    os_region_name = RegionOne
    project_domain_name = Default
    project_name = service
    auth_type = password
    user_domain_name = Default
    auth_url = http://ops:5000/v3
    username = placement
    password = huy123
    
Cấu hình virtualhost cho nova placement tại `/etc/httpd/conf.d/00-nova-placement-api.conf`:

    <Directory /usr/bin>
       <IfVersion >= 2.4>
          Require all granted
       </IfVersion>
       <IfVersion < 2.4>
          Order allow,deny
          Allow from all
       </IfVersion>
    </Directory>

Cấu hình bind cho nova placement api trên httpd:

    sed -i -e 's/VirtualHost \*/VirtualHost ops/g' /etc/httpd/conf.d/00-nova-placement-api.conf
    sed -i -e 's/Listen 8778/Listen ops:8778/g' /etc/httpd/conf.d/00-nova-placement-api.conf

Restart httpd:

    systemctl restart httpd 
    
Import DB nova:

    su -s /bin/sh -c "nova-manage api_db sync" nova
    su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
    su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova 
    su -s /bin/sh -c "nova-manage db sync" nova
    
Check nova cell

    nova-manage cell_v2 list_cells
    
Enable và start service nova

    systemctl enable openstack-nova-api.service openstack-nova-consoleauth.service \
    openstack-nova-scheduler.service openstack-nova-conductor.service \
    openstack-nova-novncproxy.service
    
    systemctl start openstack-nova-api.service openstack-nova-consoleauth.service \
    openstack-nova-scheduler.service openstack-nova-conductor.service \
    openstack-nova-novncproxy.service

Kiểm tra cài đặt lại dịch vụ

    openstack compute service list

#### 3.3.4 Kiểm tra cấu hình Nova
Xác định xem node `ops` có hỗ trợ ảo hóa hay không

    egrep -c '(vmx|svm)' /proc/cpuinfo
    
- Nếu lệnh này return 1 hoặc lớn hơn, thì node `ops` này hỗ trợ ảo hóa.
- Nếu lệnh này return 0, thì node `ops` không hỗ trợ ảo hóa, cần sửa section `[libvirt]` trong file `/etc/nova/nova.conf`:

        [libvirt]
        virt_type = qemu

Enable và start dịch vụ Compute:

    systemctl enable libvirtd.service openstack-nova-compute.service
    systemctl start libvirtd.service openstack-nova-compute.service
    
Kiểm tra node compute `ops` vừa tạo:

    admin-openrc
    openstack hypervisor list
### 3.3 Cài đặt Neutron (Network Service)

### 3.3 Cài đặt Cinder (Block Service)
