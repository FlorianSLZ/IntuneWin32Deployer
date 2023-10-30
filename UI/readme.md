|Florian Salzmann|[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)|
|----------------|-------------------------------|
|**Jannik Reinhard**|[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/jannik_reinhard)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/jannik-r/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://jannikreinhard.com/)|

# IntuneDeviceInventory UI (IDIUI)

You can find the UI for the Device Inventory Module here. This UI supports you to change/set the custom inventory for single devices but also for multiple devices at the same time but also to trigger device actions.

![Tool View](https://github.com/FlorianSLZ/IntuneDeviceInventory/blob/main/UI/.images/toolView.png)

## Installing the UI
In the repo there is an installation wrapper that creates a start menu entry and unblocks the dlls.
To install the UI for the following steps out:
- Download the repository
- Execute the setup script

```PowerShell
Install-IntuneDeviceInventoryUI.ps1
```

## Start the UI
- If you have installed the IDIUI then search in the start menue "IntuneDeviceInventory" 
- if you not installed the IDIUI than make sure that the dlls are unblocked and execute the Start-IntuneDeviceInventoryUi.ps1

## Authentication
You have multiple possibilities for the authentication:
- User auth (Authentication with your current or other user)
- Service Principle (insert manual) (Authentication with an service principle insert the appId, TenantId and secret manual)
- Service Principle (auto creation and sace local) (Automatic creation of a new service principle and store the connection information secure on you device to remember for the next login)

![Tool View](https://github.com/FlorianSLZ/IntuneDeviceInventory/blob/main/UI/.images/auth.png)


## Features
###  Change custom inventory attribute for single device
You can add, change and delete custom attribute to a single device

![Tool View](https://github.com/FlorianSLZ/IntuneDeviceInventory/blob/main/UI/.images/singleDeviceView.png)

###  Change custom inventory attribute for multiple device
You can add, change and delete custom attribute to a multiple devices device

![Tool View](https://github.com/FlorianSLZ/IntuneDeviceInventory/blob/main/UI/.images/multiDeviceView.png)

### Trigger deive action
You can trigger device actions like sync, restart, bitlocker rotation, defender scan and defender signature update

![Tool View](https://github.com/FlorianSLZ/IntuneDeviceInventory/blob/main/UI/.images/actions.png)