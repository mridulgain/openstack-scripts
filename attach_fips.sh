#      1. go to ~/openupi (assume this dir will be there, if not exit)
#      2. source overcloudrc
#      3. list the openstack servers
#      4. associate floating ip to those servers, if not attached.
#      5. server & corresponding floating ip.

#!/bin/bash
set -x
if [ -d ~/openupi ]
then
    # 1
    cd ~/openupi
    # 2
    source overcloudrc
    # 3
    readarray -t servers_without_fip < <(openstack server list -f value -c Name -c Networks | awk '{if($3 == "")print($1)}')
    declare -p servers_without_fip
    readarray -t unused_fips < <(openstack floating ip list -f value | awk '{if($3 == "None")print($2)}')
    declare -p unused_fips
    # 4
    for i in ${!servers_without_fip[@]}
    do
        if [ $i -lt ${#unused_fips[@]} ]
        then
            openstack server add floating ip ${servers_without_fip[$i]} ${unused_fips[$i]} 
        else
            echo "No more unused floating ips are there to associate with servers. Please add more and rerun this script".
            break
        fi
    done
    # 5
    echo "-----------Server Name > Floating Ip-----------"
    openstack server list -f value -c Name -c Networks | awk '{print($1,">",$3)}'

fi 


#     readarray -t server_names < <(openstack server list -f value -c Name)
#     declare -p server_names
#     readarray -t fips < <(openstack server list -f value -c Networks | awk '{split($0, net, ";"); split(net[1], ip); print(ip[2])}')
#     declare -p fips

# openstack server list --fit-width
# openstack server list --name 'openupi-pqqjk-master-0' -f value -c Networks | awk '{print $2}'

# openstack server list -f value -c Name -c Networks | awk '{if($3 == "")print($1)}'
# openstack floating ip list -f value | awk '{if($3 == "None")print($2)}'

# openstack server create --flavor m1.medium --image rhcos-4.5 --network 2cf5588a-3749-433c-ae02-67f044daa0a8 without_fip

# openstack server add floating ip with_fip 60.60.60.199 
# openstack server remove floating ip with_fip 60.60.60.199 
# openstack server add floating ip openupi-pqqjk-worker-q8h45 60.60.60.37