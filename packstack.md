yum update -y
yum install -y centos-release-openstack-train
yum update -y
yum install -y openstack-packstack
yum -y update
yum -y install vim wget curl bash-completion
yum update -y



cat > ceph-secret.xml <<EOF
<secret ephemeral='no' private='no'>
<uuid>f3e54e0c-dc0d-4275-969c-ed3d9c99cf6f</uuid>
<usage type='ceph'>
	<name>client.cinder secret</name>
</usage>
</secret>
EOF

virsh secret-set-value --secret f3e54e0c-dc0d-4275-969c-ed3d9c99cf6f --base64 $(cat /root/client.cinder)



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
rbd_secret_uuid = f3e54e0c-dc0d-4275-969c-ed3d9c99cf6f
report_discard_supported = true


Nova

cat << EOF > nova-ceph.xml
<secret ephemeral="no" private="no">
<uuid>f8039eb5-7295-41ab-80ef-330b4c4dd369</uuid>
<usage type="ceph">
<name>client.nova secret</name>
</usage>
</secret>
EOF

virsh secret-set-value --secret f8039eb5-7295-41ab-80ef-330b4c4dd369 --base64 $(cat /root/client.nova)

