## Live-migration

    openstack  --os-compute-api-version 2.30 server migrate  --live-migration --block-migration --host ops2 ef6328a9-7f58-44a6-b808-9f9448be4969

## Create VM

    openstack server create --volume e3c4a224-08fc-4f82-93e9-ad8ddb7803e6  --flavor m1.benchmark --key-name huy --security-group basic --nic net-id=8ee3ba1f-3cea-44b5-8b26-13c1bd75d5a1 --availability-zone nova:ops3 testops3
    
## reset state

    cinder reset-state --state available --attach-status detached 
