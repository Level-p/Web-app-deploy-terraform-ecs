output "jenkins_public_ip" {
  value = aws_instance.jenkins-server.public_ip
}

output "arn_sgroup" {
  value = aws_security_group.jenkins_sg.arn
}