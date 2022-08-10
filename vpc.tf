#vpc
resource "aws_vpc" "server1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "server1-vpc"
  }
}
#internetgateway
resource "aws_internet_gateway" "myInternetGateway" {
  vpc_id = aws_vpc.server1.id
  tags = {
    Name = "myinternetgw"
  }
}
#public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.server1.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "server1-publicSubnet"
  }
}
#private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.server1.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "server1-PrivateSubnet"
  }
}
resource "aws_eip" "nat_eip"{
  vpc=true
}
#natgatway
resource "aws_nat_gateway" "myNatGateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id         = aws_subnet.public.id
  tags = {
    Name = "myNatGateway"
  }
}
#route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.server1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myInternetGateway.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.server1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNatGateway.id
  }
  tags = {
    Name = "privateRouteTable"
  }
}
# routetableassociation
resource "aws_route_table_association" "forPublic" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "forPrivate" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
#security group
resource "aws_security_group" "public" {
  name = "my-public-sg"
  description = "Public internet access"
  vpc_id = aws_vpc.server1.id
  tags = {
    Name        = "my_sg"
  }
}
#ingree
resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
#egress
resource "aws_security_group_rule" "public_in_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_s3_bucket" "bucket" {
  bucket = " My Terraform_bucket"
  tags = {
    Name        = "My bucket"
  }
  versioning {
    enabled = true
  }
}
resource "aws_s3_bucket_acl" "b_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "log-delivery-write"
}
locals {
  s3_origin_id = "myS3Origin"
}
resource "aws_cloudfront_origin_access_identity" "example" {
  comment = "helo"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.example.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "helo"
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress              = true
    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_200"
  viewer_certificate {
    cloudfront_default_certificate = true
    }
    restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

