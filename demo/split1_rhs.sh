#!/usr/bin/env bash

. $(dirname ${BASH_SOURCE})/util.sh

export SLAVE_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_slave_1)
export ETCD_AUTHORITY=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_etcd_1):2379

desc "I can access the frontend"
run "echo '<----- see left pane'"
desc "But I can also access redis"
run "docker exec netmodules_client_1 docker run --rm redis:alpine redis-cli -h redis.marathon.mesos -p 6379 SET hits 0"

desc "This is bad news, so lets add some policy"

desc "Policy for redis access (from frontend only)"
run "cat $(relative redis-policy.yaml)"
run "./calicoctl create --filename=./redis-policy.yaml"

desc "Policy for frontend access"
run "cat $(relative frontend-policy.yaml)"
run "./calicoctl create --filename=./frontend-policy.yaml"


desc "But we can no longer access redis directly - only the frontend can"
run "docker exec netmodules_client_1 docker run -i  --rm redis:alpine redis-cli -h redis.marathon.mesos -p 6379 ping"

desc "Remove policy to access redis and the frontend starts giving errors"
run "./calicoctl delete policy"

