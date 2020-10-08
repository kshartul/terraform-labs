output "ip-address-hostname" {
  value = "${
      formatlist(
        "%s:%s",
        azurerm_linux_virtual_machine.myterraformvm.*.name, azurerm_public_ip.myterraformpublicip.*.ip_address
      )
    }"
}

#  alternatively, Use  thefolllwing command from PowerShell to get the ipaddress 
# az vm show --resource-group SecondRG  --name myvm-0 -d --query [publicIps] -o tsv
# az vm show --resource-group SecondRG  --name myvm-1 -d --query [publicIps] -o tsv
# az vm show --resource-group SecondRG  --name myvm-3 -d --query [publicIps] -o tsv
# output is ipaddres:  

