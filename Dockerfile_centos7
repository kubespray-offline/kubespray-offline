FROM centos:7

RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-19.03.13.tgz | tar zxvf - --strip 1 -C /usr/local/bin docker/docker
RUN yum install -y libselinux-utils patch sudo which python3

COPY . .
RUN mv /igz_files/* .
ENTRYPOINT ["/igz_make_offline.sh"]
