FROM postgres:11.6

MAINTAINER  slonikov

#Install Pip/Python related stuff
#RUN yum -y install epel-release



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

#WORKDIR /var/lib/pgsql/11/data

WORKDIR /usr/bin/web_django
COPY start_db.bash .
COPY postgresql.conf .
COPY pg_hba.conf .

EXPOSE 22
EXPOSE 5432
CMD ["./start_db.bash"]
