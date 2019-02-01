# Initial variables
os ?= $(shell uname -s)

# Load custom setitngs
-include .env
export
PROVISION ?= docker
include etc/$(PROVISION)/makefile

install i: | build test open ## Perform install tasks (build, test, and open)

tag: ## Tag and push current branch. Usage make tag version=<semver>
	git tag -a $(version) -m "Version $(version)"
	git push origin $(version)

squash:
	git rebase -i $(shell git merge-base origin/$(shell git rev-parse --abbrev-ref HEAD) origin/master)
	git push -f

publish: | test release checknewrelease checkoutlatesttag deploy ## Tag and deploy version. Registry authentication required. Usage: make publish
	git checkout master

review: container ?= app
review: version := $(shell git rev-parse --abbrev-ref HEAD)
review: ## Tag, deploy and push image of the current branch. Update service. Registry authentication required. Usage: make review
	make build container=
	make test container=
	make deploy
	make updateservice

push: branch := $(shell git rev-parse --abbrev-ref HEAD)
push: ## Review, add, commit and push changes using commitizen. Usage: make push
	git diff
	git add -A .
	@docker run --rm -it -e CUSTOM=true -v $(CURDIR):/app -v $(HOME)/.gitconfig:/root/.gitconfig aplyca/commitizen
	git pull origin $(branch)
	git push -u origin $(branch)

checkoutlatesttag:
	git fetch --prune origin "+refs/tags/*:refs/tags/*"
	git checkout $(shell git describe --always --abbrev=0 --tags)

test: ## Running test
	$(info Go to $(subst 0.0.0.0,localhost,http://$(shell docker-compose port app 8182))/iiif/2/d49220a9-99fc-4c10-926c-c411ba808bb0.jpg/full/full/0/default.jpg)

h help: ## This help.
	@echo 'Usage: make <task>' 
	@echo 'Default task: install'
	@echo
	@echo 'Tasks:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9., _-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := install
.PHONY: all
