---
external help file: FishTank-help.xml
online version: 
schema: 2.0.0
---

# Import-FishTank

## SYNOPSIS
Imports fish tanks from external ftk files

## SYNTAX

### Path (Default)
```
Import-FishTank [-Path] <String[]> [-Include <String[]>] [-Exclude <String[]>] [<CommonParameters>]
```

### LiteralPath
```
Import-FishTank [-LiteralPath] <String[]> [-Include <String[]>] [-Exclude <String[]>] [<CommonParameters>]
```

## DESCRIPTION

## EXAMPLES

### Example 1
```
PS C:\> Import-FishTank -Path d:\tanks\*.ftk
```

Imports all fish tank data in d:\tanks

## PARAMETERS

### -Exclude
Do not import from the files that matches the exclude pattern

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Include
Import only from the files that matches the include pattern

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LiteralPath
Literal path to one or more locations.

```yaml
Type: String[]
Parameter Sets: LiteralPath
Aliases: PSPath

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Path
Path to one or more locations.

```yaml
Type: String[]
Parameter Sets: Path
Aliases: 

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### FishTank

## NOTES

## RELATED LINKS

