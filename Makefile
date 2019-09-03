NAME := prosody-rpi
TAG := 0.11.2
IMAGE_NAME := sbriskin/$(NAME)

.PHONY: help build push clean

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\ \1\ :\2/' | column -c2 -t -s :)\n"

build: ## Builds docker image
	docker build --pull -t $(IMAGE_NAME):$(TAG) .
	docker images | grep $(IMAGE_NAME)

push: ## Pushes the docker image to docker.io
	# Don't --pull here, we don't want any last minute upsteam changes
	docker build -t $(IMAGE_NAME):$(TAG) .
	docker tag $(IMAGE_NAME):$(TAG) $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):$(TAG)
	docker push $(IMAGE_NAME):latest
	docker images | grep $(IMAGE_NAME)

clean: ## Remove built images
	docker rmi $(IMAGE_NAME):$(TAG)
	docker rmi $(IMAGE_NAME):latest

run: ## Run container
	docker run -d --name $(NAME) --restart unless-stopped \
		-p 5080:80 \
		-p 5443:443 \
		-p 5222:5222 \
		-p 5269:5269 \
		-p 5347:5347 \
		-p 5280:5280 \
		-p 5281:5281 \
		-e LOCAL=user \
		-e DOMAIN=localhost \
		-e PASSWORD=secret \
		-v `pwd`/config:/etc/prosody \
		-v `pwd`/log:/var/log/prosody \
	$(IMAGE_NAME):$(TAG)
	sleep 3 && docker ps -a

shell: ## Start interactive shell inside container
	docker exec -it $(NAME) /bin/bash

kill: ## Stop and remove container
	docker kill $(NAME)
	docker rm $(NAME)
