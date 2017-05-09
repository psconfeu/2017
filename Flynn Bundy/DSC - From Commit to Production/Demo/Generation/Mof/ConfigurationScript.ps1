configuration Main
{

Param (
    $BeertimeAPIKey
)

Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
Import-DscResource -ModuleName cChoco
Import-DscResource -Name MSFT_xRemoteFile, xEnvironment -ModuleName xPSDesiredStateConfiguration

node $AllNodes.NodeName
    {
        switch ($Node.Role)
        {
            'beertime'
            {
                File AppDir
                {
                  Type = 'Directory'
                  Ensure = 'Present'
                  DestinationPath = 'C:\App'
                }
                cChocoInstaller InstallChoco
                {
                    InstallDir = "c:\choco"
                }
                Foreach ($Package in $node.Packages)
                {
                    cChocoPackageInstaller "$Package"
                    {
                      Name      = $Package
                      Ensure    = 'Present'
                      DependsOn = '[cChocoInstaller]InstallChoco'
                    }
                }
                xEnvironment brewAPIkey
                {
                    Ensure = "Present"
                    Name = "apikey"
                    Value = $BeertimeAPIKey
                }
            }
        }
    }
}
