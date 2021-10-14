## Tích hợp Scaleio làm block device cho Openstack

Cấu hình `/etc/cinder/cinder.conf`:

    [DEFAULT]
    enabled_backends = scaleio
    [scaleio]
    volume_driver = cinder.volume.drivers.emc.scaleio.ScaleIODriver
    volume_backend_name = scaleio
    san_ip = 172.16.68.80
    sio_protection_domain_name = default
    sio_storage_pool_name = default
    sio_storage_pools = default:default
    san_login = admin
    san_password = MDM_PASSWORD
