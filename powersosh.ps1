<#
	.SYNOPSIS
		OSINT Tool

	.DESCRIPTION
		Find usernames on the web using PowerShell

	.NOTES
		Aurthor: https://securethelogs.com
		
		Idea: This script can build and build and build.........
#>



Write-Output ""
Write-Output "__________                                             .__     "
Write-Output "\______   \______  _  __ ___________  __________  _____|  |__  "
Write-Output " |     ___/  _ \ \/ \/ // __ \_  __ \/  ___/  _ \/  ___/  |  \ "
Write-Output " |    |  (  <_> )     /\  ___/|  | \/\___ (  <_> )___ \|   Y  \"
Write-Output " |____|   \____/ \/\_/  \___  >__|  /____  >____/____  >___|  /"
Write-Output "                            \/           \/          \/     \/ "
Write-Output ""
Write-Output "Creator: https://securethelogs.com / @securethelogs"
Write-Output ""



#Get the username

$userhandle = Read-Host -Prompt "Enter A Username: "

$myArray = @(
"https://twitter.com/$userhandle",
"https://www.instagram.com/$userhandle/",
"https://ws2.kik.com/user/$userhandle/",
"https://medium.com/@$userhandle",
"https://pastebin.com/u/$userhandle/",
"https://www.patreon.com/$userhandle/",
"https://photobucket.com/user/$userhandle/library",
"https://www.pinterest.com/$userhandle/",
"https://myspace.com/$userhandle/",
"https://www.reddit.com/user/$userhandle/"

)


Write-Output "`n"
Write-Output "Running Checks.............."
Write-Output "`n"

foreach ($i in $myArray) {

try

{

    $response = Invoke-WebRequest -Uri "$i" -ErrorAction Stop
    $StatusCode = $Response.StatusCode
}
catch
{
    $StatusCode = $_.Exception.Response.StatusCode.value__
}


if ($StatusCode -eq "200"){

Write-Output "Found one: $i"

}

if ($StatusCode -eq "404"){

#Site Does Not Exist - Do Nothing

}

else {

#Do Nothing

}

}

Write-Output "`n"
