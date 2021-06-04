# 1. getting active snatpolicy names
# 2. save their config in .yaml 
# 3. remove/delete them.
# ---- run snat tests ----
# 3. re-deploy using the details recorded in step 1.

#!/bin/bash
set -x
readarray -t snatPolicies < <(kubectl get snatpolicy -A -o name| tail +2)
declare -p snatPolicies
for i in ${!snatPolicies[@]}
do
    kubectl get snatpolicy ${snatPolicies[$i]} -o yaml > /tmp/snat_$i.yaml
    kubectl delete snatpolicy ${snatPolicies[$i]}
done

# command to run snat tests

for i in ${!snatPolicies[@]}
do
    kubectl apply -f /tmp/snat_$i.yaml
done