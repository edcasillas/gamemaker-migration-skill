param(
    [Parameter(Mandatory = $true)]
    [string]$InputDir,

    [Parameter(Mandatory = $true)]
    [string]$OutputDir,

    [Parameter(Mandatory = $true)]
    [string]$SoundFont,

    [string]$GmxSoundDir = "",

    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

function Require-Command {
    param([string]$Name)

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "Required command not found: $Name"
    }
}

Require-Command "fluidsynth"
Require-Command "ffmpeg"

$inputPath = (Resolve-Path -LiteralPath $InputDir).Path
$soundFontPath = (Resolve-Path -LiteralPath $SoundFont).Path

New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
$outputPath = (Resolve-Path -LiteralPath $OutputDir).Path

if ([string]::IsNullOrWhiteSpace($GmxSoundDir)) {
    $midiFiles = Get-ChildItem -LiteralPath $inputPath -File |
        Where-Object { $_.Extension -in @(".mid", ".midi") } |
        Sort-Object Name
} else {
    $soundDirPath = (Resolve-Path -LiteralPath $GmxSoundDir).Path
    $midiNames = Get-ChildItem -LiteralPath $soundDirPath -Filter "*.sound.gmx" -File |
        ForEach-Object {
            $xml = [xml](Get-Content -LiteralPath $_.FullName)
            if ($xml.sound.extension -in @(".mid", ".midi")) {
                $xml.sound.data
            }
        } |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Sort-Object -Unique

    $midiFiles = $midiNames | ForEach-Object {
        $path = Join-Path $inputPath $_
        if (Test-Path -LiteralPath $path) {
            Get-Item -LiteralPath $path
        } else {
            Write-Warning "Registered MIDI not found: $path"
        }
    }
}

if (-not $midiFiles -or $midiFiles.Count -eq 0) {
    throw "No MIDI files found to convert."
}

$tempDir = Join-Path $env:TEMP ("midi-convert-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {
    foreach ($midi in $midiFiles) {
        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($midi.Name)
        $wavPath = Join-Path $tempDir ($baseName + ".wav")
        $mp3Path = Join-Path $outputPath ($baseName + ".mp3")

        if ((Test-Path -LiteralPath $mp3Path) -and -not $Overwrite) {
            Write-Host "Skipping existing: $mp3Path"
            continue
        }

        Write-Host "Rendering MIDI to WAV: $($midi.Name)"
        & fluidsynth -ni -q -F "$wavPath" -r 44100 "$soundFontPath" "$($midi.FullName)"
        if ($LASTEXITCODE -ne 0) {
            throw "fluidsynth failed for $($midi.FullName)"
        }

        Write-Host "Encoding WAV to MP3: $mp3Path"
        & ffmpeg -y -hide_banner -loglevel error -i "$wavPath" -codec:a libmp3lame -q:a 2 "$mp3Path"
        if ($LASTEXITCODE -ne 0) {
            throw "ffmpeg failed for $wavPath"
        }
    }
} finally {
    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Done. MP3 files are in: $outputPath"
