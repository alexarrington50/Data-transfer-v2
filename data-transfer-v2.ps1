##########################################
#Alex Arrington's Data Transfer Script V2#
#            GPL V3.0                    #
##########################################

#OG switches: /MIR /XA:SH /XJD /XX /R:5 /W:15 /MT:32 /V /NP /DCOPY:T

function transfer-folder {	#file transfer function via Robocopy
	robocopy \\$OldPCserial\C$\Users\$sourceUsersFolder\$txfolder \\$NewPCserial\C$\Users\$destUsersFolder\$txfolder /mt:128 /xa:SH /R:5 /W:15 /mir /compress /xx /xjd /dcopy:T #/log:\\$NewPCserial\C$\Data\transfer-script-v2-log\$txfolder-log.txt
}

function transfer-chrome {	#file transfer function via Robocopy
	robocopy "\\$OldPCserial\C$\Users\$sourceUsersFolder\AppData\Local\Chrome\Profile\Default\" "\\$NewPCserial\C$\Users\$destUsersFolder\AppData\Local\Chrome\Profile\Default\" Bookmarks* /mt:128 /xa:SH /R:5 /W:15 /compress /xx /xjd /dcopy:T #/log:\\$NewPCserial\C$\Data\transfer-script-v2-log\$txfolder-log.txt
}


