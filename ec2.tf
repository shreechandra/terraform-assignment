  associate_public_ip_address = true
  subnet_id = aws_subnet.mysubnet1.id
  vpc_security_group_ids = [aws_security_group.allow.id]
  iam_instance_profile =  "${aws_iam_instance_profile.ec2_shree}"

  tags = {
    Name = "instant"
  }
  volume_tags = {
    "Name" = "terraform"
  }
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                
                sudo apt install ruby-full -y
                sudo apt install wget -y 
                sudo wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
                sudo chmod +x ./install
                sudo ./install auto  
                sudo service codedeploy-agent status 
                sudo service codedeploy-agent restart
              EOF
