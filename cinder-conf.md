    [DEFAULT]
    scheduler_default_filters = DriverFilter
    cinder_internal_tenant_user_id = baa0dd22ea5b4edf8fc818583cce617d
    cinder_internal_tenant_project_id = eea2d3d81d94453faaa12f2ea7f1dafd
    graceful_shutdown_timeout = 5
    glance_api_version = 2
    glance_api_servers = http://192.168.53.129/image
    osapi_volume_workers = 6
    logging_exception_prefix = ERROR %(name)s ^[[01;35m%(instance)s^[[00m
    logging_default_format_string = %(color)s%(levelname)s %(name)s [^[[00;36m-%(color)s] ^[[01;35m%(instance)s%(color)s%(message)s^[[00m
    logging_context_format_string = %(color)s%(levelname)s %(name)s [^[[01;36m%(global_request_id)s %(request_id)s ^[[00;36m%(project_name)s %(user_name)s%(color)s] ^[[01;35m%(instance)s%(color)s%(message)s^[[00m
    logging_debug_format_suffix = ^[[00;33m{{(pid=%(process)d) %(funcName)s %(pathname)s:%(lineno)d}}^[[00m
    transport_url = rabbit://stackrabbit:Vccloud123$%^@192.168.53.129:5672/
    default_volume_type = scaleio
    #enabled_backends = lvmdriver-1
    enabled_backends = scaleio
    #enabled_backends = vxflexos
    my_ip = 192.168.53.129
    state_path = /opt/stack/data/cinder
    osapi_volume_listen = 0.0.0.0
    osapi_volume_extension = cinder.api.contrib.standard_extensions
    rootwrap_config = /etc/cinder/rootwrap.conf
    api_paste_config = /etc/cinder/api-paste.ini
    target_helper = tgtadm
    debug = True

    [database]
    connection = mysql+pymysql://root:Vccloud123$%^@127.0.0.1/cinder?charset=utf8

    [oslo_concurrency]
    lock_path = /opt/stack/data/cinder

    [key_manager]
    fixed_key = bae3516cc1c0eb18b05440eba8012a4a880a2ee04d584a9c1579445e675b12defdc716ec
    backend = cinder.keymgr.conf_key_mgr.ConfKeyManager

    [scaleio]
    volume_driver = cinder.volume.drivers.dell_emc.scaleio.driver.ScaleIODriver
    #volume_driver = cinder.volume.drivers.dell_emc.vxflexos.driver.VxFlexOSDriver
    volume_backend_name = scaleio
    #volume_backend_name = vxflexos
    san_ip = 192.168.53.126
    #sio_protection_domain_name = default
    #sio_storage_pool_name = default
    vxflexos_storage_pools = default:default
    san_login = admin
    san_password = Huy123456
    san_thin_provision = True
    sio_allow_non_padded_thick_volumes = True
    vxflexos_allow_non_padded_volumes = True
