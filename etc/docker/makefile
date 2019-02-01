requirements: ## Installing local requirements
ifeq ($(os), Darwin)
	grep -q 'brew' <<< echo `command -v brew` || /usr/bin/ruby -e "`curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install`"
	brew install make git
	brew cask install docker
	open -a Docker
else ifeq ($(os), Linux)
	sudo sh -c "$$(curl -fsSL https://get.docker.com)"
	sudo apt-get install make git
	sudo usermod -aG docker $${USER}
	sudo service docker start
	sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(os)-$(shell uname -m) -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	su - $${USER}
else ifeq ($(os), Windows_NT)
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
	choco install make git docker-for-windows -y
else
	$(warning Platform "$(os)" not supported)
endif

ifdef command
override command := -c "$(command)"
endif

ifdef profile
override profile := --profile $(profile)
endif

ifeq ($(os), Darwin)
open = open
else ifeq ($(os), Linux)
open = xdg-open
else ifeq ($(os), Windows_NT)
open =  explorer
endif

build:
	docker-compose up --build -d --remove-orphans $(container)

remove:
	docker-compose rm --force $(container)

reload up: ## Reload containers 
	docker-compose up -d $(container)

down:
	docker-compose down $(container)

stop:
	docker-compose stop $(container)

start:
	docker-compose start $(container)

restart:
	docker-compose restart $(container)

reboot: | down up ## Recreate containers

status ps:
	docker-compose ps $(container)

cli exec: container ?= app
cli exec: ## Execute commands in containers, use "command"  argument to send the command. By Default enter the shell.
	docker-compose exec $(container) /bin/ash $(command)

run: container ?= app
run: ## Run commands in a new container
	docker-compose run --rm $(container) /bin/ash $(command)

config:
	docker-compose config

logs: container ?= app
logs: ## Show logs
	docker-compose logs -f $(container)

open: ## Open web app in the browser
	$(open) $(subst 0.0.0.0,localhost,http://$(shell docker-compose port app 8182))/iiif/2/d49220a9-99fc-4c10-926c-c411ba808bb0.jpg/full/full/0/default.jpg

open.admin: ## Open admin app in the browser
	$(open) $(subst 0.0.0.0,localhost,http://$(shell docker-compose port app 8182))/admin

open.storage:
	$(open) $(subst 0.0.0.0,localhost,http://$(shell docker-compose port storage 9000))

expose: ## Expose your local environment to the internet, thanks to Serveo (https://serveo.net)
	ssh -R 80:localhost:$(subst 0.0.0.0:,,$(shell docker-compose port app 8182)) serveo.net

ecslogin:
	$(shell docker run --rm -it --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} infrastructureascode/aws-cli ash -c "aws ecr get-login --no-include-email --region us-east-2")

release:
	git checkout production
	docker run --rm -it -v $(CURDIR):/app -v ~/.ssh:/root/.ssh -w /app aplyca/semantic-release ash -c "semantic-release --no-ci"
	git pull

updateservice: service ?= FOLGERDAP-IIIF-Staging
updateservice: ## 🚀  Update service in ECS, default FOLGERDAP-Client-Staging
	$(info 🚀  Updating service $(service) ...)
	@docker run --rm -it --env AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} --env AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} infrastructureascode/aws-cli:1.16.23 ash -c "aws ecs update-service --cluster FOLGERDAP --service $(service) --force-new-deployment --region us-east-2 --query 'service.{status:status,pendingCount:pendingCount,desiredCount:desiredCount,runningCount:runningCount,serviceName:serviceName,taskDefinition:taskDefinition}'"

deploy: container ?= app
deploy: registryurl ?= 159895783284.dkr.ecr.us-east-2.amazonaws.com/folgerdap/iiif/$(container)
deploy: version ?= $(shell git describe --always --abbrev=0 --tags)
deploy: ecslogin ## Login to Registry, build, tag and push the images. Registry authentication required. Usage: make deploy version="<semver>". Use version=latest to create the latest image
	docker build --target prod -t $(registryurl):$(version) -f etc/docker/$(container)/Dockerfile .
	docker push $(registryurl):$(version)

deploylatest: version ?= $(shell git describe --always --abbrev=0 --tags)
deploylatest: ## Login to Registry, build, tag with the latest images and push to registry. Registry authentication required. Usage: make deploylatest version="<semver>"
	docker tag $(registryurl):$(version) $(registryurl):latest
	docker push $(registryurl):latest