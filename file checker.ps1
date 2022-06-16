﻿
write-host " "
write-host "What are you doing today?"
write-host "A) Collect new baseline?"
write-host "B) Monitor files with baseline?"

$response = Read-Host -Prompt "Enter A or B "

Write-host "Entered $($response))"

Function Calculate-File-Hash($filepath) {
#used to test caluclate function   $hash = Calculate-File-Hash "P:\Bizerba docs\test1.txt"
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exists () {
    #checks to see if files exists, then deletes it if it is
    $baselineExists = Test-Path -Path .\baseline.txt

    if ($baselineExists) {
        Remove-Item -Path .\baseline.txt
    }
}

if ($response -eq "A".ToUpper()) {
    #delete baseline file if it exist already
    Erase-Baseline-If-Already-Exists

    #Calculate hash from the target files, store data in baseline.txt
    Write-host "Calculate hashes, make new baseline file" -ForegroundColor Cyan

    #collect file in target folder
    $files = Get-ChildItem -Path "P:\Bizerba docs\testfolder" 
    

    #per file, calculate the hash, then write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($hash.Path)|$($hash.Hash)" | out-file -FilePath .\baseline.txt -Append
    }


}
elseif ($response -eq "B".ToUpper()){
 
    #creates empty hash table
    $fileHashDictionary = @{}

    #load hash file from baseline file and store them in dictinoary
    $filePathsAndHashes = Get-Content -Path .\baseline.txt

    foreach ($f in $filePathsAndHashes) {
        $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

    
    
    #continuouslyt Checks files with baseline"
   while ($true) {
    Start-sleep -seconds 1

    $files = Get-ChildItem -Path "P:\Bizerba docs\testfolder" 
    
    #per file, calculate the hash, then write to baseline.txt
    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        #"$($hash.Path)|$($hash.Hash)" | out-file -FilePath .\baseline.txt -Append
        
        #notify if new files has been made
        if ($fileHashDictionary[$hash.Path] -eq $null) {
        #a new file has been created
        write-host "$($hash.Path) has been created!" -Foreground Green
        }

        #file has been changed, notify user
        if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
        }

        write-host "$($hash.Path) has changed!!!" -Foregroundcolor Yellow
        }

        }

        foreach ($key in $fileHashDictionary.Keys){
        $baselineFilesStillExists = Test-Path -Path $key
        if (-Not $baselineFilesStillExists) {
            #a baseline file has been deleted, notify the user
            write-host "$($key) has been deleted" -ForegroundColor DarkRed
        }
        }
        
    }
        

