# Velocet's PowerShell Repository [![GitHub release](http://img.shields.io/github/release/velocet/dotfiles.svg?maxAge=2592000)](../releases/) [![license](http://img.shields.io/github/license/velocet/dotfiles.svg?maxAge=2592000)](../LICENSE)

[![GitHub issues](http://img.shields.io/github/issues-raw/velocet/dotfiles.svg?maxAge=2592000)](../issues/)
[![GitHub pull request](http://img.shields.io/github/issues-pr-raw/velocet/dotfiles.svg?maxAge=2592000)](../pulls/)

**vPoShRepo** is a collection of personal PoSh scripts for use in PoSh and ISE

> TODO PoSh Loading Screen einfügen
<p align="center"><img src="http://assets-cdn.github.com/images/modules/logos_page/GitHub-Logo.png"/></p>

## **Download**

* :package: [Version 2.1.1](../releases/)
* :octocat: [Source Code](../archive/master.zip)

---

## TODO

Eventuell einarbeiten:
Questions (FAQ), Issues & Bug Reports & Feature Requests

* Motd einarbeiten:
Fortune Cookie Online: http://www.thebuttonfactory.nl/?p=3127
Fortune Cookie Offline: https://anjaz.ch/2015/08/24/motd-for-powershell-using-the-fortune-mod-linux-package-files/
Fortune Cookie RSS: http://www.harleystagner.com/uncategorized/powershell-rss-powered-message-of-the-day.php
* http://winaero.com/blog/how-to-clear-all-event-logs-in-windows-10/
* https://github.com/FuzzySecurity/PowerShell-Suite/tree/master/Bypass-UAC
---

<!-- TOC -->

* [Getting Started](#getting-started)
  * [Pre-Requirements](#pre-requirements)
  * [Dependencies](#dependencies)
  * [Installation](#installation)
* [Documentation](#documentation)
  * [Usage](#usage)
    * [Examples](#examples)
  * [Deployment](#deployment)
  * [Development](#development)
    * [Compilation](#compilation)
    * [Running the tests](#running-the-tests)
      * [Test 1](#test-1)
      * [Test 2](#test-2)
  * [API Reference](#api-reference)
* [Contributing](#contributing)
  * [Versioning](#versioning)
  * [Translating](#translating)
  * [Code of Conduct](#code-of-conduct)
* [About](#about)
  * [Author/Team & Contact](#authorteam-contact)
  * [Contributors](#contributors)
    * [Translation](#translation)
  * [Third-party libraries](#third-party-libraries)
  * [Acknowledgments & Notes](#acknowledgments-notes)
  * [Release History / Change-log](#release-history-change-log)
  * [ToDo](#heavycheckmark-to-do)
  * [Built With](#built-with)
* [License](#pagefacingup-license)

<!-- /TOC -->

---

## Getting Started

These instructions will get the project up and running on your local machine.

### Pre-Requirements

* Execution Policy set to *Bypass* or *Unrestricted*
  * Get the current execution policy: `Get-ExecutionPolicy`
  * Set the current execution policy to *Unrestricted*: `Set-ExecutionPolicy Unrestricted`
    * Note: You need a elevated PoSh terminal

#### Dependencies

No dependencies as of now.

### Installation

#### Method 1 (recommended)
* Open an elevated PoSh prompt:
  ```PowerShell
  iwr http://raw.githubusercontent.com/Velocet/PowerShell/master/install.ps1 -UseBasicParsing | iex
  ```
  This will download, extract and install everything automatically into your PoSh profile folder.
  
  Find your profile directory:
  ```PowerShell
  Split-Path $PROFILE
  ```

#### Method 2
* Open an elevated PoSh prompt.

* Download the [latest version](../archive/master.zip):
  ```PowerShell
  # Downloads the latest version to the current directory
  iwr https://github.com/Velocet/PowerShell/archive/master.zip -OutFile master.zip
  ```

* Extract it the archive to a folder named after your username:
  ```PowerShell
  Expand-Archive master.zip $env:USERNAME
  ```

* Move the extracted folder to your PoSh profile folder:
  ```PowerShell
  mv $env:USERNAME $(Split-Path $PROFILE)
  ```

* To load the profile everytime we open a new prompt we only have to execute this last line:
  ```PowerShell
  # Replace '$env:USERNAME' if you have used another name for the folder
  Add-Content $PROFILE '`n. $env:USERNAME\profile.ps1'
  ```

**Note**: If you used another name instead of *$env:USERNAME* you have to adjust the commands.
---

## Documentation

The idea of this PoSh repo is to have all your files inside one folder which could reside anywhere on the local machine. The best way would be to keep it on OneDrive or another cloud provider to have all your scripts right by your hand.

### Usage

This PoSh script repo should be at least invasive as it could be. This is why you only have to add one line to your *profile.ps1* file.

If you want to replace your profile files completly with the files of this repo you could just overwrite them. This is the main reason why the three files in the repo are named like the original files but are residing inside a seperate directory.

After adding the line which loads the repo to your $PROFILE ..

#### Examples

Examples showing how to use the application

```PowerShell
Write-Host 'Hello World!'
```

### Deployment

Add additional notes about how to deploy this on a live system

### Development

Always stick to the official [Cmdlet Development Guidelines](https://msdn.microsoft.com/en-us/library/ms714657(v=vs.85).aspx) and coding guidelines provided by ISESteroids (which are based on [The PowerShell Best Practices and Style Guide](https://github.com/PoshCode/PowerShellPracticeAndStyle)).

---

## Contributing

1. Fork it!
1. Create your feature branch: `git checkout -b my-new-feature`
1. Commit your changes: `git commit -am 'Add some feature'`
1. Push to the branch: `git push origin my-new-feature`
1. Submit a pull request :)

### Versioning

I use [SemVer](http://semver.org/) for versioning. For available versions, see the [tags](../tags).

---

## About

This project started as tool base to help me with common task i encounter on different PCs. Since i have to deal with many different computers and accounts i needed a fast and single folder solution which could be downloaded instantly.

### Author & Contact

* **Felix Niederhausen** - [Homepage / E-Mail](https://velocet.de/)
* Twitter: [@velocet](https://twitter.com/velocet/ "Velocet on twitter")
* PowerShell Gallery: [Velocet's Profile](https://www.powershellgallery.com/profiles/Velocet/)

### Contributors

See also the list of [contributors](../contributors/) who participated in this project.

### Third-party libraries

[ISESteroids](http://www.powertheshell.com/isesteroids/) from Dr. Tobias Weltner

### Acknowledgments & Notes

* Thanks to [M. Miller](https://github.com/mmillar-bolis/ps-motd) for the initial `Get-MotD` version

### Release History / Change-log

For a change-log please see the [releases page](../releases/).

#### :heavy_check_mark: To-Do

* :small_red_triangle: MotD überarbeiten...
* :small_orange_diamond: Priority 2
* :small_red_triangle_down: Priority 3

### Built With

* [ISESteroids](www.powertheshell.com/isesteroids/)
* [Visual Studio Code](https://code.visualstudio.com/)
* Icons by [The Noun Project](https://thenounproject.com/)
* Badges by [Shields.io](http://shields.io/)

---

## :page_facing_up: License

This project is licensed under the *MIT License* - see the [LICENSE](LICENSE.md) file for details.

The documentation of this project is licensed under the [GNU Free Documentation License](https://www.gnu.org/licenses/fdl-1.3.en.html).
