Set-Alias dk 'C:\Program Files\dual-key-remap-v0.7\dual-key-remap.exe'
Set-Alias lvim 'C:\Users\camal\.local\bin\lvim.ps1'
Set-Alias cl clear
Set-Alias eb 'C:\Users\camal\.ebcli-virtual-env\executables\eb.ps1'

Import-Module PSReadLine
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -PredictionSource None

function prompt
{
  $loc = $($executionContext.SessionState.Path.CurrentLocation);
  $out = "PS $loc `n >> ";
  $out += "$([char]27)]9;9;`"$loc`"$([char]27)\"
  return $out
}

function yank
{
  param(
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]$value
  )
  $value | win32yank.exe -i 
}

# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\wopian.omp.json" | Invoke-Expression
# Import-Module Terminal-Icons
