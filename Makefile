.PHONY: run backup

BACKUP_EXCLUDES = \
	--exclude=node_modules \
	--exclude=.npm \
	--exclude=public \
	--exclude=db.json \
	--exclude=.bash_history \
	--exclude=.lesshst \
	--exclude=.viminfo \
	--exclude='*.log' \
	--exclude=.DS_Store \
	--exclude=Thumbs.db \
	--exclude='.deploy*' \
	--exclude=_multiconfig.yml

run:
	-docker system prune -f
	docker run --pull=always --privileged --rm -it --name node --network host -e DEBIAN_FRONTEND=noninteractive -v /root:/root -v $$(pwd)/:/data node:lts bash

backup:
	tar -cvf ~/hexo.tar $(BACKUP_EXCLUDES) -C $(CURDIR) .
