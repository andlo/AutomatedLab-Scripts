New-LabDefinition -Name 'Lab' -DefaultVirtualizationEngine HyperV

$labName = 'LAB'
$labSources = Get-LabSourcesLocation

Add-LabVirtualNetworkDefinition -Name $labName
Add-LabVirtualNetworkDefinition -Name Internet -HyperVProperties @{ SwitchType = 'External'; AdapterName = 'Ethernet 3' }

Add-LabIsoImageDefinition -Name Exchange2016 -Path $labSources\ISOs\ExchangeServer2016-x64-cu3.iso

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

Add-LabMachineDefinition -Name DC1 -Roles RootDC -Processors 2

Add-LabMachineDefinition -Name DC2 -Roles DC  -OperatingSystem 'Windows Server 2016 SERVERSTANDARDCORE'

$netAdapter = @()
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch $labName
$netAdapter += New-LabNetworkAdapterDefinition -VirtualSwitch Internet -UseDhcp
Add-LabMachineDefinition -Name GW -Roles Routing -NetworkAdapter $netAdapter -OperatingSystem 'Windows Server 2016 SERVERSTANDARDCORE'

$role = Get-LabMachineRoleDefinition -Role Exchange2016 -Properties @{
  OrganizationName       = 'LAB'
  DependencySourceFolder = "$labSources\SoftwarePackages"
}
Add-LabMachineDefinition -Name EXCH1 -Roles @role -MaxMemory 4GB -Processors 2

Add-LabMachineDefinition -Name Client1 -MaxMemory 2GB -OperatingSystem 'Windows 10 Enterprise'

Install-Lab

Show-LabInstallationTime