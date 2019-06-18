RUBY_VERSION=2.5

bundle:
	docker run \
		--rm \
		--volume $$(pwd):/usr/src/app \
		--workdir /usr/src/app \
		ruby:$$RUBY_VERSION \
		bundle install

test:
	docker run \
		--tty \
		--rm \
		--volume $$(pwd):/usr/src/app \
		--workdir /usr/src/app \
		ruby:$$RUBY_VERSION \
		./scripts/rspec.sh

test_e2e:
	docker run \
		--tty \
		--rm \
		--volume $$(pwd):/usr/src/app \
		--workdir /usr/src/app \
		ruby:$$RUBY_VERSION \
		./scripts/setup_and_run_end_to_end_tests.sh
