##########################################
#Alex Arrington's Data Transfer Script V2#
#   License: GPL V3.0                    #
##########################################

#OG switches: /MIR /XA:SH /XJD /XX /R:5 /W:15 /MT:32 /V /NP /DCOPY:T

function transfer-folder {	#file transfer function via Robocopy
	robocopy \\$OldPCserial\C$\Users\$sourceUsersFolder\$txfolder \\$NewPCserial\C$\Users\$destUsersFolder\$txfolder /mt:128 /xa:SH /mir /compress /xx /xjd /dcopy:T #/log:\\$NewPCserial\C$\Data\transfer-script\$NewPCserial\log.txt /z
}

function folder-checker {	#checks whether the Users folder exists
	Test-Path -Path "\\$PCserial\C$\Users\$UsersFolder"
}

function press-key {	#press any key to contine function
	Read-Host "`nPress enter to continue...`n"	
}


function printer-mius
{
    Add-Printer -ConnectionName \\miusprint\$printername
}

$user = $env:username


#Privledge escalation https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }


while ( 1 )
{
    $OldPCserial = Read-Host "`nEnter the serial of the OLD PC:`n"

    $OldPCserial = $OldPCserial.Trim()

    $OldPClen = $OldPCSerial.Length

    if ( $OldPClen -gt 8 ) #If length of old PC > 8 then warn user
    {
	    Write-Warning "`nCheck Old PC serial, input was too long..."
        press-key
    }
    elseif ( $OldPClen -lt 8 ) #If length of old PC < 8 then warn user
    {
	    Write-Warning "`nCheck Old PC serial, input was too short..."
        press-key
    }
    else
    {
	    Write-Host "`nContinuing...`n"
        break
    }
}


#reads new PC serial and sanitizes input
$validSerial = 0

while ( 1 )
{

    $NewPCserial = Read-Host "Enter the serial of the NEW PC:`n"

    $NewPCserial = $NewPCserial.Trim()

    $NewPClen = $NewPCserial.Length

    $validSerial = 0

    if ( $NewPClen -gt 8 ) #If length of new PC > 8 then warn user 
    {
	    Write-Warning "`nCheck NEW PC serial, input was too long..."
        press-key
    }
    elseif ( $NewPClen -lt 8 ) #If length of new PC < 8 then warn user
    {
	    Write-Warning "`nCheck NEW PC serial, input was too short..."
        press-key
    }
    else
    {
	    Write-Host "`nContinuing...`n"
        break
    }
}



#Ping computer that is not running the script 
#REWRITE THIS AS FUNCTION
#I want this to ping the remote computer and keep pinging until the computer responds while prompting the user to check the device's connection

$connectionstatus = "offline"

Write-Host "`nStarting network check`n"

While ( $connectionstatus -eq "offline" )
{
	if ( $OldPCserial -eq $env:computername )
	{
		if ( Test-Connection -ComputerName $NewPCserial -Count 3 -Delay 2 -Quiet )
		{
			$connectionstatus = "online"
			Write-Host "`nRemote computer is online... Continuing...`n"
            Start-Sleep -Seconds 1.5
		}
		else
		{
			$connectionstatus = "offline"
			Write-Warning "$NewPCserial is offline... Check network."
            press-key
		}
	}
	elseif ( $NewPCserial -eq $env:computername )
	{
		if (Test-Connection -ComputerName $OldPCserial -Count 3 -Delay 2 -Quiet )
		{
			$connectionstatus = "online"
			Write-Host "`nRemote computer is online... Continuing...`n"
            Start-Sleep -Seconds 1.5
		}
		else
		{
			$connectionstatus = "offline"
			Write-Warning "$OldPCserial is offline... Check network."
            press-key
		}
	}
	else #check if both PCs are online
	{
		if ( Test-Connection -ComputerName $OldPCserial -Count 3 -Delay 2 -Quiet ) #check if OLD PC is online
        {
		    Write-Host "$OldPCserial is online..."
            $connectionstatus = "online"
        }
        else
        {
            Write-Warning "Check if $OldPCserial is offline... Check network"
            press-key
        }
        #check if NEW PC is online
        if ( Test-Connection -ComputerName $NewPCserial -Count 3 -Delay 2 -Quiet )
        {
		    Write-Host "$NewPCserial is online..."
            $connectionstatus = "online"
        }
        else
        {
            Write-Warning "Check if $NewPCserial is offline... Check network..."
            press-key
        }
	}
}


#Read source Users folder and determine whether folder exists

while ( 1 )
{
    $sourceUsersFolder = Read-Host "`nEnter the source Users folder to transfer (usually Lan ID):`n"
    $foldercheck = ""
    $PCserial = $OldPCserial
    $UsersFolder = $sourceUsersFolder

    if ( folder-checker )
    {
	    Write-Host "`n\\$PCserial\C$\Users\$UsersFolder folder on $PCserial exists... Continuing...`n"
        break
    }
    else
    {
	    Write-Warning "`n\\$PCserial\C$\Users\$UsersFolder does not exist on $PCserial... Check Users folder and run try again."
        press-key
    }
}


#Read destination users folder and check if folder exists
while ( 1 )
{
    $destUsersFolder = Read-Host "`nEnter the destination Users folder to transfer:`n"
    $foldercheck = ""
    $PCserial = $NewPCserial
    $UsersFolder = $destUsersFolder
    $folderPresent = 0


    if ( folder-checker )
    {
	    Write-Host "`n\\$PCserial\C$\Users\$UsersFolder folder on $PCserial exists... Continuing...`n"
        break
    }
    else
    {
	    Write-Warning "`n\\$PCserial\C$\Users\$UsersFolder does not exist on $PCserial... Check Users folder and try again."
        press-key
    }
}

#List of folders to transfer
$txfolderls = @(
	'3D Objects'
	'AppData\Roaming\Microsoft\Excel\XLSTART'
    'AppData\Local\Chrome\Profile\Default'
    'AppData\Local\Microsoft\Outlook *.pst'
	'Contacts'
	'Desktop'
	'Downloads'
	'Documents'
	'Favorites'
	'Links'
	'Music'
	'Pictures'
	'Searches'
	'Vidoes'
)

foreach ( $txfolder in $txfolderls )
{
	transfer-folder
	Write-Host "`n$txfolder done.`n"
}

Write-Host "Data transfer has finsihed successfully."
press-key

#add printers
#currently adds printer to the host computer. Need to figure out how to add to $NewPCserial


$numPrinters = Read-Host "`nHow many printers do you was to add from \\miusprint?`n"
$printerls = @() #create printer list



if ( $numPrinters -gt 0 )
{
    foreach ( $i in 1..$numPrinters )
    {
        $printeradd = Read-Host "`nEnter the name of the printer you would like to add from \\miusprint (ex:DP04PRT01):`n"
        $printeradd = $printeradd.Trim()
        $printerls.Add($printeradd)
    }
    foreach ( $printername in $printerls)
    {
        printer-mius
    }
}
else
{
    Write-Host "No printers will be added..."
    press-key
}


#add function to set default apps
#call function to set defaults

Exit 1;