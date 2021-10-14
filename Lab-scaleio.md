- scaleio 2.5
- centos 7
- 3 node cluster

## 1. Cài đặt java jdk 1.8
Kiểm tra xem các bản java đã cài đặt trước đó và gỡ cài đặt, ví dụ `java-1.7.0-openjdk`:

    yum update
    rpm -qa | grep -E '^open[jre|jdk]|j[re|dk]'
    yum remove java-1.7.0-openjdk

Tải về jdk package tại [đây](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html) và cài đặt:

    rpm -ivh jdk-8u25-linux-x64.rpm
    
Ssetup các biến môi trường

    cat << EOF > /etc/profile.d/java.sh
    #!/bin/bash
    JAVA_HOME=/usr/java/jdk1.8.0_25/
    PATH=$JAVA_HOME/bin:$PATH
    export PATH JAVA_HOME
    export CLASSPATH=.
    EOF

    chmod +x /etc/profile.d/java.sh
    source /etc/profile.d/java.sh
    alternatives --install /usr/bin/java java /usr/java/jdk1.8.0_25/jre/bin/java 20000
    alternatives --install /usr/bin/jar jar /usr/java/jdk1.8.0_25/bin/jar 20000
    alternatives --install /usr/bin/javac javac /usr/java/jdk1.8.0_25/bin/javac 20000
    alternatives --install /usr/bin/javaws javaws /usr/java/jdk1.8.0_25/jre/bin/javaws 20000
    alternatives --set java /usr/java/jdk1.8.0_25/jre/bin/java
    alternatives --set jar /usr/java/jdk1.8.0_25/bin/jar
    alternatives --set javac /usr/java/jdk1.8.0_25/bin/javac
    alternatives --set javaws /usr/java/jdk1.8.0_25/jre/bin/javaws
    
Kiểm tra:
    
    java -version
    
## 2. Deploy Scaleio
### Gateway
Scaleio sẽ được deploy qua một installer gateway.

Cài đặt packet gateway dành cho Centos:

    # GATEWAY_ADMIN_PASSWORD=<new_GW_admin_password> rpm -U EMC-ScaleIO-gateway-2.5-0.254.x86_64.rpm --nodeps
    
Cài đặt packet gateway dành cho Ubuntu:
    
    # apt install bitutils -y
    # GATEWAY_ADMIN_PASSWORD=<new_GW_admin_password> dpkg -i EMC-ScaleIO-gateway-2.5-<build>.X.deb
    
Nếu gặp lỗi `Cannot query status of the EMC ScaleIO Gateway.` thì cần xem lại các cài đặt java, cần đúng 1.8.

Truy cập vào gateway theo ip của host:
### Deploy cluster
Ở tab **Packages**, upload các package theo yêu cầu (MDM, SDS, SDC, LIA).

Ở tab **Install**, chọn phương thức deploy (ở đây là cluster 3 node: 1 Master MDM, 1 Slave MDM, và 1 TieBreaker MDM)
- Cấu hình password của thành phần LIA và MDM, IP của các host và password root.

Sau khi **Start installation**, ở tab **Monitor** cho phép theo dõi quá trình install và config các thành phần.
- Làm theo từng bước **Start upload phase** -> **Start install phase** -> **Start configure phase**
- Lưu ý ở mỗi bước cần check trạng thái *completed* trước khi chuyển sang bước kế tiếp

Nếu trạng thái *failed* xảy ra, thử *retry failed*. Hoặc purge các package *emc-scaleio* tại các node và cài lại.

Khi tất cả được thành công sẽ có kết quả:

### GUI
Cài đặt gói GUI của Scalio:

    # dpkg -i EMC-ScaleIO-gui-2.5-0.254.deb

Khởi động GUI:

    # cd /opt/emc/scaleio/gui/
    # ./run.sh

Nhập IP của server manage, username mặc định *admin* và password đã cầu hình ở phần deploy:

### CLI
Đăng nhập bằng cli:

    # scli --login --username admin --password <password>
    
Thêm một SDS device:

    # scli --add_sds_device --sds_ip <IP> --protection_domain_name default --storage_pool_name default --device_path /dev/sda
    
Nếu chưa có pool được tạo mặc định:

Add a volume:
scli --add_volume --protection_domain_name default
     --storage_pool_name default --size_gb <SIZE> --volume_name <NAME>
