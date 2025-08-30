# we need this, otherwise WT terminal won't display the fonts correctly
choco install nerd-fonts-meslo

# Run as Administrator
$fonts = Get-ChildItem "C:\Users\nikiforovall\AppData\Local\UniGetUI\Chocolatey\lib\nerd-fonts-Meslo\tools\*.ttf"
Add-Type -AssemblyName System.Drawing
$fontsCollection = New-Object System.Drawing.Text.InstalledFontCollection
$shell = New-Object -ComObject Shell.Application
$fontsFolder = $shell.Namespace(0x14)

foreach ($font in $fonts) {
    $fontsFolder.CopyHere($font.FullName, 0x10)
}