FROM ubuntu

MAINTAINER Adrian Goins "monachus@arces.net"

RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ precise main restricted universe" > /etc/apt/sources.list
RUN apt-get -y update

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -y install redis-server supervisor

ADD docker_files/redis.conf /etc/redis/redis.conf
ADD docker_files/docker.conf /etc/supervisor/conf.d/
ADD docker_files/start /start

EXPOSE 6379 9999

CMD ["/start"]