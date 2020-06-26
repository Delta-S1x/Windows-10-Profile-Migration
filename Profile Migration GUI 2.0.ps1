#############################################################################################################
# To run: Right click "Run with powershell"
# Note: You may have to do "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned" or "Set-ExecutionPolicy -ExecutionPolicy Unrestricted"
# to get this to run.
#
# This tool will run itself as Administrator and give options to Move user folders from one profile to another
# Included folders: Desktop
#                   Documents
#                   Start Menu
#                   Downloads
#                   Pictures
#                   Music
#                   Temp Folder
#                   Signatures
#                   Favorites
#       
#    NOTE: This will not account for browser bookmarks. Please ensure the end user has them backed up
#
# Author: [REDACTED]
#
############################################################################################################


Function Run-AsAdmin
{

    [CmdletBinding(DefaultParameterSetName='CheckOnly')]

    Param
	(
        [Parameter(Mandatory=$true, ParameterSetName='CheckOnly')]
		[switch]$CheckOnly = $false,
        [Parameter(Mandatory=$true, ParameterSetName='SkipCheck')]
        [switch]$SkipCheck = $false,
        [switch]$DefaultPSRunPath = $false
	)
    

    if ($CheckOnly) 
    {
        $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
        if ($IsAdmin) 
        {
			$Host.UI.RawUI.WindowTitle = $myInvocation.ScriptName.ToString() + "(Elevated)"
			$Host.UI.RawUI.BackgroundColor = "DarkBlue"
			clear-host
            return $true
	    } 
        else 
        {
            return $false
        }

    }

    if ($SkipCheck) 
    {
        $Invocation = $script:MyInvocation.MyCommand.Path
        $Invocation = Get-Item ($Invocation)

        if ($Invocation.PSDrive.DisplayRoot) 
        {
            $Invocation = ($Invocation.PSDrive.DisplayRoot) + $(Split-Path -Path $Invocation -NoQualifier)
        } 
        else 
        {
            $Invocation = $Invocation.FullName
        }

        $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell"
		
        if ($DefaultPSRunPath)
        {
            $ArgBase = "-ExecutionPolicy Bypass -File `"$Invocation`""
        }
        else
        {
            $InvocDir = Split-Path -Path $Invocation
            $ArgBase = "-ExecutionPolicy Bypass -Command Set-Location \""$InvocDir\""; & \""$Invocation\"""
        }
        

        $newProcess.Arguments = $ArgBase
        $newProcess.Verb = 'runas'
		[System.Diagnostics.Process]::Start($newProcess)
        exit

    }
	
} ###End Run-AsAdmin###

if (!(Run-AsAdmin -CheckOnly)) 
{
    Run-AsAdmin -SkipCheck
}


#Continue script as admin below here.



###################################################################### 
 #.Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'  

  $consolePtr = [Console.Window]::GetConsoleWindow()
    
   # [Console.Window]::ShowWindow($consolePtr, 0)
######################################################################    
# Loading external assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$Form1 = New-Object System.Windows.Forms.Form

$label1 = New-Object System.Windows.Forms.Label
$label2 = New-Object System.Windows.Forms.Label
$ListBox2 = New-Object System.Windows.Forms.ComboBox
$ListBox1 = New-Object System.Windows.Forms.ComboBox
$button1 = New-Object System.Windows.Forms.Button
$Desktopbox = New-Object System.Windows.Forms.CheckBox
$DownloadsBox = New-Object System.Windows.Forms.CheckBox
$StartMenuBox = New-Object System.Windows.Forms.CheckBox
$DocumentsBox = New-Object System.Windows.Forms.CheckBox
$picturesbox = New-Object System.Windows.Forms.CheckBox
$Tempfolderbox = New-Object System.Windows.Forms.CheckBox
$favoritesbox = New-Object System.Windows.Forms.CheckBox
$Signaturesbox = New-Object System.Windows.Forms.CheckBox
$musicbox = New-Object System.Windows.Forms.CheckBox
$Checkallbox = New-Object System.Windows.Forms.CheckBox


#
# label1
#
$label1.AutoSize = $true
$label1.Location = New-Object System.Drawing.Point(23, 9)
$label1.Name = "label1"
$label1.Size = New-Object System.Drawing.Size(55, 13)
$label1.TabIndex = 0
$label1.Text = "Old Profile"




#
# label2
#
$label2.AutoSize = $true
$label2.Location = New-Object System.Drawing.Point(23, 72)
$label2.Name = "label2"
$label2.Size = New-Object System.Drawing.Size(61, 13)
$label2.TabIndex = 1
$label2.Text = "New Profile"
#


####Profile Lookup
$Profiles = Get-ChildItem -LiteralPath C:\Users -Directory 
$Profiles = $Profiles.Name


# ListBox2
#
$ListBox2.FormattingEnabled = $true
$ListBox2.Location = New-Object System.Drawing.Point(23, 88)
$ListBox2.Name = "ListBox2"
$ListBox2.Size = New-Object System.Drawing.Size(199, 21)
$ListBox2.TabIndex = 3
$ListBox2.Items.AddRange($Profiles)
#
# ListBox1
#
$ListBox1.FormattingEnabled = $true
$ListBox1.Location = New-Object System.Drawing.Point(23, 25)
$ListBox1.Name = "ListBox1"
$ListBox1.Size = New-Object System.Drawing.Size(199, 21)
$ListBox1.TabIndex = 4
$ListBox1.Items.AddRange($Profiles)
#
# button1
#
$button1.Location = New-Object System.Drawing.Point(80, 295)
$button1.Name = "button1"
$button1.Size = New-Object System.Drawing.Size(83, 35)
$button1.TabIndex = 5
$button1.Text = "Start Migration"
$button1.UseVisualStyleBackColor = $true

function OnClickbutton1 {
#creating object os WScript
$wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
#invoking the POP method using object
$answer = $wshell.Popup("Are you sure you want to continue Migration?",0,"Profile Migraton",48+4)
$answer
if ($answer -eq 6){
    try{

    $OldProfilePath = $ListBox1.Text
    $NewProfilePath = $ListBox2.Text
     $progressBar1.Value = 5
    if($DownloadsBox.checked){
    #Downloads
    Move-Item ("C:\users\" + $OldProfilePath + '\Downloads\*') -Destination ("C:/users/" + $NewProfilePath + '\Downloads') -Force -Verbose
    $dest = "C:\users\" + $NewProfilePath + "\Downloads"
    Write-Host $dest
    icacls.exe $dest /reset /t
    $progressBar1.Value += 11.11
    }
    
    if($Desktopbox.checked){
    #Desktop
    Move-Item ("C:\users\" + $OldProfilePath + '\Desktop\*') -Destination ("C:/users/" + $NewProfilePath + '\Desktop') -Force -Verbose
    $dest = "C:\users\" + $NewProfilePath + "\Desktop"
    icacls.exe $dest /reset /t
    $progressBar1.Value += 11.11
    }
    if($StartMenuBox.Checked){
    #Start Menu
    move-Item ("C:\users\" + $OldProfilePath + '\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\*') -Destination ($NewProfilePath + '\AppData\Roaming\Microsoft\Windows\Start Menu\Programs') -Force -Verbose
    $dest = "C:\users\" + $NewProfilePath + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs"
    icacls $dest /reset /t
    $progressBar1.Value += 11.11
    }
    if($picturesbox.Checked){
    #Pictures
     Move-Item ("C:\users\" + $OldProfilePath + '\Pictures\*') -Destination ("C:/users/" + $NewProfilePath + '\Pictures') -Force -Verbose
     $dest = "C:\users\" + $NewProfilePath + "\Pictures"
     icacls $dest /reset /t
     $progressBar1.Value += 11.11
     }
     if($DocumentsBox.Checked){
    #Documents
     Move-Item ("C:\users\" + $OldProfilePath + '\Documents\*') -Destination ("C:/users/" + $NewProfilePath + '\Documents') -Force -Verbose
     $dest = "C:\users\" + $NewProfilePath + "\Documents"
     icacls $dest /reset /t
     $progressBar1.Value += 11.11
     }
     if($musicbox.Checked){
    #Music
      Move-Item ("C:\users\" + $OldProfilePath + '\Music\*') -Destination ("C:/users/" + $NewProfilePath + '\Music') -Force -Verbose
      $dest = "C:\users\" + $NewProfilePath + "\Music"
     icacls $dest /reset /t
     $progressBar1.Value += 11.11
      }
    if($Tempfolderbox.Checked){
    #Temp Folder
      Move-Item ("C:\users\" + $OldProfilePath + '\AppData\Local\Temp\*') -Destination ("C:/users/" + $NewProfilePath + '\AppData\Local\Temp') -Force -Verbose
      $dest = "C:\users\" + $NewProfilePath + "\AppData\Local\Temp"
     icacls $dest /reset /t
     $progressBar1.Value += 11.11
    }
    if($favoritesbox.Checked){
    #Favorites
     Move-Item ("C:\users\" + $OldProfilePath + '\Favorites\*') -Destination ("C:/users/" + $NewProfilePath + '\Favorites') -Force -Verbose
     $dest = "C:\users\" + $NewProfilePath + "\Favorites"
     icacls $dest /reset /t
     $progressBar1.Value += 11.11
    }

    if($Signaturesbox.Checked){
    #Signatures
      Move-Item ("C:\users\" + $OldProfilePath + '\AppData\Roaming\Microsoft\Signatures\*') -Destination ("C:/users/" + $NewProfilePath + '\AppData\Roaming\Microsoft\Signatures') -Force -Verbose
      $dest = "C:\users\" + $NewProfilePath + "\AppData\Roaming\Microsoft\Signatures"
     icacls $dest /reset /t
     $progressBar1.Value += 11.11
    }

$progressBar1.Value = 100
#creating object os WScript
$wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
#invoking the POP method using object
$wshell.Popup("Migration Complete!",0,"Profile Migration",0)
}catch{
#creating object os WScript
$wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
#invoking the POP method using object
$wshell.Popup("An Error Occured",0,"Profile Migration",48+0)
Write-Host $_
}

}else{

}
}

$button1.Add_Click( { OnClickbutton1 } )

$Checkallbox.Add_CheckStateChanged({
 If($Checkallbox.Checked){
 $Desktopbox.checked = $true
 $DownloadsBox.checked = $true
 $StartMenuBox.Checked = $true
 $DocumentsBox.checked = $true
 $musicbox.checked = $true
 $picturesbox.checked = $true
 $Tempfolderbox.checked = $true
 $favoritesbox.checked = $true
 $Signaturesbox.checked = $true
 }else{
 $Desktopbox.checked = $false
 $DownloadsBox.checked = $false
 $StartMenuBox.Checked = $false
 $DocumentsBox.checked = $false
 $musicbox.checked = $false
 $picturesbox.checked = $false
 $Tempfolderbox.checked = $false
 $favoritesbox.checked = $false
 $Signaturesbox.checked = $false
}
})


#
# Desktopbox
#
$Desktopbox.AutoSize = $true
$Desktopbox.Checked = $true
$Desktopbox.CheckState = [System.Windows.Forms.CheckState]::Checked
$Desktopbox.Location = New-Object System.Drawing.Point(26, 130)
$Desktopbox.Name = "Desktopbox"
$Desktopbox.Size = New-Object System.Drawing.Size(66, 17)
$Desktopbox.TabIndex = 6
$Desktopbox.Text = "Desktop"
$Desktopbox.UseVisualStyleBackColor = $true
#
# DownloadsBox
#
$DownloadsBox.AutoSize = $true
$DownloadsBox.Checked = $true
$DownloadsBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$DownloadsBox.Location = New-Object System.Drawing.Point(26, 153)
$DownloadsBox.Name = "DownloadsBox"
$DownloadsBox.Size = New-Object System.Drawing.Size(79, 17)
$DownloadsBox.TabIndex = 7
$DownloadsBox.Text = "Downloads"
$DownloadsBox.UseVisualStyleBackColor = $true
#
# StartMenuBox
#
$StartMenuBox.AutoSize = $true
$StartMenuBox.Checked = $true
$StartMenuBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$StartMenuBox.Location = New-Object System.Drawing.Point(26, 176)
$StartMenuBox.Name = "StartMenuBox"
$StartMenuBox.Size = New-Object System.Drawing.Size(78, 17)
$StartMenuBox.TabIndex = 8
$StartMenuBox.Text = "Start Menu"
$StartMenuBox.UseVisualStyleBackColor = $true
#
# DocumentsBox
#
$DocumentsBox.AutoSize = $true
$DocumentsBox.Checked = $true
$DocumentsBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$DocumentsBox.Location = New-Object System.Drawing.Point(26, 199)
$DocumentsBox.Name = "DocumentsBox"
$DocumentsBox.Size = New-Object System.Drawing.Size(80, 17)
$DocumentsBox.TabIndex = 9
$DocumentsBox.Text = "Documents"
$DocumentsBox.UseVisualStyleBackColor = $true
#
# picturesbox
#
$picturesbox.AutoSize = $true
$picturesbox.Checked = $true
$picturesbox.CheckState = [System.Windows.Forms.CheckState]::Checked
$picturesbox.Location = New-Object System.Drawing.Point(112, 130)
$picturesbox.Name = "picturesbox"
$picturesbox.Size = New-Object System.Drawing.Size(64, 17)
$picturesbox.TabIndex = 10
$picturesbox.Text = "Pictures"
$picturesbox.UseVisualStyleBackColor = $true
#
# Tempfolderbox
#
$Tempfolderbox.AutoSize = $true
$Tempfolderbox.Checked = $true
$Tempfolderbox.CheckState = [System.Windows.Forms.CheckState]::Checked
$Tempfolderbox.Location = New-Object System.Drawing.Point(112, 153)
$Tempfolderbox.Name = "Tempfolderbox"
$Tempfolderbox.Size = New-Object System.Drawing.Size(85, 17)
$Tempfolderbox.TabIndex = 11
$Tempfolderbox.Text = "Temp Folder"
$Tempfolderbox.UseVisualStyleBackColor = $true
#
# favoritesbox
#
$favoritesbox.AutoSize = $true
$favoritesbox.Checked = $true
$favoritesbox.CheckState = [System.Windows.Forms.CheckState]::Checked
$favoritesbox.Location = New-Object System.Drawing.Point(112, 176)
$favoritesbox.Name = "favoritesbox"
$favoritesbox.Size = New-Object System.Drawing.Size(69, 17)
$favoritesbox.TabIndex = 12
$favoritesbox.Text = "Favorites"
$favoritesbox.UseVisualStyleBackColor = $true
#
# Signaturesbox
#
$Signaturesbox.AutoSize = $true
$Signaturesbox.Checked = $true
$Signaturesbox.CheckState = [System.Windows.Forms.CheckState]::Checked
$Signaturesbox.Location = New-Object System.Drawing.Point(112, 199)
$Signaturesbox.Name = "Signaturesbox"
$Signaturesbox.Size = New-Object System.Drawing.Size(76, 17)
$Signaturesbox.TabIndex = 13
$Signaturesbox.Text = "Signatures"
$Signaturesbox.UseVisualStyleBackColor = $true
#
# musicbox
#
$musicbox.AutoSize = $true
$musicbox.Checked = $true
$musicbox.CheckState = [System.Windows.Forms.CheckState]::Checked
$musicbox.Location = New-Object System.Drawing.Point(26, 222)
$musicbox.Name = "musicbox"
$musicbox.Size = New-Object System.Drawing.Size(54, 17)
$musicbox.TabIndex = 14
$musicbox.Text = "Music"
$musicbox.UseVisualStyleBackColor = $true
#
# CheckAllbox
#
$Checkallbox.AutoSize = $true
$Checkallbox.Checked = $true
$Checkallbox.CheckState = [System.Windows.Forms.CheckState]::Checked
$Checkallbox.Location = New-Object System.Drawing.Point(26, 250)
$Checkallbox.Name = "Checkallbox"
$Checkallbox.Size = New-Object System.Drawing.Size(54, 17)
$Checkallbox.TabIndex = 15
$Checkallbox.Text = "Check All"
$Checkallbox.UseVisualStyleBackColor = $true
#
#progress bar
$progressBar1 = New-Object System.Windows.Forms.ProgressBar
$progressBar1.Name = 'progressBar1'
$progressBar1.Value = 0
$progressBar1.Style="Continuous"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 215
$System_Drawing_Size.Height = 20
$progressBar1.Size = $System_Drawing_Size
$progressBar1.Left = 15
$progressBar1.Top = 270
$form1.Controls.Add($progressBar1)

#
# Form1
#
$Form1.ClientSize = New-Object System.Drawing.Size(245, 340)
$Form1.Controls.Add($Checkallbox)
$Form1.Controls.Add($musicbox)
$Form1.Controls.Add($Signaturesbox)
$Form1.Controls.Add($favoritesbox)
$Form1.Controls.Add($Tempfolderbox)
$Form1.Controls.Add($picturesbox)
$Form1.Controls.Add($DocumentsBox)
$Form1.Controls.Add($StartMenuBox)
$Form1.Controls.Add($DownloadsBox)
$Form1.Controls.Add($Desktopbox)
$Form1.Controls.Add($button1)
$Form1.Controls.Add($ListBox1)
$Form1.Controls.Add($ListBox2)
$Form1.Controls.Add($label2)
$Form1.Controls.Add($label1)
$Form1.Name = "Form1"
$Form1.Text = "Profile Migration"

function OnFormClosing_Form1{ 
	# $this parameter is equal to the sender (object)
	# $_ is equal to the parameter e (eventarg)

	# The CloseReason property indicates a reason for the closure :
	#   if (($_).CloseReason -eq [System.Windows.Forms.CloseReason]::UserClosing)

	#Sets the value indicating that the event should be canceled.
	($_).Cancel= $False
}

$Form1.Add_FormClosing( { OnFormClosing_Form1} )

$Form1.Add_Shown({$Form1.Activate()})
$ModalResult=$Form1.ShowDialog()
# Release the Form
$Form1.Dispose()
