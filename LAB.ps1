
$labName = 'LAB'
$labSources = Get-LabSourcesLocation

New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV

#Setup Network
Add-LabVirtualNetworkDefinition -Name $labName
#Add-LabVirtualNetworkDefinition -Name Internet -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet 3' }

#Add needed ISO's
#Add-LabIsoImageDefinition -Name Exchange2016 -Path $labSources\ISOs\ExchangeServer2016-x64-cu3.iso

#defining default parameter values, as these ones are the same for all the machines
$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:DomainName' = 'lab.local'
    'Add-LabMachineDefinition:Memory' = 512Mb
    'Add-LabMachineDefinition:MaxMemory' = 1024Mb
    'Add-LabMachineDefinition:MinMemory' = 512Mb
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2016 SERVERSTANDARD'
    'Add-LabMachineDefinition:Network' = $labName
    'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
}


# DC1
#The PostInstallationActivity is just creating some users
$postInstallActivity = Get-LabPostInstallationActivity -ScriptFileName PrepareRootDomain.ps1 -DependencyFolder "$labSources\PostInstallationActivities\PrepareRootDomain"
Add-LabMachineDefinition -Name DC1 -Roles RootDC -Processors 2 -PostInstallationActivity $postInstallActivity

# DC2
#Add-LabMachineDefinition -Name DC2 -Roles DC 
#-OperatingSystem 'Windows Server 2016 SERVERSTANDARDCORE'

# GW
# The GW is just a WindowsServer whith to Networkinterfaces and the Routing role
#$netAdapter = @()
#$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $labName
#$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch Internet -UseDhcp
#Add-LabMachineDefinition -Name GW -Roles Routing -NetworkAdapter $netAdapter 
#-OperatingSystem 'Windows Server 2016 SERVERSTANDARDCORE'

# EXCH1
# First Exchangeserver
$role = Get-LabMachineRoleDefinition -Role Exchange2016 -Properties @{
  OrganizationName       = 'LAB'
  DependencySourceFolder = "$labSources\SoftwarePackages"
}
Add-LabMachineDefinition -Name EXCH1 -Roles $role -MaxMemory 4GB -Processors 2 

# NAV2016
# A windowsserver whith NAVDEMO setup
$postInstallActivity = Get-LabPostInstallationActivity -ScriptFileName navdemo.ps1 -DependencyFolder "$labSources\SoftwarePackages\Dynamics.90.NA.1769452.DVD" -KeepFolder
Add-LabMachineDefinition -Name NAV2016 -MaxMemory 2GB -Processors 1 -PostInstallationActivity $postInstallActivity

# Client1
# W Windows10 based Client
#Add-LabMachineDefinition -Name Client1 -MaxMemory 2GB -OperatingSystem 'Windows 10 Enterprise'

Install-Lab 

Show-LabInstallationTime