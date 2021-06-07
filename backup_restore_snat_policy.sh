#!/bin/bash
# :backup & remove:
#   getting active snatpolicy names
#   save their config in .yaml 
#   remove/delete them.
# :restore:
#   re-deploy using the details recorded in step 1.
# Take bash argument to perform each task at a time.

set -x

backup()
{
    readarray -t snatPolicies < <(kubectl get snatpolicy -A -o name)
    declare -p snatPolicies
    for i in ${!snatPolicies[@]}
    do
        kubectl get ${snatPolicies[$i]} -o yaml > ${backup_location}/snat_$i.yaml
        kubectl delete ${snatPolicies[$i]}
    done
    # kubectl get -o=yaml $(kubectl get -o name snatpolicy) > ${backup_location}/snat_policy.bak
    # kubectl delete $(kubectl get -o name snatpolicy)
}

apply()
{
    for i in $(ls ${restore_location}/snat_*.yaml)
    do
        kubectl apply -f $i
    done
    # kubectl apply -f ~${restore_location}/snat_policy.bak
}

help()
{
    echo "Backup snat policies currently running on your cluster"
    echo "or, apply previously backed up snat policies."
    echo
    echo "Usage: $0 [<option> [<path>]]"
    echo "Options:"
    echo "-h or --help      Show usage"
    echo "-b or --backup    Specify backup location"
    echo "-a or --apply     Specify location from where to restore"
}

if [[ $# -eq 1  || $# -eq 2 ]]
then
    opt=$1
    case $opt in
        -b|--backup)
        backup_location="/tmp"
        if [ ! -z $2 ];then backup_location=$2;fi
        echo "Backing up at: ${backup_location}"
        backup
        ;;
        -a|--apply)
        restore_location="/tmp"
        if [ ! -z $2 ];then restore_location=$2;fi
        echo "Applying from: ${restore_location}"
        apply
        ;;
        -h|--help)
        help
        ;;
        *)
        echo "Invalid option. Try $0 --help instead."
    esac
else
    echo "Invalid Usage. Try $0 --help instead."
fi
