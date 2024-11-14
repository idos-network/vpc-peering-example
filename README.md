# VPC_Peering
AWS VPC Peering Setup Documentation
Objective
This document provides detailed information about the configuration and purpose of each Terraform file used to set up AWS VPC peering. The goal is to establish a peering connection between two AWS VPCs and enable private communication between instances in these VPCs.
1. vpc1_main.tf
This file defines the AWS resources for VPC1, including its networking components. Below are the details:
- **aws_vpc.vpc1**: Creates a VPC with a CIDR block of `10.0.0.0/16`.
- **aws_subnet.subnet1**: Defines a public subnet in the VPC with a CIDR block of `10.0.1.0/24`.
- **aws_internet_gateway.example_igw**: Adds an internet gateway to the VPC to enable internet access.
- **aws_route_table.example_route_table**: Creates a route table with a default route to the internet gateway.
- **aws_route_table_association.example_route_table_assoc**: Associates the route table with the subnet.
- **aws_security_group.vpc1_sg**: Creates a security group that allows SSH and ICMP traffic.
- **tls_private_key.example_vpc1**: Generates an RSA private key.
- **aws_key_pair.generated_key_vpc1_**: Adds the corresponding public key as an EC2 key pair.
- **aws_instance.vpc1_instance**: Launches an EC2 instance in the subnet using the security group.
2. vpc2_main.tf
This file defines the AWS resources for VPC2, mirroring the configuration of VPC1. Below are the details:
- **aws_vpc.vpc2**: Creates a VPC with a CIDR block of `10.1.0.0/16`.
- **aws_subnet.subnet2**: Defines a public subnet in the VPC with a CIDR block of `10.1.1.0/24`.
- **aws_internet_gateway.example_igw_vpc2**: Adds an internet gateway to the VPC to enable internet access.
- **aws_route_table.example_route_table_vpc2**: Creates a route table with a default route to the internet gateway.
- **aws_route_table_association.example_route_table_assoc_vpc2**: Associates the route table with the subnet.
- **aws_security_group.vpc2_sg**: Creates a security group that allows SSH and ICMP traffic.
- **tls_private_key.example_vpc2**: Generates an RSA private key.
- **aws_key_pair.generated_key_vpc2_**: Adds the corresponding public key as an EC2 key pair.
- **aws_instance.vpc2_instance**: Launches an EC2 instance in the subnet using the security group.
3. vpc_peering.tf
This file sets up the peering connection between VPC1 and VPC2, along with the necessary routing:
- **null_resource.wait_for_vpc_propagation**: Adds a delay to ensure that VPC IDs are propagated before creating the peering connection.
- **aws_vpc_peering_connection.vpc1_to_vpc2**: Establishes a peering connection between VPC1 and VPC2.
- **aws_route.vpc1_to_vpc2_route**: Adds a route in VPC1's route table to direct traffic to VPC2 via the peering connection.
- **aws_route.vpc2_to_vpc1_route**: Adds a route in VPC2's route table to direct traffic to VPC1 via the peering connection.
Results
The Terraform configuration successfully set up VPC peering between VPC1 and VPC2. Instances in both VPCs can communicate over their private IPs.
Verification Steps
1. SSH into the instance in VPC1 using its public IP and verify connectivity to VPC2's instance:
   ```bash
   ssh -i private_key.pem ec2-user@<VPC1_PUBLIC_IP>
   ping <VPC2_PRIVATE_IP>
   ```
2. SSH into the instance in VPC2 using its public IP and verify connectivity to VPC1's instance:
   ```bash
   ssh -i private_key.pem ec2-user@<VPC2_PUBLIC_IP>
   ping <VPC1_PRIVATE_IP>
   ```