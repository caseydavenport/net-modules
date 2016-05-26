#!/usr/bin/env bash

. $(dirname ${BASH_SOURCE})/util.sh

SLAVE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_slave_1)

desc "I can access the frontend"
run "echo '<----- see left pane'"
desc "But I can also access redis"
run "docker exec netmodules_client_1 docker run --rm redis:alpine redis-cli -h redis.marathon.mesos -p 6379 SET hits 0"

desc "This is bad news, so lets add some policy"
desc "There is no existing policy"
run "docker exec netmodules_slave_1 ./policy list"

desc "Policy for redis access (from frontend only)"
run "cat $(relative redis-policy.yaml)"
run "cat redis-policy.yaml | docker exec netmodules_slave_1 ./policy create -f /dev/stdin"

desc "Policy for frontend access"
run "cat $(relative frontend-policy.yaml)"
run "cat frontend-policy.yaml | ssh $SLAVE_IP ./policy create -f /dev/stdin"

desc "Turn on isolation and traffic keeps flowing"
run "kubectl annotate ns demos 'net.alpha.kubernetes.io/network-isolation=yes' --overwrite=true"

desc "But we can no longer access redis directly - only the frontend can"
run "ssh -i /tmp/key core@ip-10-0-0-50.eu-central-1.compute.internal docker run -i  --rm redis:alpine redis-cli -h redis.marathon.mesos -p 6379 ping"

desc "Remove policy to access redis and the frontend starts giving errors"
run "ssh -i /tmp/key core@ip-10-0-0-50.eu-central-1.compute.internal ./policy delete --namespace demos redis"

desc "Remove policy to access frontend and we can no longer access it at all"
run "ssh -i /tmp/key core@ip-10-0-0-50.eu-central-1.compute.internal ./policy delete --namespace demos frontend"

desc "Turn off isolation and traffic resumes"
run "kubectl annotate ns demos 'net.alpha.kubernetes.io/network-isolation=off' --overwrite=true"
