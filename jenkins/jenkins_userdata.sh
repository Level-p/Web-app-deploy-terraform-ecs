#!/bin/bash
sudo yum update -y
# install dependencies-wget,pip,git,maven
sudo yum install wget git pip maven -y
# install amazon-ssm-agent
sudo dnf install -y https://s3."${region}".amazonaws.com/amazon-ssm-"${region}"/latest/linux_amd64/amazon-ssm-agent.rpm
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm
# get jenkins repo
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo
# import jenkins key
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
# install Java 21 (IMPORTANT)
sudo yum install -y java-21-openjdk java-21-openjdk-devel
# FORCE Java 21 as system default (CRITICAL FIX)
sudo alternatives --install /usr/bin/java java /usr/lib/jvm/java-21-openjdk/bin/java 2
sudo alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-21-openjdk/bin/javac 2
sudo alternatives --set java /usr/lib/jvm/java-21-openjdk/bin/java
sudo alternatives --set javac /usr/lib/jvm/java-21-openjdk/bin/javac
# verify java version
java -version
javac -version
# install Jenkins
sudo yum install -y jenkins
# DO NOT hardcode JAVA_HOME (important fix)
# Jenkins will use system java automatically now
# enable and start Jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins
# wait for Jenkins to stabilize
sleep 10
sudo usermod -aG jenkins ec2-user
# Install trivy for container scanning
RELEASE_VERSION=$(grep -Po '(?<=VERSION_ID=")[0-9]' /etc/os-release)
cat << EOT | sudo tee -a /etc/yum.repos.d/trivy.repo
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/$RELEASE_VERSION/\$basearch/
gpgcheck=0
enabled=1
EOT
sudo yum -y update
sudo yum -y install trivy

# install docker
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce -y
sudo service docker start
sudo systemctl start docker
sudo systemctl enable docker
# add jenkins and ec2-user to docker group
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins
sudo chmod 777 /var/run/docker.sock

# Installing awscli
sudo yum install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
sudo ln -svf /usr/local/bin/aws /usr/bin/aws
sudo hostnamectl set-hostname jenkins