
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

## RBD

```
rbd create disk02 --size 6G --image-feature layering -p rbdpool1
rbd ls -l -p rbdpool1
rbd map disk02 -p rbdpool1
rbd showmapped
```

## Autoscale
```
ceph osd pool set testpool1 pg_autoscale_mode on
ceph config set global osd_pool_default_pg_autoscale_mode <mode>
``` 
## Ceph tell
```
ceph tell 'osd.*' injectargs --osd-max-backfills=2 --osd-recovery-max-active=6
```

## Ceph config
```
ceph config dump
ceph config set global osd_scrub_auto_repair true
ceph config set global osd_pool_default_pg_autoscale_mode off
```
## PG
```
8 osd, 6 pool, rep size 2
PGs per OSD: (32×4×2+256×2×2)÷8
```

## RGW
```
radosgw-admin user list
radosgw-admin user info --uid=benchmark-user

radosgw-admin bucket list
radosgw-admin bucket list --bucket=testbucket | jq '.[] | .name'

radosgw-admin key create --gen-access-key --gen-secret --subuser=backup-service:backup --key-type=s3

rados -p default.rgw.buckets.data ls -
rados -p default.rgw.buckets.data get gach/object file.txt
```
