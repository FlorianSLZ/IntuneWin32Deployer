> Version 2022.22.0

[![Twitter Follow](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=twitter&logoColor=white)](https://twitter.com/FlorianSLZ/)  [![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/fsalzmann/)  [![Website](https://img.shields.io/badge/website-000000?style=for-the-badge&logo=About.me&logoColor=white)](https://scloud.work/en/about)


# Intune Win32 Deployer


Create and deploy winget and chocolatey (win32) apps to Intune with one click!

## Installation
To install just download the whole repository and execute the "INSTALL_Intune-Win32-Deployer.ps1" in the root folder. 
This will copy the program files to your local Appdata and creates a shortcut in the start menu. (no Desktop icon, cause I don't like those). 

In addition the installer asks you if you want to install winget and chocolatey (as an admin). 


## Blogpost / Wiki
An overview and some how-to's I put together on my blog: [The "Intune Win32 Deployer"](https://scloud.work/en/intune-win32-deployer/)

## Functions
- Create Intunewin for winget applications
- Create Intunewin for Chocolatey applications
- Deploy winget via Intune (as system)
- Deploy Chocolatey via Intune
- Transform programs from the Windows Package Manager into an intunewin
- Transform programs from Chocolatey into an intunewin
- Create Win32 applications upload to Intune
- Maintaining an inventory list within the application
- Install winget (optional)
- Install Chocolatey (optional)
- Current Microsoft Win32 Content Prep Tool download

added in 2022.38.0
- Create AAD group per win32 app
- Define AAD group prefix
- Create Proactive Remediation package per app to update [how it works](https://scloud.work/winget-updates-proactive-remediations/)

## Demo 
[![DEMO](https://img.youtube.com/vi/f77XANBj95c/0.jpg)](https://youtu.be/f77XANBj95c "DEMO")

## Change log
### Version 2022.38.0
- compatible/requires newest IntuneWin32App version (1.3.5)
- can create/assign AAD group per app
- can create PR to update each app
- log improvements
- function consilidation
- small UI tweaks

### Version 2022.22.1
- adde winget install parameter in machine context (--scope Machine)

### Version 2022.22.0
- initial version