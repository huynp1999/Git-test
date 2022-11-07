Inputs

- `user_name` (bắt buộc)
Tên user.
Tùy vào loại dịch vụ của Openstack mà sẽ có giá trị riêng.
Ví dụ tích hợp Openstack Cinder với Ceph thì `user_name = cinder`
- `cinder_user_caps` (bắt buộc)
Phân quyền user được phép access vào pool nào
Tùy vào loại dịch vụ của Openstack mà sẽ có giá trị riêng.
    - mặc định: `mon 'profile rbd' osd 'profile rbd pool=HDD1, allow rx pool=glances'`
- `glance_user_caps` (bắt buộc)
Phân quyền user được phép access vào pool nào
Tùy vào loại dịch vụ của Openstack mà sẽ có giá trị riêng.
    - mặc định: `mon 'profile rbd' osd 'allow class-read object_prefix rbd_children, allow rwx pool=glances ,allow rx pool=HDD1'`
- `pool_name` (bắt buộc)
Tên pool đã được tạo ở role trước
Tùy vào loại dịch vụ của Openstack mà sẽ có giá trị riêng.
Ví dụ tích hợp Openstack Cinder với Ceph thì `pool_name = HDD1`
- `cinder_keyring` (bắt buộc)
Keyring để tích hợp Ceph với Cinder
- `glance_keyring` (bắt buộc)
Keyring để tích hợp Ceph với Glance
- `ceph_fsid` (bắt buộc)
ID định danh duy nhất cho một cluster Ceph
- `rbd_secret_uuid` (bắt buộc)
UUID dùng để tích hợp Ceph với Cinder và Nova

Process

1. Cú pháp tạo ceph user
`ceph auth get-or-create client.<user_name> <user-cap>`
2. Tạo user cho glance:
`ceph auth get-or-create client.glance mon 'profile rbd' osd 'allow class-read object_prefix rbd_children, allow rwx pool=glances ,allow rx pool=HDD1'`
- trong trường hợp có thêm rule -> thêm pool (ví dụ tên SSD1)
`ceph auth get-or-create client.glance mon 'profile rbd' osd 'allow class-read object_prefix rbd_children, allow rwx pool=glances ,allow rx pool=HDD1, allow rx pool=SSD1'`
3. Tạo user cho cinder:
`ceph auth get-or-create client.cinder mon 'profile rbd' osd 'profile rbd pool=HDD1, allow rx pool=glances'`
- trong trường hợp có thêm rule -> thêm pool (ví dụ tên SSD1)
`ceph auth get-or-create client.cinder mon 'profile rbd' osd 'profile rbd pool=HDD1, profile rbd pool=SSD1, allow rx pool=glances'`

Tích hợp Ceph và Cinder của Openstack

1. Đứng tại node cinder, thực hiện các lệnh sau để lấy keyring:
- `ceph auth get-or-create client.cinder`
- `ceph auth get-or-create client.glance`
- `ceph auth get-key client.cinder | ssh <compute_server> tee client.cinder.key`
    - `<controller_server>` là role [Controller](https://www.notion.so/Role-Controller-4-cee21eee8a4748c3a79cc838bbf4dada)
    - `<compute_server>` là role [Compute](https://www.notion.so/9a9057d1366843dfae00d9e88922ac20)
    - lưu ý: keyring của user cinder sẽ copy cho node controller và node compute
    keyring của user glance sẽ copy cho node controller và node glance ( nếu có)
1. Đứng tại node compute, lấy giá trị cho `rbd_secret_uuid` bằng lệnh:
- `uuidgen`
    - output sẽ là giá trị của `rbd_secret_uuid`: fa43b59a-9b19-4f2a-9de1-d5342ac91c66
1. Sau khi lấy được `rbd_secret_uuid`, tạo file `secret.xml` để tích hợp nova:

```bash
cat > secret.xml <<EOF
<secret ephemeral='no' private='no'>
  <uuid>rbd_secret_uuid</uuid>
  <usage type='ceph'>
    <name>client.cinder secret</name>
  </usage>
</secret>
EOF
```

1. Đứng tại node compute, tích hợp Nova
- `virsh secret-define --file secret.xml`
- `virsh secret-set-value --secret fa43b59a-9b19-4f2a-9de1-d5342ac91c66 --base64 $(cat client.cinder.key) && rm client.cinder.key secret.xml`
1. Đứng tại node controller, tích hợp Cinder, lấy `rbd_secret_uuid` từ gen được sang cấu hình của [Role Cinder](https://www.notion.so/d383924887904aaab1853e056852f275)

Output

User được tạo thành công.
Kiểm tra nếu thấy tên các user vừa tạo là hoàn tất:

- `ceph auth list | grep -E 'cinder|glance'`

Keyring cho Cinder và Glance được tạo thành công:

- Output của `ceph auth get-key client.cinder` sẽ là giá trị cho `cinder_keyring`
- Output của `ceph auth get-key client.glance` sẽ là giá trị cho `glance_keyring`
    - Ví dụ: `AQBm4ytjuA1AIxAA/qr54cstZQcYxZeN0h1JyA==`

`ceph_fsid` của Ceph được lấy qua `ceph mon dump | grep fsid`

- Ví dụ: `569c49fe-6f31-44c5-8bc1-32d1c780343e`
