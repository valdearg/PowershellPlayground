$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceSUTs = Resolve-Path "$here\..\..\SourceSubjectsUnderTest.ps1"

# Some extra information.
"`$here = $here"
"`$sourceSUTs = $sourceSUTs"
"`$PSScriptRoot = $PSScriptRoot"
("`$MyInvocation.MyCommand = {0}" -f $MyInvocation.MyCommand)
("`$MyInvocation.MyCommand.Path = {0}" -f $MyInvocation.MyCommand.Path)

Describe 'Private.Size.Configuration' {
    . $sourceSUTs
    . SourceClasses
    . SourcePrivate

    Context 'PREFIXES' {
        It 'has 16 prefixes' {
            $PREFIXES.Length | Should Be 16
        }
        It 'has 8 prefixes with a Binary prefix type' {
            $binaryPrefixes = $PREFIXES | Where-Object { $_.PrefixType.IsBinary() }
            $binaryPrefixes.Length | Should Be 8
        }
        It 'has 8 prefixes with a Decimal prefix type' {
            $decimalPrefixes = $PREFIXES | Where-Object { $_.PrefixType.IsDecimal() }
            $decimalPrefixes.Length | Should Be 8
        }
    }
    Context 'UNITS' {
        It 'has 34 units' {
            $UNITS.Length | Should Be 34
        }
        It 'has (8 + 8 + 1) bit units' {
            $bitUnits = $UNITS | Where-Object { $_.UnitType -eq [UnitType]::BIT }
            $bitUnits.Length | Should Be (8 + 8 + 1)
        }
        It 'has (8 + 8 + 1) byte units' {
            $byteUnits = $UNITS | Where-Object { $_.UnitType -eq [UnitType]::BYTE }
            $byteUnits.Length | Should Be (8 + 8 + 1)
        }
        It 'has (8 + 8) units with a Binary prefix type' {
            $binaryPrefixUnits = $UNITS | Where-Object { $_.IsBinary() }
            $binaryPrefixUnits.Length | Should Be (8 + 8)
        }
        It 'has (8 + 8) units with a Decimal prefix type' {
            $decimalPrefixUnits = $UNITS | Where-Object { $_.IsDecimal() }
            $decimalPrefixUnits.Length | Should Be (8 + 8)
    
        }
    }
    Context 'ValidateUnit' {
        It 'Returns true for valid unit' {
            ValidateUnit 'B' | Should Be $true
            ValidateUnit 'Mib' | Should Be $true
        }
        It 'Throws for invalid unit' {
            { ValidateUnit 'Bla' } | Should Throw
        }
        It 'Is case sensitive' {
            { ValidateUnit 'kib'} | Should Throw
        }
    }
    Context 'GetUnitForName' {
        It 'Returns a unit for valid name' {
            $unit = GetUnitForName 'MiB'
            $unit | Should Not BeNullOrEmpty
            
            # Should BeOfType incorrectly asserts type and inconsistently processes type information : 
            # https://github.com/pester/Pester/issues/386
            # $unit | Should BeOfType [Unit] -> doesn't work. Apply method below.
            $unit.GetType() | Should Be 'Unit'
        }
        It 'Throws for invalid name' {
            { GetUnitForName 'Bla' } | Should Throw
        }
        It 'Is case sensitive' {
            { ValidateUnit 'kib'} | Should Throw
        }
    }
    Context 'GetUnitsForUnitType' {
        $units = GetUnitsForUnitType ([UnitType]::BYTE)
        It 'Returns the expected type' {
        
            $units | Should Not BeNullOrEmpty
            $units.GetType() | Should Be 'System.Object[]'
        }
        It 'Returns (8 + 8 + 1) units with unit type byte' {
            $units.Length | Should Be (8 + 8 + 1)
        }
    }
    Context 'GetUnitsForTypes' {
        $units = GetUnitsForTypes ([PrefixType]::BINARY) ([UnitType]::BYTE)
        It 'Returns the expected type' {
            $units | Should Not Be $null
            $units.GetType() | Should Be 'System.Object[]'
        }
        It 'Returns the expected number of units' {
            $units.Length | Should Be (8 + 1)
        }
    }
    Context 'GetAllUnitsAsString' {
        $s = GetAllUnitsAsString
        Write-Host $s
        It 'returns the expected value' {
            $s | Should BeExactly 'b, B, Kib, KiB, Mib, MiB, Gib, GiB, Tib, TiB, Pib, PiB, Eib, EiB, Zib, ZiB, Yib, YiB, Kb, KB, Mb, MB, Gb, GB, Tb, TB, Pb, PB, Eb, EB, Zb, ZB, Yb, YB'
        }
    }
}