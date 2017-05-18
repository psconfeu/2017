---
external help file: FishTank-help.xml
online version: 
schema: 2.0.0
---

# Add-FishTank

## SYNOPSIS
Adds a new fishtank

## SYNTAX

```
Add-FishTank [-ModelName] <String> [-Location] <String> [[-Fish] <Fish[]>] [<CommonParameters>]
```

## DESCRIPTION
Adds a new fishtank to the system specifying the model and a location

## EXAMPLES

### Example 1
```
PS C:\> Add-fishtank -Model 'Aquarium Evolution 40' -Location Livingroom
```

Adds a new fishtank in the livingroom

## PARAMETERS

### -Fish
{{Fill Fish Description}}

```yaml
Type: Fish[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Location
{{Fill Location Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModelName
{{Fill ModelName Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Fish[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

