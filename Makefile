CALICO_NODE_VERSION=v0.19.0

default: images

redis: calico/redis.tar
calico/redis.tar:
	docker pull redis:alpine
	mkdir -p calico
	docker save -o calico/redis.tar redis:alpine

calico-node: calico/calico-node-$(CALICO_NODE_VERSION).tar

calico/calico-node-$(CALICO_NODE_VERSION).tar:
	docker pull calico/node:$(CALICO_NODE_VERSION)
	mkdir -p calico
	docker save -o calico/calico-node-$(CALICO_NODE_VERSION).tar calico/node:$(CALICO_NODE_VERSION)

images: calico-node redis pull
	  docker-compose -p mesoscni build

pull: pull.created
pull.created:
	docker-compose -p mesoscni pull
	touch pull.created

clean:
	docker-compose -p mesoscni kill
	docker-compose -p mesoscni rm --force

cluster: images
	docker-compose -p mesoscni up -d
	docker-compose -p mesoscni scale slave=2
	docker-compose run client curl -L -X PUT \
		http://etcd:2379/v2/keys/coreos.com/network/config \
		-d value='{"Network":"10.0.0.0/8","Backend":{"Type":"vxlan"}}'

test-cni:
	docker exec mesoscni_slave_1 mesos-execute \
		--containerizer=mesos \
		--docker_image=busybox \
		--name=test-1 \
		--master=172.17.0.4:5050 \
		--networks=test \
		--command=ifconfig
