PYTHON := /usr/bin/env python
PROJECT=bundletester
VERSION=$(shell cat VERSION)

all: lint test

.PHONY: deps
deps: .venv
	@echo Updating dependency wheels...
	@.venv/bin/pip wheel -w deps -r requirements.txt

clean:
	rm -rf MANIFEST dist/* bundletester.egg-inf .cover
	find . -name '*.pyc' -delete
	rm -rf .venv
	rm -rf .cover

test: .venv
	@echo Starting tests...
	@./bin/nosetests

coverage: .venv
	@echo Starting tests...
	@./bin/nosetests --with-coverage
	@xdg-open .cover/index.html


ftest:
	@echo Starting fast tests...
	@./bin/nosetests --attr '!slow' --nologcapture

lint:
	@flake8 $(PROJECT) $(TESTS) && echo OK

.venv:
	./bin/test_setup

release:
	git remote | xargs -L1 git fetch --tags
	$(PYTHON) setup.py register sdist upload
	git tag ${VERSION}
	git remote | xargs -L1 git push --tags
	@if [ -n "${CHARMBOX_TOKEN}" ]; then \
	    echo 'Rebuilding charmbox' ; \
	    curl --data "build=true" -X POST https://registry.hub.docker.com/u/johnsca/charmbox/trigger/$(CHARMBOX_TOKEN)/ ; \
	else \
	    echo 'Not rebuilding charmbox due to missing CHARMBOX_TOKEN' ; \
	fi
