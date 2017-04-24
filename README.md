About
------------
Repository with all devstack mitaka reletad scripts.

Content
-------
1) rest_mitaka - bash tool for sending rest requests to OpenStack Object Storage module - Swift. 
   Supported methods: 
  - create/list/delete container
  - create/list/delete object
  
2) create_rgw_user_for_devstack - bash script for creating rados gateway user. Needed for working with devstack-plugin-ceph
   while deployed using devstack.
