## Mandatory integrity control ´

# Create test folders
New-Item -ItemType Directory -Path 'c:\integritylevels'
New-Item -ItemType Directory -Path 'c:\integritylevels\low'
New-Item -ItemType Directory -Path 'c:\integritylevels\medium'
New-Item -ItemType Directory -Path 'c:\integritylevels\high'

# Everyone may do everything
icacls.exe 'c:\integritylevels' /inheritance:r
icacls.exe 'c:\integritylevels' /grant "*WD`:(OI)(CI)F"

# DEFINED:
# untrusted, low, medium, high, and system.

# icacls knows 3 of them:
icacls.exe 'c:\integritylevels\low' /setintegritylevel '(OI)(CI)L'
icacls.exe 'c:\integritylevels\medium' /setintegritylevel '(OI)(CI)M'
icacls.exe 'c:\integritylevels\high' /setintegritylevel '(OI)(CI)H'

# Display the levels (if defined):
icacls.exe 'c:\integritylevels\high' 
