 #### terraform-labs:- MicroServcies, Ansible, Terraform on MS Azure

a)Infrastructure Setup on MS Azure: 1 RG, 3 VMs, 3 NICs, 1 NSG, 1 VPC, 1 Subnet, 3 disks, and  1 Storage account
  
  *Navigate to folder terraform then from terminal initialize, view plan and then apply.
  
  Command
   1) terraform init
   2) terraform plan
   3) terraform apply:  Enter yes
   
   ![picture](https://github.com/kshartul/terraform-labs/blob/main/terraform-IAC-inaction.png)
   
   ![picture](https://github.com/kshartul/terraform-labs/blob/main/Azure-Infrastructure-SetUp%20(2).png)
 

b)Push the Docker images to Azure Container Registry
   login to MS Azure portal
   1) az login 
   2) az acr login --name myregistry
   3) docker push myregistry.azurecr.io/currency-conversion:0.0.1-RELEASE
   4) docker push myregistry.azurecr.io/currency-exchange:0.0.1-RELEASE

   ![picture](https://github.com/kshartul/terraform-labs/blob/main/2MS-DockerImages-ACR.png)

c)Application services deployment
   Use  the folllwing command from PowerShell to get the ipaddress of 3 VMs

  - az vm show --resource-group SecondRG  --name myvm-0 -d --query [publicIps] -o tsv
  - az vm show --resource-group SecondRG  --name myvm-1 -d --query [publicIps] -o tsv
  - az vm show --resource-group SecondRG  --name myvm-3 -d --query [publicIps] -o tsv
  
   ![picture](https://github.com/kshartul/terraform-labs/blob/main/AzureVMs-publicIPs-PowerShell.png)
  
    output is  3 ipaddres:  ip1 , ip2, ip3  
   
  - add ip1  to the file ansible/inventories/development/hosts 
  - add ip2  to the file ansible/inventories/production/hosts 
  - add ip3  to the file ansible/inventories/staging/hosts 
 
   Navigate to folder ansible then execute the following command from terminal
   Command

  - ansible-playbook -i inventories/development/hosts  installation.yml
  - ansible-playbook -i inventories/staging/hosts  installation.yml
  - ansible-playbook -i inventories/production/hosts  installation.yml
  
   ![picture](https://github.com/kshartul/terraform-labs/blob/main/ansible_inaction.png)






