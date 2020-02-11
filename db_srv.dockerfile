FROM local/c7-systemd

MAINTAINER  slonikov

#Install Pip/Python related stuff
#RUN yum -y install epel-release

RUN yum -y update
RUN yum clean all &&\
    yum makecache &&\
    yum repolist
RUN yum install -y https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-centos11-11-2.noarch.rpm
RUN yum install -y postgresql11-server postgresql11
RUN /usr/pgsql-11/bin/postgresql-11-setup initdb
WORKDIR /var/lib/pgsql/11/data
COPY postgresql.conf .
COPY pg_hba.conf .
RUN systemctl enable postgresql-11.service
RUN systemctl start postgresql-11.service

RUN yum -y install which
RUN yum -y install openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:abc123' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN  /usr/bin/ssh-keygen -A

WORKDIR /usr/bin/web_django
COPY start_db.bash .
RUN ./start_db.bash
EXPOSE 22
EXPOSE 5432

CMD ["/usr/sbin/init"]

