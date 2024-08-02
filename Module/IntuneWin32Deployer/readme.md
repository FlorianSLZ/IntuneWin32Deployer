<p align="center">
    <a href="https://scloud.work" alt="Florian Salzmann | scloud"></a>
            <img src="https://scloud.work/wp-content/uploads/IntuneWin32Deployer-Icon.png" width="75" height="75" /></a>
</p>
<p align="center">
    <a href="https://www.linkedin.com/in/fsalzmann/">
        <img alt="Made by" src="https://img.shields.io/static/v1?label=made%20by&message=Florian%20Salzmann&color=04D361">
    </a>
    <a href="https://x.com/FlorianSLZ" alt="X / Twitter">
    	<img src="https://img.shields.io/twitter/follow/FlorianSLZ.svg?style=social"/>
    </a>
</p>
<p align="center">
    <a href="https://www.powershellgallery.com/packages/IntuneWin32Deployer/" alt="PowerShell Gallery Version">
        <img src="https://img.shields.io/powershellgallery/v/IntuneWin32Deployer.svg" />
    </a>
    <a href="https://www.powershellgallery.com/packages/IntuneWin32Deployer/" alt="PS Gallery Downloads">
        <img src="https://img.shields.io/powershellgallery/dt/IntuneWin32Deployer.svg" />
    </a>
</p>
<p align="center">
    <a href="https://raw.githubusercontent.com/FlorianSLZ/IntuneWin32Deployer/master/LICENSE" alt="GitHub License">
        <img src="https://img.shields.io/github/license/FlorianSLZ/IntuneWin32Deployer.svg" />
    </a>
    <a href="https://github.com/FlorianSLZ/IntuneWin32Deployer/graphs/contributors" alt="GitHub Contributors">
        <img src="https://img.shields.io/github/contributors/FlorianSLZ/IntuneWin32Deployer.svg"/>
    </a>
</p>

<p align="center">
    <a href='https://buymeacoffee.com/scloud' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3' border='0' alt='Buy Me a Glass of wine' /></a>
</p>

# IntuneWin32Deployer (IWD)
![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/IntuneWin32Deployer)

The "Intune Win32 Deployer" allows you to transform Windows Package Manager (winget) and Chocolatey installations for Intune into a Win32 application (intunewin) and upload it straight away to your MEM environment. If you want to do without the automatic upload, you can also just generate the intunewin files.

## Installing the module from PSGallery

The IntuneWin32App module is published to the [PowerShell Gallery](https://www.powershellgallery.com/packages/IntuneWin32Deployer). 
Install it on your system by running the following in an elevated PowerShell console:
```PowerShell
Install-Module -Name IntuneWin32Deployer
```

## Import the module for testing

As an alternative to installing, you chan download this Repository and import it in a PowerShell Session. 
*The path may be different in your case*
```PowerShell
Import-Module -Name "C:\GitHub\IntuneWin32Deployer\Module\IntuneWin32Deployer" -Verbose -Force
```

## Module dependencies

IntuneWin32Deployer module requires the following modules, which will be automatically installed as dependencies:
- Microsoft.Graph.Authentication
- Microsoft.Graph.Groups

# Functions / Examples

Here are all functions and some examples to start with:

- Connect-IWD
- Add-IWDApp2Repo
- Add-IWDApp
- Create-IWDWin32App
- Create-IWDChocolatey4Dependency
- Create-IWDWinGet4Dependency
- Check-IWDLocalChocolatey
- Out-IWDIntunewin
- Upload-IWDWin32App
- Create-IWDAppGroup


## Authentication
Before using any of the functions within this module that interacts with Graph API, ensure you are authenticated. 

### User Authentication
With this command, you'll be connected to the Graph API and be able to use all commands
```PowerShell
# Authentication as User
Connect-IWD

```


## Permissions

- DeviceManagementManagedDevices.ReadWrite.All
- Group.ReadWrite.All
- GroupMember.Read.All
- Organization.Read.All
