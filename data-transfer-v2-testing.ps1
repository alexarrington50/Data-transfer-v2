##########################################
#Alex Arrington's Data Transfer Script V2#
#   License: GPL V3.0                    #
##########################################

#OG switches: /MIR /XA:SH /XJD /XX /R:5 /W:15 /MT:32 /V /NP /DCOPY:T

function transfer-folder {	#file transfer function via Robocopy
	robocopy \\$OldPCserial\C$\Users\$sourceUsersFolder\$txfolder \\$NewPCserial\C$\Users\$destUsersFolder\$txfolder /mt:128 /xa:SH /mir /compress /xx /xjd /dcopy:T #/log:\\$NewPCserial\C$\Data\transfer-script-v2-log\$txfolder-log.txt
}

function folder-checker {	#checks whether the Users folder exists
	Test-Path -Path "\\$PCserial\C$\Users\$UsersFolder"
}

function press-key {	#press any key to contine function
	Read-Host "`nPress enter to continue...`n"	
}

function printer-mius ( $printerqueue )##adds printer to local computer
{
    Add-Printer -ConnectionName \\miusprint\$printerqueue
}

function Connection-Checker ( $PCserial )#Checks if a PC is online via ping
{
Test-Connection -ComputerName $PCserial -Count 3 -Delay 2 -Quiet
}

$user = $env:username
$OldPCconnection = $false
$NewPCconnection = $false

#Privledge escalation 

#https://stackoverflow.com/questions/7690994/running-a-command-as-administrator-using-powershell

#https://stackoverflow.com/questions/60209449/how-to-elevate-a-powershell-script-from-within-a-script

#https://ss64.com/ps/syntax-elevate.html

#if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -File `"$PSCommandPath`"" -Verb RunAs; exit }
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Unrestricted -File `"$PSCommandPath`"" -Verb RunAs; exit }


Write-Host "#############################"
Write-Host "###Data Transfer Script v2###"
Write-Host "#############################"
Write-Host "`nPress CTRL + C to quit at any time.`n"

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



#Pings both computers and determines their status

$connectionstatus = "offline"

Write-Host "`nStarting network check`n"

While (1)
{
        if ( Connection-Checker $OldPCserial )
        {
            Write-Host "`n$OldPCserial is online... Continuing...`n"
            Start-Sleep -Seconds 1
            $OldPCconnection = $true
        }
        else
        {
            Write-Warning "$OldPCserial is offline... Check network."
            press-key
        }
        if ( Connection-Checker $NewPCserial )
        {
            Write-Host "`n$NewPCserial is online... Continuing...`n"
            Start-Sleep -Seconds 1
            $NewPCconnection = $true
        }
        else
        {
            Write-Warning "$NewPCserial is offline... Check network."
            press-key
        }
        if ( $OldPCconnection -eq $true -And $NewPCconnection -eq $true )
        {
            break
        }
        else
        {
            Write-Host "Checking network again...`n"
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
    'AppData\Local\Chrome\Profile\Default Bookmarks'
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

Write-Host "Data transfer has finished successfully."
press-key

#add printers
#currently adds printer to the host computer. Need to figure out how to add to $NewPCserial

Write-Host "Preparing to add printers..."

Write-Host "Running Mi Login Script..."

\\corp.motion-ind.com\netlogon\milogon.cmd

Write-Host "`nBuilding printer DB...`n"

$printerls = Get-Printer -ComputerName miusprint 

Write-Host "DB done...`n"

$printnamels = $printerls.Name

#$printnames

$branch = Read-Host '`nWhat branch would you like to print from? (EX: AL06)`n'

$printaddls = @()


if ( $NewPCserial -eq $env:computername )
{
    foreach ($printer in $printnamels )
    {
        if ($printer.StartsWith($branch))
        {
            $printaddls += $printer
        }
        else{}
        foreach ( $printeradd in $printeraddls )
        {
            printer-mius $printeradd
            Write-Host "$printeradd connected to $NewPCserial..."
        }
    }
}
elseif ( $OldPCserial -eq $env:computername -And $numPrinters -gt 0 )
{
    Write-Warning "You are trying to add printers to the old PC $env:computername...`nTo add printers, please run this script on the New PC next time..."
    press-key
}
else
{
    Write-Host "No printers will be added..."
    Start-Sleep -Seconds 1
}



Exit 1;