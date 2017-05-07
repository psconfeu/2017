<#  
        .NOTES 
        ============================================================================
        Date:       20.04.2016
        Presenter:  David das Neves 
        Version:    1.0
        Project:    PSConfEU - PSRepoServer 
        Ref:        

        ============================================================================ 
        .DESCRIPTION 
        Presentation data        
#> 


Set-Location $PSScriptRoot

$certpath = 'C:\OneDrive\Weiteres\PSConfEU - 2017\__PreConf\Powershell Security Einführung\Signing\PSConfEU.pfx'
$c = Get-PfxCertificate -FilePath $certpath 

Get-Item -Path '.\5SigningDemo.ps1' | Set-AuthenticodeSignature -Certificate $c