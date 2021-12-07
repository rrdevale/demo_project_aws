output "instance_ip" {
  value = module.my-server.ec2_public_ip.public_ip 
}