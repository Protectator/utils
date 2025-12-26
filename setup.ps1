Write-Host "Installing Chrome and Firefox..."
winget install Google.Chrome
winget install Mozilla.Firefox

Write-Host "Installing VSCode ..."
winget install Microsoft.VisualStudioCode

Write-Host "Installing 7zip, VLC and PowerToys..."
winget install 7zip.7zip
winget install VideoLAN.VLC
winget install Microsoft.PowerToys

Write-Host "Installing Discord and Spotify..."
winget install Discord.Discord
winget install Spotify.Spotify

Write-Host "Installing Git..."
winget install Git.Git

Write-Host "Installing Winaero Tweaker..."
winget install -e --id winaero.tweaker

Write-Host "Done"
pause
