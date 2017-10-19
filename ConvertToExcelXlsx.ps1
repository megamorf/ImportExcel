Function ConvertTo-ExcelXlsx {
[CmdletBinding()]
    Param
    (
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [string]$Path,
        [parameter(Mandatory=$false)]
        [switch]$Force,
        [parameter(Mandatory=$false)]
        [switch]$PassThru
    )
    Process
    {
        if(-Not ($Path | Test-Path) ){
            throw "File not found" 
        }
        if(-Not ($Path | Test-Path -PathType Leaf) ){
            throw "Folder paths are not allowed"
        }

        $xlFixedFormat = 51 #Constant for XLSX Workbook
        $xlsFile = Get-Item -Path $Path
        $xlsxPath = "{0}x" -f $xlsFile.FullName

        if($xlsFile.Extension -ne ".xls"){
            throw "Expected .xls extension"
        }

        if(Test-Path -Path $xlsxPath){
            if($Force){
                try {
                    Remove-Item $xlsxPath -Force
                } catch {
                    throw "{0} already exists and cannot be removed. The file may be locked by another application." -f $xlsxPath
                }
                Write-Verbose $("Removed existing {0}" -f $xlsxPath)
            } else {
                throw "{0} already exists!" -f $xlsxPath
            }
        }

        try{    
            $Excel = New-Object -ComObject "Excel.Application" -Verbose:$false
        } catch {
            throw "Could not create Excel.Application ComObject. Please verify that Excel is installed."
        }

        $Excel.Visible = $false
        $Excel.Workbooks.Open($xlsFile.FullName) | Out-Null
        $Excel.ActiveWorkbook.SaveAs($xlsxPath, $xlFixedFormat)
        $Excel.ActiveWorkbook.Close()
        $Excel.Quit()

        if ($PassThru){
            Get-Item $xlsxPath
        }
    }
}

