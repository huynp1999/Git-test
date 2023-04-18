
## Class
```
ceph osd crush set-device-class hdd osd.0
ceph osd crush rm-device-class osd.0
```

## Bucket
```
ceph osd crush add-bucket data root
ceph osd crush move hdd-data root=data
ceph osd crush remove default
```

## Rule
```
ceph osd crush rule dump
ceph osd crush rule create-replicated data-hdd   data    host
                                      <rule>     <root>  <failure-domain>
ceph osd crush rule rm replicated_rule
```

## Pool
```
ceph osd lspools
ceph osd pool ls detail
ceph osd pool create testpool1 128 128 replicated hdd-rule
ceph osd pool delete testpool1 --yes-i-really-really-mean-it
```

## Erasure code

```
ceph osd erasure-code-profile set ecroot-profile m=1 crush-root=ecroot
ceph osd crush rule create-erasure ecrule ecroot-profile
ceph osd pool create default.rgw.archive.data erasure ecroot-profile ecrule
```

## RBD

```
rbd create disk02 --size 6G --image-feature layering -p rbdpool1
rbd ls -l -p rbdpool1
rbd map disk02 -p rbdpool1
rbd showmapped

rbd children -a images/3fe29499-7134-49af-9d29-53e62e36b31d@snap
rbd trash rm volumes/525ba2db99fbdb --force
rbd snap unprotect images/3fe29499-7134-49af-9d29-53e62e36b31d@snap
rbd snap rm images/3fe29499-7134-49af-9d29-53e62e36b31d@snap
rbd rm images/3fe29499-7134-49af-9d29-53e62e36b31d
```

## Autoscale
```
ceph osd pool set testpool1 pg_autoscale_mode on
ceph config set global osd_pool_default_pg_autoscale_mode <mode>
``` 
## Ceph tell
```
ceph tell 'osd.*' injectargs --osd-max-backfills=2 --osd-recovery-max-active=6
ceph osd set-full-ratio 0.95
ceph --admin-daemon /var/run/ceph/ceph-client.rgw.ceph1.asok config set debug_rgw 20


ceph device ls-by-host ceph1
ceph osd reweight osd.111 0
```

## Ceph config
```
ceph config dump
ceph config set global osd_scrub_auto_repair true
ceph config set global osd_pool_default_pg_autoscale_mode off

ceph daemon mon.stor1 config show
```
## PG
```
8 osd, 6 pool, rep size 2
PGs per OSD: (32×4×2+256×2×2)÷8
```

## RGW
```
radosgw-admin user create --uid=huy --display-name="huy user" --access-key fooAccessKey --secret-key fooSecretKey
radosgw-admin subuser create --uid huy --subuser huy3 --key-type s3
radosgw-admin user list
radosgw-admin user info --uid=benchmark-user

radosgw-admin bucket list
radosgw-admin bucket list --bucket=testbucket | jq '.[] | .name'

radosgw-admin bucket rm --bucket mps-cttcp-trash-2ec3d2fbb92c --purge-objects --max-concurrent-ios=2048 --bypass-gc

radosgw-admin key create --gen-access-key --gen-secret --subuser=backup-service:backup --key-type=s3

radosgw-admin caps add --uid=johndoe --caps="[users|buckets|metadata|usage|zone]=[*|read|write|read, write]"

radosgw-admin quota set --quota-scope=user --uid=myuser --max-size=500G

rados -p default.rgw.buckets.data ls -
rados -p default.rgw.buckets.data get gach/object file.txt
```

## FS
```
ceph fs new cephfs meta data
mount -t ceph 10.5.90.56:/ /mnt/cephfs-test/ -o name=admin,secret=AQDYlbJitZscHRAABHSiC2YZ1ma50IXf5WStgg==

ceph tell mds.ceph-nfs-03 client ls | jq "." | less  # query client
ceph tell mds.0 client evict id=4305 # evict
```

## Stretch mode
```
ceph mon add ceph6 10.5.10.93 datacenter=site2

```

## ceph-objectstore-tool 
Xóa pg và sang node còn lại mark complete
```
ceph-objectstore-tool --op remove --data-path /var/lib/ceph/osd/ceph-6 --pgid 17.0 --force

ceph-objectstore-tool --data-path /var/lib/ceph/osd/ceph-1 --pgid 17.0 --op mark-complete --no-mon-config
```
https://tracker.ceph.com/issues/57940


Export pg data:
```
ceph-objectstore-tool --data-path /var/lib/ceph/osd/ceph-441 --no-mon-config --pgid 6.fcc --op export --file ./pg6ffc
```
https://lists.ceph.io/hyperkitty/list/ceph-users@ceph.io/thread/7AWMDL5CWKW2WBHM7TVIRLXYJSNS5EIX/

