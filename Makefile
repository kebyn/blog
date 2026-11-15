.PHONY: run backup

run:
	-docker system prune -f
	docker run --pull=always --privileged --rm -it --name node --network host -e DEBIAN_FRONTEND=noninteractive -v /root:/root -v $$(pwd)/:/data node:lts bash

backup:
	tar -cvf ~/hexo.tar -C $(CURDIR) .
