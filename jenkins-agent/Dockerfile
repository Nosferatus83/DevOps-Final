#Это Docker file для Jenkins Agent

#Собераем образ: docker build -f Dockerfile -t nosferatus83/devops-final-jagent .
#Логинимся в Dockehub: docker login
#Заливаем образ на Dockehub: docker push nosferatus83/devops-final-jagent

#Using base image Ubuntu 20.04
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive

#Update Repos
RUN apt update

#Install required tools & packages for agent

#Install unzip
RUN apt install unzip -y

#Install wget
RUN apt install wget -y

#Install Git
RUN apt install git -y

#Install Terraform
WORKDIR /tmp
RUN wget https://releases.hashicorp.com/terraform/0.15.1/terraform_0.15.1_linux_amd64.zip
RUN unzip terraform_0.15.1_linux_amd64.zip
RUN chmod +x terraform
RUN cp terraform /bin

#Install Ansible
RUN apt install software-properties-common -y
RUN apt-add-repository --yes --update ppa:ansible/ansible -y
RUN apt install ansible -y

#Generate keys and configire SSH for user Root
RUN ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa
CMD echo 'StrictHostKeyChecking no' >>  /etc/ssh/ssh_config
RUN sed -i -e "s/#host_key_checking = False/host_key_checking = False/g" /etc/ansible/ansible.cfg

# Clear cache
RUN apt-get clean