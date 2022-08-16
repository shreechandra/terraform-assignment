  resource "aws_instance" "myInstance" {
  ami           = "ami-0b02eacf129bfac4e"
  instance_type = "t2.micro"
  key_name = "redgear"
  tags                         = {
        "Name" = "instance1"
    }
    user_data = <<-EOF
                  #!/bin/bash
                  sudo apt update -y
                  sudo apt-get install -y apache2
                  sudo systemctl start apache2
                  sudo systemctl enable apache2
                  sudo apt update
                EOF
}
