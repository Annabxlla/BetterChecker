# BetterChecker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PowerShell](https://img.shields.io/badge/built%20with-PowerShell-5391FE)](https://learn.microsoft.com/powershell/)
[![Issues](https://img.shields.io/github/issues/Annabxlla/BetterChecker)](https://github.com/Annabxlla/BetterChecker/issues)
[![Pull Requests](https://img.shields.io/github/issues-pr/Annabxlla/BetterChecker)](https://github.com/Annabxlla/BetterChecker/pulls)

BetterChecker is an open-source **PowerShell** tool for verifying the integrity of a player’s setup in **Tom Clancy’s Rainbow Six Siege**.  
It’s designed for streamers, YouTubers, and other trusted individuals to have a suspected player run the script to check for common cheats, injectors, or unfair modifications.

## Overview

- **Purpose-built for Rainbow Six Siege**  
  Scans for widely known cheats, injectors, or suspicious modifications.
- **Transparent & Safe**  
  Originally inspired by a closed-source script with questionable code.  
  BetterChecker was rebuilt from scratch to be open source, auditable, and safe to run.
- **Easy to Run**  
  Delivered as a single PowerShell script that can be executed via a one-liner.

## Features

- Detects common cheat tools and modifications.
- Lightweight and fast — minimal system impact.
- Fully open source for transparency.
- Regularly updated detection signatures (when applicable).

## Running BetterChecker

You can run BetterChecker directly with a one-liner in PowerShell.  

### Run with a single command
```powershell
iex(iwr("https://raw.githubusercontent.com/Annabxlla/BetterChecker/refs/heads/master/main.ps1"))
```

*(This downloads and executes the latest `main.ps1` from GitHub.)*

Or, if you prefer to download and inspect first:

### Download and inspect manually
```sh
git clone https://github.com/Annabxlla/BetterChecker
```

### After running
The script will perform checks and output a report indicating any detected suspicious files, processes, or configurations.

## Project Structure
```
BetterChecker/
├── main.ps1        # main detection script
├── modules/        # sub-scripts
└── README.md
```

## Intended Use

BetterChecker is meant for **legitimate, non-malicious verification** by trusted parties (streamers, content creators, competitive players).  
It is **not** an anti-cheat system and does not provide real-time enforcement.

## License
This project is licensed under the [MIT License](LICENSE).  

