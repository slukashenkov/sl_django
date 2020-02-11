FROM centos:7
#FROM centos:7.7.1908

MAINTAINER  slonikov

COPY nginx.repo /etc/yum.repos.d
RUN yum -y update
RUN yum -y install epel-release
RUN yum -y install which
RUN yum -y install nginx
RUN yum -y install openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:abc123' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN  /usr/bin/ssh-keygen -A

#Install Pip/Python related stuff

RUN yum clean all &&\
    yum makecache &&\
    yum repolist
RUN yum -y groupinstall 'development tools'&&\
    yum -y install vim
RUN yum -y install python-pip &&\
    yum -y install https://centos7.iuscommunity.org/ius-release.rpm &&\
    yum -y update &&\
    yum -y install -y python36u python36u-libs python36u-devel python36u-pip

RUN pip3.6 install --upgrade pip
RUN pip3.6 install uwsgi
RUN pip3.6 install django
RUN pip3.6 install psycopg2

WORKDIR /etc/nginx
COPY uwsgi.ini .
COPY nginx.conf .

WORKDIR /etc/nginx/conf.d
COPY default.conf .

RUN mkdir /usr/bin/web_django
WORKDIR /usr/bin/web_django
COPY start_srvs.bash .
COPY web_django .

EXPOSE 80
EXPOSE 22

CMD ["./start_srvs.bash"]
#CMD ["/usr/sbin/sshd", "-D"]