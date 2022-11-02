Inputs

- `rules` (bắt buộc, mặc định = 1, tối đa = 2)
Số lượng rule
- `rule_name`
Bao gồm tên rule và device class của rule (mặc định = `HDD1: hdd`)
    - (tùy chọn) thêm rule, giá trị có thể ví dụ:
    - lưu ý: nếu rule 1 có device_class là hdd thì device_class của rule 2 sẽ phải là ssd. Và ngược lại.

```
HDD1: hdd
SSD1: ssd
```

- `pool_name` (bắt buộc)
Luôn có mặc định 2 pool là HDD1 và glances theo rule 1. Nếu `rules` > 1 thì sẽ có thêm một pool thứ 3, pool này sẽ theo rule 2.
Như vậy tên các pool sẽ phải ghi theo thứ tự: glance pool, cinder pool[, extra pool]
  - ví dụ: `glances, HDD1, SSD1`

- `pg_num` (bắt buộc, mặc định = `128`)
Số lượng pg của các pool

Process

1. Cú pháp tạo rule và pool
`ceph osd crush rule create-replicated <rule_name> default host <device_class>`
`ceph osd pool create <pool_name> <pool_pg_num> <pool_pg_num> replicated <rule_name>`
2. Tạo rule cho cinder và glance (và tạo rule thứ 2 nếu có)
`ceph osd crush rule create-replicated HDD1 default host hdd`
`ceph osd crush rule create-replicated SSD1 default host ssd`

3. Tạo các pool theo các `pool_name`
- Lưu ý: 2 pool đầu tiên sẽ chung rule 1, nếu có pool thứ 3 thì dùng rule 2
`ceph osd pool create HDD1 128 128 replicated HDD1`
`ceph osd pool create glances 128 128 replicated HDD1`
`ceph osd pool create SSD2 128 128 replicated SSD2`

Output

Rule và pool được tạo thành công.
Kiểm tra nếu thấy tên rule và pool là hoàn tất:

- `ceph osd crush rule ls | grep -E ‘HDD1’`
- `ceph osd pool ls | grep -E ‘glances|HDD1’`

Pool được tạo có tên HDD1, dùng để thay vào `<pool_name>` bên [install cinder](https://www.notion.so/d383924887904aaab1853e056852f275)
