param(
    [string]$source = "C:\Users\lucas.salviano\.gemini\antigravity-ide\brain\e4e7ab4d-2fc4-4db8-85eb-d831033d6e67\.user_uploaded\media_1789697899182.png"
)

$assetsDir = "C:\Users\lucas.salviano\Desktop\THIAGO APP\assets"
if (-not (Test-Path $assetsDir)) { 
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}
Copy-Item -Path $source -Destination "$assetsDir\zaraplast_logo.png" -Force

Add-Type -AssemblyName System.Drawing

function Resize-File([string]$src, [string]$dst, [int]$width, [int]$height) {
    $parent = Split-Path $dst -Parent
    if (-not (Test-Path $parent)) { 
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    $img = [System.Drawing.Image]::FromFile($src)
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($img, 0, 0, $width, $height)
    $bmp.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    $img.Dispose()
    Write-Host "Created: $dst ($width x $height)"
}

$logo = "$assetsDir\zaraplast_logo.png"

# Android Icons
$res = "C:\Users\lucas.salviano\Desktop\THIAGO APP\android\app\src\main\res"
Resize-File $logo "$res\mipmap-mdpi\ic_launcher.png" 48 48
Resize-File $logo "$res\mipmap-hdpi\ic_launcher.png" 72 72
Resize-File $logo "$res\mipmap-xhdpi\ic_launcher.png" 96 96
Resize-File $logo "$res\mipmap-xxhdpi\ic_launcher.png" 144 144
Resize-File $logo "$res\mipmap-xxxhdpi\ic_launcher.png" 192 192

# Web Icons
$web = "C:\Users\lucas.salviano\Desktop\THIAGO APP\web"
Resize-File $logo "$web\favicon.png" 64 64
Resize-File $logo "$web\icons\Icon-192.png" 192 192
Resize-File $logo "$web\icons\Icon-512.png" 512 512

Write-Host "ALL ICONS GENERATED SUCCESSFULLY!"
