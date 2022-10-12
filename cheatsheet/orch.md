## OSD

```
ceph orch osd rm 0 --zap
ceph orch daemon rm osd.0 --force
for i in {1..3}; do ceph osd purge osd.$i --force; done
```

## Host

```
ceph orch host drain ceph-adm-2
ceph orch host rm ceph-adm-2
```

## Daemon

```
ceph orch ps
ceph orch daemon rm mon.ceph-adm-3 --force
```

## Cephadm

```
cephadm bootstrap --mon-ip 10.5.89.49 --ssh-private-key /root/.ssh/id_rsa --ssh-public-key /root/.ssh/id_rsa.pub --ssh-user root --skip-dashboard --apply-spec cluster.yaml
cephadm rm-cluster --fsid 3e3a5628-49df-11ed-a1ed-fa163ef71b18 --force
```

## Export

```
ceph orch ls --service-name rgw.<realm>.<zone> --export > rgw.<realm>.<zone>.yaml
ceph orch ls --service-type mgr --export > mgr.yaml
ceph orch ls --export > cluster.yaml

UPDATING SERVICE SPECIFICATIONS
ceph orch apply -i myservice.yaml [--dry-run]
```
