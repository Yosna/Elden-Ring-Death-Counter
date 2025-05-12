# Elden Ring Death Counter [![Release v1.0.0](https://img.shields.io/badge/release-v1.0.0-blue)](https://github.com/Yosna/Elden-Ring-Death-Counter/releases/tag/v1.0.0)

A transparent on-screen death counter for Elden Ring. It reads your character’s stats from memory to display your death count in the bottom right corner. Disables EAC if necessary. Built using [AutoHotkey v2](https://autohotkey.com).

## Features

- **On-screen overlay:** displays your deaths in the bottom right corner above your runes
- **Toggle key (F8):** show and hide the overlay as needed
- **Manual overwrite:** set a custom death count
- **Multi-character support:** tracks characters by stats instead of save file structure, allowing custom death counts to persist across different save states
- **EAC detection & bypass:** adjusts the environment automatically to prevent Easy Anti-Cheat from running
- **Separate GUI window:** view your character's stats and modify their death count

## Requirements

- **Required:** Windows 10 or 11 (Linux and macOS are not supported)
- **Optional:** [AutoHotkey v2](https://autohotkey.com/) if you want to run the AHK script instead of the executable

## How To Use

### Run the executable

1. Download **ER-Death-Counter.exe** from the [Releases](https://github.com/Yosna/Elden-Ring-Death-Counter/releases/tag/v1.0.0) page
2. If blocked by Windows: right click the program -> select *Properties* -> check *Unblock* -> *Apply* the change
3. Double click **ER-Death-Counter.exe** to run the program

### Run the AHK script

1. Install [AutoHotkey v2](https://autohotkey.com/)
2. [Download ZIP](https://github.com/Yosna/Elden-Ring-Death-Counter/archive/refs/tags/v1.0.0.zip) and extract the folder to your desired location
3. Double click **deathcounter.ahk** to run the script

## License
- This project is licensed under the GNU General Public License v3.0. See [LICENSE](https://github.com/Yosna/Elden-Ring-Death-Counter/blob/main/LICENSE) for details.