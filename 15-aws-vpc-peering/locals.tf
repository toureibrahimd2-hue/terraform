locals {

  tags = merge(var.tags, {
    creation_date = timestamp()
  })

  primary_user_data = <<EOF
  #!/bin/bash
  apt update -y
  apt install -y apache2
  systemctl enable apache2
  systemctl start apache2

  echo "<h1>Hello World from ${var.aws_region_first} VPC</h1>" > /var/www/html/index.html
  echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
  EOF

  secondary_user_data = <<-EOF
  #!/bin/bash
  apt update -y
  apt install -y nginx
  systemctl enable nginx
  systemctl start nginx

  echo "<h1>Hello World from ${var.aws_region_second} VPC</h1>" > /var/www/html/index.html
  echo "<p>Private IP: $(hostname -I)</p>" >> /var/www/html/index.html
  EOF
}