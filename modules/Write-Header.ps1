# Function to display header information (Splash Screen & Title)
Clear-Host  # Clears the terminal screen

# ASCII Art splash screen
$darkRed = [System.ConsoleColor]::DarkRed
$white = [System.ConsoleColor]::White
$art = @"

                      ▄▄▄▄   ▓█████▄▄▄█████▓▄▄▄█████▓▓█████  ██▀███          
                     ▓█████▄ ▓█   ▀▓  ██▒ ▓▒▓  ██▒ ▓▒▓█   ▀ ▓██ ▒ ██▒        
                     ▒██▒ ▄██▒███  ▒ ▓██░ ▒░▒ ▓██░ ▒░▒███   ▓██ ░▄█ ▒        
                     ▒██░█▀  ▒▓█  ▄░ ▓██▓ ░ ░ ▓██▓ ░ ▒▓█  ▄ ▒██▀▀█▄          
                     ░▓█  ▀█▓░▒████▒ ▒██▒ ░   ▒██▒ ░ ░▒████▒░██▓ ▒██▒        
                     ░▒▓███▀▒░░ ▒░ ░ ▒ ░░     ▒ ░░   ░░ ▒░ ░░ ▒▓ ░▒▓░        
                     ▒░▒   ░  ░ ░  ░   ░        ░     ░ ░  ░  ░▒ ░ ▒░        
                      ░    ░    ░    ░        ░         ░     ░░   ░         
                      ░         ░  ░                    ░  ░   ░             
                           ░                                                 
                      ▄████▄   ██░ ██ ▓█████  ▄████▄   ██ ▄█▀▓█████  ██▀███  
                     ▒██▀ ▀█  ▓██░ ██▒▓█   ▀ ▒██▀ ▀█   ██▄█▒ ▓█   ▀ ▓██ ▒ ██▒
                     ▒▓█    ▄ ▒██▀▀██░▒███   ▒▓█    ▄ ▓███▄░ ▒███   ▓██ ░▄█ ▒
                     ▒▓▓▄ ▄██▒░▓█ ░██ ▒▓█  ▄ ▒▓▓▄ ▄██▒▓██ █▄ ▒▓█  ▄ ▒██▀▀█▄  
                     ▒ ▓███▀ ░░▓█▒░██▓░▒████▒▒ ▓███▀ ░▒██▒ █▄░▒████▒░██▓ ▒██▒
                     ░ ░▒ ▒  ░ ▒ ░░▒░▒░░ ▒░ ░░ ░▒ ▒  ░▒ ▒▒ ▓▒░░ ▒░ ░░ ▒▓ ░▒▓░
                       ░  ▒    ▒ ░▒░ ░ ░ ░  ░  ░  ▒   ░ ░▒ ▒░ ░ ░  ░  ░▒ ░ ▒░
                     ░         ░  ░░ ░   ░   ░        ░ ░░ ░    ░     ░░   ░ 
                     ░ ░       ░  ░  ░   ░  ░░ ░      ░  ░      ░  ░   ░     
                     ░                       ░                               
                     
"@

foreach ($char in $art.ToCharArray()) {
    if ($char -match '[▒░▓]') {
        Write-Host $char -ForegroundColor $darkRed -NoNewline
    }
    else {
        Write-Host $char -ForegroundColor $white -NoNewline
    }
}

# Encode and decode title text
$encodedTitle = "VXBkYXRlZCBieSBAYW5uYWJ4bGxhIG9uIERpc2NvcmQg4pml" # Joke about base64 being "encrypted" (For Reapiin because this is not "encryption")
$titleText = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($encodedTitle))

# Set terminal window title
$Host.UI.RawUI.WindowTitle = $titleText
