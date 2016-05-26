#!/usr/bin/env bash

. $(dirname ${BASH_SOURCE})/util.sh

export SLAVE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_slave_1)
export ETCD_AUTHORITY=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_etcd_1):2379
export MARATHON_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_marathon_1)

desc "I can access the frontend"
run "echo '<----- see left pane'"
desc "But I can also access redis"
run "docker exec netmodules_client_1 docker run --rm redis:alpine redis-cli -h redis.marathon.mesos -p 6379 SET hits 0"

desc "This is bad news, so lets add some policy"

desc "Let's define a policy that only allows redis to accept inbound connections from the frontend"
run "cat $(relative redis-policy.yaml)"
run "./calicoctl create --filename=./redis-policy.yaml"

desc "Our frontend policy will need to accept connections from anywhere, but only outbound connect to redis"
run "cat $(relative frontend-policy.yaml)"
run "./calicoctl create --filename=./frontend-policy.yaml"

desc "We can no longer access redis directly - only the frontend can"
run "docker exec netmodules_client_1 docker run -i  --rm redis:alpine redis-cli -h redis.marathon.mesos -p 6379 ping"

desc "This is still true when we scale our frontend"
run "curl -X PUT -H 'Content-Type: application/json' http://$MARATHON_IP:8080/v2/apps/frontend -d @$(relative frontend-3.json)"
