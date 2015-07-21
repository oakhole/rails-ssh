# Centos中部署ROR应用环境
FROM centos:6.6
MAINTAINER Oakhole <evilefy@gmail.com>

# 安装基础工具包
RUN yum update -y
RUN yum install -y which tar curl git

# 配置ruby on rails环境
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c "source /etc/profile.d/rvm.sh"
RUN /bin/bash -l -c "rvm install 2.2"
RUN /bin/bash -l -c "rvm use 2.2 --default"
RUN /bin/bash -l -c "gem sources --remove https://rubygems.org/"
RUN /bin/bash -l -c "gem sources -a https://ruby.taobao.org/"
RUN /bin/bash -l -c "gem install rails"

# 添加项目repo
RUN git clone https://git.oschina.net/oakhole/docker-dev.git /var/www
RUN /bin/bash -l -c "cd /var/www/ruby-dev && bundle install"

# 安装ssh-server并添加自启动
RUN yum install -y openssh-server

RUN mkdir /var/run/sshd
RUN sed -i 's/^PermitRootLogin/#PermitRootLogin/' /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
RUN echo "root:root" | chpasswd

# SSH访问端口
EXPOSE 22

# HTTP访问端口
EXPOSE 80

# 设置命令执行路径
WORKDIR /var/www/ruby-dev

# 初始容器执行命令，防止容器执行命令结束后关闭
CMD service sshd restart && /bin/bash -l -c "rails s -b 0.0.0.0 -p 80"
