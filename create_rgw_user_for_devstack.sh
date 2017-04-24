#!/bin/bash
echo -e "----------------------------------------------------------------------"
echo -e "*                Creating RGW user for swift 					      *"
echo -e "----------------------------------------------------------------------"

sudo radosgw-admin user create --subuser="admin:admin" --uid="admin"
--display-name="admin" --key-type=swift --secret="secrete" --access=full