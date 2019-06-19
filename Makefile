RUBY_VERSION=2.5

build_docker_dev:
	docker build \
		--file Dockerfile-dev \
		--rm \
		--tag cfn-nag-dev .

test:
	docker run \
		--tty \
		--rm \
		--volume $$(pwd):/usr/src/app \
		--workdir /usr/src/app \
		cfn-nag-dev:latest \
		./scripts/rspec.sh

test_e2e:
	docker run \
		--tty \
		--rm \
		--volume $$(pwd):/usr/src/app \
		--workdir /usr/src/app \
		cfn-nag-dev:latest \
		./scripts/setup_and_run_end_to_end_tests.sh

rubocop:
	docker run \
		--tty \
		--rm \
		--volume $$(pwd):/usr/src/app \
		--workdir /usr/src/app \
		cfn-nag-dev:latest \
		/bin/bash -c "rubocop -D"
