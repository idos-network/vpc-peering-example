
```markdown
# VPC Peering Example

## Objective
This document provides a clear guide to set up VPC peering between two AWS VPCs using Terraform. The example demonstrates how to configure the networking components required for seamless communication between instances in these VPCs.

## Overview
The Terraform code consists of three files:
1. `vpc1_main.tf`: Sets up VPC1 and its resources.
2. `vpc2_main.tf`: Sets up VPC2 and its resources.
3. `vpc_peering.tf`: Configures the VPC peering connection and routing between VPC1 and VPC2.

The setup allows private communication between VPC1 and VPC2 and supports idOS node deployment.

---

## Files and Configuration

### `vpc1_main.tf`
Defines resources for VPC1:
- **VPC Creation**:
  - `aws_vpc.vpc1`: CIDR block `10.0.0.0/16`.
- **Subnet**:
  - `aws_subnet.subnet1`: CIDR block `10.0.1.0/24`.
- **Internet Gateway**:
  - `aws_internet_gateway.example_igw`: Enables internet access.
- **Route Table**:
  - `aws_route_table.example_route_table`: Adds a default route for the internet.
  - `aws_route_table_association.example_route_table_assoc`: Associates the route table with the subnet.
- **Security Group**:
  - `aws_security_group.vpc1_sg`: Allows inbound SSH and ICMP traffic.
- **EC2 Instance**:
  - `aws_instance.vpc1_instance`: A t2.micro instance launched in the subnet.

### `vpc2_main.tf`
Mirrors VPC1's setup:
- **VPC Creation**:
  - `aws_vpc.vpc2`: CIDR block `10.1.0.0/16`.
- **Subnet**:
  - `aws_subnet.subnet2`: CIDR block `10.1.1.0/24`.
- **Internet Gateway**:
  - `aws_internet_gateway.example_igw_vpc2`: Enables internet access.
- **Route Table**:
  - `aws_route_table.example_route_table_vpc2`: Adds a default route for the internet.
  - `aws_route_table_association.example_route_table_assoc_vpc2`: Associates the route table with the subnet.
- **Security Group**:
  - `aws_security_group.vpc2_sg`: Allows inbound SSH and ICMP traffic.
- **EC2 Instance**:
  - `aws_instance.vpc2_instance`: A t2.micro instance launched in the subnet.

### `vpc_peering.tf`
Establishes and configures the VPC peering connection:
- **Peering Connection**:
  - `aws_vpc_peering_connection.vpc1_to_vpc2`: Connects VPC1 and VPC2.
- **Routing**:
  - `aws_route.vpc1_to_vpc2_route`: Adds a route in VPC1 to VPC2.
  - `aws_route.vpc2_to_vpc1_route`: Adds a route in VPC2 to VPC1.

---

## Steps to Verify Connectivity

1. **Access VPC1 Instance**:
   SSH into the VPC1 instance using its public IP:
   ```bash
   ssh -i private_key.pem ec2-user@<VPC1_PUBLIC_IP>
   ```

2. **Test Connectivity to VPC2**:
   Ping the private IP of the VPC2 instance:
   ```bash
   ping <VPC2_PRIVATE_IP>
   ```

3. **Access VPC2 Instance**:
   SSH into the VPC2 instance using its public IP:
   ```bash
   ssh -i private_key.pem ec2-user@<VPC2_PUBLIC_IP>
   ```

4. **Test Connectivity to VPC1**:
   Ping the private IP of the VPC1 instance:
   ```bash
   ping <VPC1_PRIVATE_IP>
   ```

---

## Simplified Workflow
1. Set up both VPCs and their components using `vpc1_main.tf` and `vpc2_main.tf`.
2. Configure the peering connection and routes with `vpc_peering.tf`.
3. Verify private communication between the instances in VPC1 and VPC2.

---

## Notes
- Ensure proper key management for secure SSH access.
- This setup can be extended to deploy idOS nodes in the peered VPCs.

``` 
