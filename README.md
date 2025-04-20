# Azure Virtual Machine Deployment using Terraform and Custom Packer Image

This project deploys a scalable and secure virtual machine infrastructure in Azure using Terraform and a custom image created with Packer.

# Project Structure

- **Custom Image**: References a prebuilt Ubuntu image stored in the `packer-image-rg` resource group.
- **Networking**: Creates a virtual network, subnet, network security group (NSG), and assigns security rules.
- **Load Balancer**: Deploys a basic Azure Load Balancer with a static public IP and backend pool.
- **Availability Set**: Ensures high availability for deployed VMs.
- **Virtual Machines**: Deploys multiple Linux VMs using the custom image.

---

##  Resources Created

- Resource Group (data source)
- Azure Virtual Network (`azurerm_virtual_network`)
- Subnet (`azurerm_subnet`)
- Network Security Group with internal access rule (`azurerm_network_security_group`)
- Public IP Address (`azurerm_public_ip`)
- Azure Load Balancer (`azurerm_lb`)
- Availability Set (`azurerm_availability_set`)
- Network Interfaces for each VM (`azurerm_network_interface`)
- Load Balancer Backend Pool (`azurerm_lb_backend_address_pool`)
- Linux Virtual Machines (`azurerm_linux_virtual_machine`)

---

## Requirements

- Terraform CLI
- An existing custom image built with Packer
- Azure Service Principal with proper permissions
- SSH key pair

---

## Variables

- `resource_group` – Name of the existing resource group.
- `location` – Azure region.
- `vm_count` – Number of VMs to deploy.
- `ssh_public_key` – Path to your local SSH public key file.