function folder-checker ($Foldercheck , $PCserial) {	#checks whether the Users folder exists
	Test-Path -Path "\\$PCserial\C$\Users\$Foldercheck"
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

function Show-FolderSize ($folder , $PCSerial , $UsersFolder)
{
    "{0:N3} GB" -f ((Get-ChildItem \\$PCSerial\C$\Users\$UsersFolder\$folder -Recurse | Measure-Object Length -s).sum / 1Gb)
}
function Show-EasterEgg 
{
Write-Host "`n**Achievement Unlocked: King of Systems Support**`n" -ForegroundColor Green
Write-Host '
                       _____________________________________________________
                      |                                                     |
             _______  |                                                     |
            / _____ | |                   Motion Industries                 |
           / /(__) || |                                                     |
  ________/ / |OO| || |                                                     |
 |         |-------|| |                                                     |
(|         |     -.|| |_______________________                              |
 |  ____   \       ||_________||____________  |             ____      ____  |
/| / __ \   |______||     / __ \   / __ \   | |            / __ \    / __ \ |\
\|| /  \ |_______________| /  \ |_| /  \ |__| |___________| /  \ |__| /  \|_|/
   | () |                 | () |   | () |                  | () |    | () |
    \__/                   \__/     \__/                    \__/      \__/

'    
Write-Host "`nKeep on truckin'`n" -ForegroundColor Red
Read-Host "`nPress enter to continue...`n"
}


Write-Host "#############################"
Write-Host "##Data Transfer Script v2.3##"
Write-Host "#############################"
Write-Host "`nPress CTRL + C to quit at any time.`n"

while ( 1 )
{
    $OldPCserial = Read-Host "`nEnter the serial of the OLD PC:`n"

    $OldPCserial = $OldPCserial.Trim()

    $OldPClen = $OldPCSerial.Length

    if ( $OldPClen -gt 8 ) #If length of old PC > 8 then warn user
    {
	    Write-Warning "`nThe Old PC serial number you entered was too long..."
        press-key
    }
    elseif ( $OldPClen -lt 8 ) #If length of old PC < 8 then warn user
    {
	    Write-Warning "`nThe Old PC serial number you entered was too short..."
        press-key
    }
    else
    {
	    Write-Host "`nContinuing...`n"
        break
    }
}


#reads new PC serial and sanitizes input

while ( 1 )
{

    $NewPCserial = Read-Host "Enter the serial of the NEW PC:`n"

    $NewPCserial = $NewPCserial.Trim()

    $NewPClen = $NewPCserial.Length

    if ( $NewPClen -gt 8 ) #If length of new PC > 8 then warn user 
    {
	    Write-Warning "`nThe NEW PC serial number you entered was too long..."
        press-key
    }
    elseif ( $NewPClen -lt 8 ) #If length of new PC < 8 then warn user
    {
	    Write-Warning "`nThe NEW PC serial number you entered was too short..."
        press-key
    }
    else
    {
	    Write-Host "`nContinuing...`n"
        break
    }
}


#Pings both computers and determines their status

Write-Host "`nStarting network check`n"

While (1)
{
    if ( Connection-Checker $OldPCserial )
    {
        Write-Host "`n$OldPCserial is online... Continuing...`n"
        Start-Sleep -Seconds 1
        break
    }
    else
    {
        Write-Warning "$OldPCserial is offline... Check network connection."
        press-key
    }
}
While (1)
{
    if ( Connection-Checker $NewPCserial )
    {
        Write-Host "`n$NewPCserial is online... Continuing...`n"
        Start-Sleep -Seconds 1
        break
    }
    else
    {
        Write-Warning "$NewPCserial is offline... Check network connection."
        press-key
    }
}



#Read source Users folder and determine whether folder exists

while ( 1 )
{
    $sourceUsersFolder = Read-Host "`nEnter the C:\Users\ folder to transfer (usually Lan ID):`n"

    $sourceUsersFolder = $sourceUsersFolder.Trim()

    if ( folder-checker $sourceUsersFolder $OldPCserial )
    {
	    Write-Host "`n\\$OldPCserial\C$\Users\$sourceUsersFolder folder on $PCserial exists... Continuing...`n"
        $destUsersFolder = $sourceUsersFolder
        break
    }
    else
    {
	    Write-Warning "`n\\$OldPCserial\C$\Users\$sourceUsersFolder does not exist on $OldPCserial... Check Users folder and try again."
        $sourceUsersFolder = Read-Host "`nEnter the source Users folder to transfer:`n"
    }
}

#Read destination users folder and check if folder exists
while ( 1 )
{

    if ( folder-checker $destUsersFolder $NewPCserial )
    {
	    Write-Host "`n\\$NewPCserial\C$\Users\$destUsersFolder folder on $NewPCserial exists... Continuing...`n"
        break
    }
    else
    {
	    Write-Warning "`n\\$NewPCserial\C$\Users\$destUsersFolder does not exist on $NewPCserial... `nMake sure the user has logged into the new computer and check C:\Users\ folder then try again."
        $destUsersFolder = Read-Host "`nEnter the destination C\:Users\ folder to transfer to:`n"
    }

}

#List of folders to transfer
$txfolderls = @(
	"3D Objects"
	"AppData\Roaming\Microsoft\Excel\XLSTART"
    "AppData\Local\Microsoft\Edge\User Data\Default\"
    #'AppData\Local\Microsoft\Outlook\'
	"Contacts"
	"Desktop"
	"Downloads"
	"Documents"
	"Favorites"
	"Links"
	"Music"
	"Pictures"
	"Searches"
	"Videos"
)

Write-Host "In the final prompt of the script, type Alex Arrington's favorite operating system!"

foreach ( $txfolder in $txfolderls )
{
	transfer-folder
	Write-Host "`n$txfolder done.`n"
}


transfer-chrome
Write-Host "`nChrome bookmarks done.`n"

Write-Host '

    ____        __           ______                      ____             ______                      __     __     
   / __ \____ _/ /_____ _   /_  __/________ _____  _____/ __/__  _____   / ____/___  ____ ___  ____  / /__  / /____ 
  / / / / __ `/ __/ __ `/    / / / ___/ __ `/ __ \/ ___/ /_/ _ \/ ___/  / /   / __ \/ __ `__ \/ __ \/ / _ \/ __/ _ \
 / /_/ / /_/ / /_/ /_/ /    / / / /  / /_/ / / / (__  ) __/  __/ /     / /___/ /_/ / / / / / / /_/ / /  __/ /_/  __/
/_____/\__,_/\__/\__,_/    /_/ /_/   \__,_/_/ /_/____/_/  \___/_/      \____/\____/_/ /_/ /_/ .___/_/\___/\__/\___/ 
                                                                                           /_/ 

'                     

$doicheck = Read-Host "`nDo you want to compare the sizes of the profile on both computers? *This could take a while* (y/n)`n"

if ($doicheck -eq "n" -or $doicheck -eq "N") {
    Write-Host "`nFolder sizes will not be compared...`n"
    break
}
else {
    Write-Host "Checking profile size. This might take a moment..."

    $folder='Documents'
    $oldDocSize=Show-Foldersize $folder $OldPCSerial $sourceUsersFolder
    $newDocSize=Show-Foldersize $folder $NewPCSerial $destUsersFolder
    Write-Host "Documents done..."

    $folder='Downloads'
    $oldDlSize=Show-Foldersize $folder $OldPCSerial $sourceUsersFolder
    $newDlSize=Show-Foldersize $folder $NewPCSerial $destUsersFolder
    Write-Host "Downloads done..."

    $folder='Desktop'
    $oldDtSize=Show-Foldersize $folder $OldPCSerial $sourceUsersFolder
    $newDtSize=Show-Foldersize $folder $NewPCSerial $destUsersFolder
    Write-Host "Desktop done..."

    $folder='Pictures'
    $oldPicSize=Show-Foldersize $folder $OldPCSerial $sourceUsersFolder
    $newPicSize=Show-Foldersize $folder $NewPCSerial $destUsersFolder
    Write-Host "Pictures done..."

    Write-Host 
    "    Folder  |  $OldPCSerial  |  $NewPCSerial
    ______________________________________________________________
    Documents  |  $oldDocSize  |  $newDocSize
    Downloads  |  $oldDlSize  |  $newDlSize
    Desktop    |  $oldDtSize  |  $newDtSize
    Pictures   |  $oldPicSize  |  $newPicSize"
}

$Money = Read-Host "`nPress enter to continue...`n"

if ($Money -eq 'Red Hat Enterprise Linux')
{
    Show-EasterEgg
}

Exit 1;

