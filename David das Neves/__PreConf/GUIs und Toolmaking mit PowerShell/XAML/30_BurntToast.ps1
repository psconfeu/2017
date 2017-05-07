#Examples
#New-BTAppId

#Default Toast
New-BurntToastNotification

#Customized Toast
New-BurntToastNotification -Text "Don't forget to smile!", 'Your script ran successfully, celebrate!' -AppLogo C:\smile.jpg

#Alarm Clock
New-BurntToastNotification -Text 'WAKE UP!' -Sound 'Alarm2' -SnoozeAndDismiss