$ProjectPath = "$PSScriptRoot\..\..\.." | Convert-Path
$ProjectName = ((Get-ChildItem -Path $ProjectPath\*\*.psd1).Where{
        ($_.Directory.Name -match 'source|src' -or $_.Directory.Name -eq $_.BaseName) -and
        $(try { Test-ModuleManifest $_.FullName -ErrorAction Stop } catch { $false } )
    }).BaseName

Import-Module $ProjectName -Force

Describe 'New-NotImplementedException' {
    Context 'When called with Message parameter only' {
        It 'Should throw the correct error' {
            $mockErrorMessage = 'Mocked error'

            { New-NotImplementedException -Message $mockErrorMessage } | Should -Throw $mockErrorMessage
        }
    }

    Context 'When called with both the Message and ErrorRecord parameter' {
        It 'Should throw the correct error' {
            $mockErrorMessage = 'Mocked error'
            $mockExceptionErrorMessage = 'Mocked exception error message'

            $mockException = New-Object -TypeName System.Exception -ArgumentList $mockExceptionErrorMessage
            $mockErrorRecord = New-Object -TypeName System.Management.Automation.ErrorRecord `
                -ArgumentList $mockException, $null, 'InvalidResult', $null

            # Wildcard processing needed to handle differing Powershell 5/6/7 exception output
            { New-NotImplementedException -Message $mockErrorMessage -ErrorRecord $mockErrorRecord } |
                Should -Throw -Passthru | Select-Object -ExpandProperty Exception |
                    Should -BeLike ('System.Exception: System.NotImplementedException: {0}*System.Exception: {1}*' -f
                        $mockErrorMessage, $mockExceptionErrorMessage)
        }
    }

    Assert-VerifiableMock
}
