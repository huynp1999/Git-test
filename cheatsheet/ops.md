## Live-migration

    openstack  --os-compute-api-version 2.30 server migrate  --live-migration --block-migration --host ops2 ef6328a9-7f58-44a6-b808-9f9448be4969

## Create VM

    openstack server create --volume e3c4a224-08fc-4f82-93e9-ad8ddb7803e6  --flavor m1.benchmark --key-name huy --security-group basic --nic net-id=8ee3ba1f-3cea-44b5-8b26-13c1bd75d5a1 --availability-zone nova:ops3 testops3
    
## reset state

    cinder reset-state --state available --attach-status detached 

# Integrade ceph

```
ceph auth get-or-create client.cinder mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes, allow rwx pool=vms, allow rx pool=images'
ceph auth get-or-create client.cinder | ssh {your-volume-server} sudo tee /etc/ceph/ceph.client.cinder.keyring
ssh {your-cinder-volume-server} chown cinder:cinder /etc/ceph/ceph.client.cinder.keyring
ceph auth get-key client.cinder | ssh {your-compute-node} tee client.cinder.key
uuidgen > uuid-secret.txt
virsh secret-define --file secret.xml
virsh secret-set-value --secret $(cat uuid-secret.txt) --base64 $(cat client.cinder.key) && rm client.cinder.key secret.xml
```

```
cinder.conf
#...
[ceph]
volume_driver = cinder.volume.drivers.rbd.RBDDriver
volume_backend_name = ceph
rbd_pool = volumes
rbd_ceph_conf = /etc/ceph/ceph.conf
rbd_flatten_volume_from_snapshot = false
rbd_max_clone_depth = 5
rbd_store_chunk_size = 4
rados_connect_timeout = -1
rbd_user = cinder
rbd_secret_uuid = 206c19f3-eb1b-4574-abc5-239dd821ae1a      # secret.xml
report_discard_supported = true
#...
```
