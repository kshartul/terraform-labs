terraform-labs:- MicroServcies, Ansible, Terraform on MS Azure

a)Infrastructure Setup on MS Azure: 1 RG, 3 VMs, 3 NICs, 1 NSG, 1 VPC, 1 Subnet, 3 disks, and  1 Storage account
   Navigate to folder terraform then from terminal initialize, view plan and then apply.
   Command
   1) terraform init
   2) terraform plan
   3) terraform apply:  Enter yes

b)Push the Docker images to Azure Container Registry
   login to MS Azure portal
   1) az login 
   2) az acr login --name myregistry
   3) docker push myregistry.azurecr.io/currency-conversion:0.0.1-RELEASE
   4) docker push myregistry.azurecr.io/currency-exchange:0.0.1-RELEASE

c)Application services deployment
   Use  the folllwing command from PowerShell to get the ipaddress of 3 VMs

   az vm show --resource-group SecondRG  --name myvm-0 -d --query [publicIps] -o tsv
   az vm show --resource-group SecondRG  --name myvm-1 -d --query [publicIps] -o tsv
   az vm show --resource-group SecondRG  --name myvm-3 -d --query [publicIps] -o tsv
   output is  3 ipaddres:  ip1 , ip2, ip3  
   
   add ip1  to the file ansible/development/inventory
   add ip2  to the file ansible/production/inventory
   add ip3  to the file ansible/staging/inventory
 
   Navigate to folder ansible then execute the following command from terminal
   Command

   ansible-playbook -i development  installation.yml
   ansible-playbook -i staging  installation.yml
   ansible-playbook -i production installation.yml







