from aman0511/todobackend-base:latest

MAINTAINER Aman Kumar <amankuamr0511@gmail.com>


# copy application artifacts


copy target /wheelhouse

RUN . /appenv/bin/activate && \
	pip install --no-index -f /wheelhouse todobackend && \
	rm -rf /wheelhouse
