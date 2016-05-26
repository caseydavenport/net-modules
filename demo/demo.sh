#!/usr/bin/env bash

. $(dirname ${BASH_SOURCE})/util.sh

export MARATHON_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_marathon_1)
export ETCD_AUTHORITY=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_etcd_1):2379

desc "Run the redis datastore"
run "cat $(relative redis.json)"
run "curl -X POST -H 'Content-Type: application/json' http://$MARATHON_IP:8080/v2/apps -d @$(relative redis.json)"


desc "Use a simple Python app to access redis"
run "cat $(relative app.py)"

desc "Marathon app definition of our frontend"
run "cat $(relative frontend.json)"
run "curl -X POST -H 'Content-Type: application/json' http://$MARATHON_IP:8080/v2/apps -d @$(relative frontend.json)"

calicoctl profile test rule add inbound allow

tmux new -d -s my-session-2 \
    "$(dirname ${BASH_SOURCE})/split1_lhs.sh" \; \
    split-window -h -d "sleep 10; $(dirname $BASH_SOURCE)/split1_rhs.sh" \; \
    attach \;
