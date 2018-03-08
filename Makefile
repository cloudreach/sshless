SHELL := /bin/bash


clean: clean-build clean-pyc

version:
	python setup.py --version

clean-build:
	rm -rf build/
	rm -rf dist/
	rm -rf .eggs/
	rm -rf .cache/
	rm -rf .tox/
	rm -rf .pytest_cache/
	rm -rf '*.egg-info/'
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc:
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

lint:
	flake8 --ignore=E722,F405,E501,F403 sshless tests

dist: clean
	python setup.py sdist

pip: dist
	twine upload dist/*

tag_github_release:
	git tag v`python setup.py --version`
	git push origin v`python setup.py --version`


local: clean-build
	python setup.py install
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	rm -rf *.egg-info/

test:
	pytest

test-all:
		tox
		mv Changelog CHANGELOG.rst
