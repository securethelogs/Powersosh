<#
.SYNOPSIS
    OSINT Tool
.DESCRIPTION
    Find usernames on the web using PowerShell
.EXAMPLE
    powersosh -UserHandle Username
.EXAMPLE
    powersosh -UserHandle Username -Sites Twitter,'https://some.other.site/user/#u'
.INPUTS
    A userhandle and an optional list of services / URLs
.OUTPUTS
    List of service names / URLs that were validated.
.NOTES
    Aurthor: https://securethelogs.com
		
    Idea: This script can build and build and build.........
.ROLE
    Any role with web access can run this cmdlet
.FUNCTIONALITY
    The function builds a list of URLs (known or custom) and tests
    access to them, The result will be a list of services (for known)
    or URLs (for unkown) where the user has been found.

    Verbose output will include the services that were not found.
#>
function powersosh {
param(
    # The handle/name for the user you are searching for
    [string]$UserHandle =
        $(Throw "Must supply -UserHandle value,`nfor example:`n`t"+
            "powersosh UserName`nor`n`tpowersosh -UserHandle UserName.`n`n"+
            "For more information run Get-Help powersosh`n`n"
        ),
    # List of sites and/or custom URLs to search. URLs must contain
    # the #u placeholder which will be replaced by the userhandle.
    [ValidateScript({Test-PowerSoshSites $_})]
    [string[]]$Sites
)

    Write-Host ""
    Write-Host "__________                                             .__     "
    Write-Host "\______   \______  _  __ ___________  __________  _____|  |__  "
    Write-Host " |     ___/  _ \ \/ \/ // __ \_  __ \/  ___/  _ \/  ___/  |  \ "
    Write-Host " |    |  (  <_> )     /\  ___/|  | \/\___ (  <_> )___ \|   Y  \"
    Write-Host " |____|   \____/ \/\_/  \___  >__|  /____  >____/____  >___|  /"
    Write-Host "                            \/           \/          \/     \/ "
    Write-Host ""
    Write-Host "Creator: https://securethelogs.com / @securethelogs"
    Write-Host ""

    $local:testingSet = $( if( -not $Sites) {
        $KnownSites.Values
    } else {
        $Sites | ForEach-Object { Test-PowerSoshSites $_ -PassThruOnly }
    } ) | ForEach-Object { $_ -replace '#u',[system.uri]::EscapeUriString($UserHandle) }

    Write-Host "`n"
    Write-Host "Running Checks..."
    Write-Host "`n"

    foreach ($testUrl in $testingSet) {
        try {
            $response = Invoke-WebRequest -Uri "$testUrl" -ErrorAction Stop
            $StatusCode = $Response.StatusCode
        } catch {
            $StatusCode = $_.Exception.Response.StatusCode.value__
        }

        if ($StatusCode -eq "200") {
            Write-Output Test-PowerSoshSites $testUrl -Reverse $UserHandle -PassThruOnly
        }

        if ($StatusCode -eq "404") {
            #Site Does Not Exist - Do Nothing
        } else {
            Write-Warning -Message "Error ($StatusCode) occured when querying $testUrl"
        }
    }

    Write-Output "`n"
}

$script:KnownSites = [ordered]@{}
# #u in a string indicates the user handle.
$KnownSites['twitter'    ] = 'https://twitter.com/#u/'
$KnownSites["instagram"  ] = "https://www.instagram.com/#u/"
$KnownSites["kik"        ] = "https://ws2.kik.com/user/#u/"
$KnownSites["medium"     ] = "https://medium.com/@#u"
$KnownSites["pastebin"   ] = "https://pastebin.com/u/#u/"
$KnownSites["patreon"    ] = "https://www.patreon.com/#u/"
$KnownSites["photobucket"] = "https://photobucket.com/user/#u/library"
$KnownSites["pinterest"  ] = "https://www.pinterest.com/#u/"
$KnownSites["myspace"    ] = "https://myspace.com/#u/"
$KnownSites["reddit"     ] = "https://www.reddit.com/user/#u/"

function Test-PowerSoshSites{
param([string[]]$arg,[string]$Reverse,[switch]$PassThruOnly)
    if( $reverse ) {
        foreach( $site in $KnownSites.Keys ) {
            $siteUri = $KnownSites[$site] -replace '#u',$Reverse
            if( $siteUri -ieq $arg ) { if( $PassThruOnly ) { return $site } else { return $true } }
        }
        if( $PassThruOnly ) { return $arg } else { return $false }
    }
    if( $arg -in $KnownSites.Keys ) {
        if( $PassThruOnly ) { return $KnownSites[$arg] } else { return $true }
    }
    Write-Verbose "($arg) is not predefined"

    if( [system.uri]::IsWellFormedUriString($arg,[System.UriKind]::Absolute) ) {
        if( $arg -match '#u' ) { if( $PassThruOnly ) { return $arg } else { return $true } }
    }

    return $false
}
