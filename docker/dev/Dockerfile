from aman/todobackend-base:latest

MAINTAINER Aman Kumar<amankumar0511@gmail.com>

# Install dev/buil dependencies

RUN apt-get update && \
	apt-get install -y vim && \
	apt-get install -qy python3-dev libpython3.6-dev libmysqlclient-dev \
	build-essential libssl-dev libffi-dev \
    libxml2-dev libxslt1-dev zlib1g-dev \
    python-pip



# Activate the virtual enviroment and install wheel support

RUN . /appenv/bin/activate && \
	pip install wheel


# Pip environment varaibles (Note Must be set after installing wheel)

ENV WHEELHOUSE=/wheelhouse PIP_WHEEL_DIR=/wheelhouse PIP_FIND_LINKS=/wheelhouse XDG_CACHE_HOME=/cache


#output: BUild artefacts(Wheels are output here)
VOLUME /wheelhouse

#Output: Test reports are output here

VOLUME /reports

#output Build cache

volume /build

# Add test entrypoint script


COPY scripts/test.sh /usr/local/bin/test.sh
RUN chmod +x /usr/local/bin/test.sh



COPY src /application

WORKDIR /application

ENTRYPOINT ["test.sh"]


CMD ["python", "manage.py", "test", "--noinput"]
