init:
	git config core.hooksPath .githooks
	gem install bundle
	bundle install

install:
	scripts/deploy_local.sh

test:
	rake test:all

e2e:
	rake test:e2e