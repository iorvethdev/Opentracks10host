# Path to your NCS2013 folder
$folder = "D:\Opentracks10host\NCS2013"
Set-Location $folder

# 1️⃣ Fix missing .mp3 extensions
Get-ChildItem | Where-Object { $_.Extension -eq "" } | Rename-Item -NewName { $_.Name + ".mp3" }

# 2️⃣ Optional: rename to just the title (strip extra stuff before .mp3)
# Uncomment the following line if you want to trim filenames to the title only
# Get-ChildItem *.mp3 | Rename-Item -NewName { ($_ -replace " \|.*\.mp3$", ".mp3") }

# 3️⃣ Update tracks.json
$tracksJsonPath = Join-Path $folder "tracks.json"
$tracks = Get-Content $tracksJsonPath -Raw | ConvertFrom-Json

foreach ($track in $tracks.Tracks) {
    # Match the file in folder by partial name
    $file = Get-ChildItem *.mp3 | Where-Object { $_.Name -like "*$($track.Name)*" } | Select-Object -First 1
    if ($file) {
        $track.Url = $file.Name
    } else {
        Write-Host "⚠️ Cannot find file for track: $($track.Name)"
    }
}

# Save updated JSON
$tracks | ConvertTo-Json -Depth 5 | Set-Content $tracksJsonPath -Encoding UTF8

# 4️⃣ Git add, commit, push
git add .
git commit -m "Fix MP3 filenames and update tracks.json"
git push

