yum update -y
yum install -y centos-release-openstack-train
yum update -y
yum install -y openstack-packstack
yum -y update
yum -y install vim wget curl bash-completion
yum update -y



cat > ceph-secret.xml <<EOF
<secret ephemeral='no' private='no'>
<uuid>f3e54e0c-dc0d-4275-969c-ed3d9c99cf6f
      f3e54e0c-dc0d-4275-969c-ed3d9c99cf6f</uuid>
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
rbd_user = volumes #not cinder like some docs
rbd_secret_uuid = f3e54e0c-dc0d-4275-969c-ed3d9c99cf6f
report_discard_supported = true


Nova

cat << EOF > nova-ceph.xml
<secret ephemeral="no" private="no">
<uuid>e3fdf24b-e8cb-440d-908f-2faa02dcb639</uuid>
<usage type="ceph">
<name>client.nova secret</name>
</usage>
</secret>
EOF

virsh secret-set-value --secret e3fdf24b-e8cb-440d-908f-2faa02dcb639 --base64 $(cat /root/client.nova)




tạo vm

tạo keypair:

	openstack keypair create --public-key=~/.ssh/id_rsa.pub adminkey

tạo security groups
	openstack server create --flavor m1.medium --image ccf907e5-70b6-431a-ac5d-4f20351bbfea --network c12e8f1a-c4be-4f24-9bb8-a8f9923f4b12 --security-group 843abb3d-4f8f-429c-bfc6-f9c064c9cb65 --key-name adminkey --block-device uuid=627880cc-a2b4-424a-a3a0-432dcef81567 --wait test-server
