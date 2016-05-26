#!/usr/bin/env bash

. $(dirname ${BASH_SOURCE})/util.sh

export MARATHON_IP=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_marathon_1)
export ETCD_AUTHORITY=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' netmodules_etcd_1):2379

desc "Our application uses a redis database. So let's launch one using marathon."
run "cat $(relative redis.json)"
run "curl -X POST -H 'Content-Type: application/json' http://$MARATHON_IP:8080/v2/apps -d @$(relative redis.json)"
desc ""

desc "A simple Python app that uses redis as its database"
run "cat $(relative app.py)"

desc "Marathon app definition to launch our frontend"
run "cat $(relative frontend.json)"
run "curl -X POST -H 'Content-Type: application/json' http://$MARATHON_IP:8080/v2/apps -d @$(relative frontend.json)"
desc ""

calicoctl profile test rule add inbound allow

tmux new -d -s my-session-2 \
    "$(dirname ${BASH_SOURCE})/split1_lhs.sh" \; \
    split-window -h -d "sleep 10; $(dirname $BASH_SOURCE)/split1_rhs.sh" \; \
    attach \;
