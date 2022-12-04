# Add outputs to this file
output "webserver_public_ip" {
  value = <<EOT
    Access the webserver(s) by going to the following location(s):
    %{ for ip in aws_instance.webserver.*.public_ip }http://${ip}%{ endfor }
    EOT
}