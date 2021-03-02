# Exor MN Installer

### v1.1.0

A custom masternode install script made from scratch specifically for installing Exor masternodes.

Currently, it supports installation on Ubuntu 16.04+ and Debian 8.x+ x64 and should be generic enough to work on any VPS provider or as a local installation at home.

Since this script has the potential to install "extra" software components such as a firewall and/or create a swap disk file, root privileges are required to install properly. Therefore, you must either run the script using the `sudo` command prefix or else run directly as the root user (generally not recommended for security reasons but still supported).

All wallets are installed to the /usr/local/bin directory.

To save time on 2+ installs, the wallet binaries are archived in the wallet directory (typically /usr/local/bin/Exor) after the first successful install and those locally stored files are then used to install subsequent wallet installs in much less time than the first.

## Table of Contents

- [Features](#features)
- [Install Instructions](#install-instructions)
- [Update Instructions](#update-instructions)
- [Command-Line Options](#command-line-options)
- [Uninstall Instructions](#uninstall-instructions)
- [Useful Commands](#useful-commands)

## Features

- Supports installing, updating or uninstalling up to 99 Exor masternode installs on the same VPS
- IPv4 and IPv6 support
- Script update feature ensures you are always installing using the most up-to-date script
- Wallet update feature ensures you do not have to wait for an updated script to be released to install the latest wallet version
- Install wallet from compiled binary files or build from source code
- Faster syncing times for 2+ installs by copying previously installed blockchain files over to new installs
- Automatic restart of installed masternodes after reboot
- Stop all masternodes automatically when a reboot or shutdown command is issued to help prevent blockchain corruption
- Install additional setup components such as swap disk file, firewall configuration and brute-force protection
- Automatic generation of genkey value provides heightened security with less user interaction
- Visualize the blockchain sync process after installation to ensure wallet(s) are all caught up with current block counts
- Custom ascii art Exor logo

## Install Instructions

To begin, you must first download the initial script and give it execute permission with the following command:

```
wget https://raw.githubusercontent.com/team-exor/exor-mn-installer/master/exor-mn-installer.sh && chmod +x exor-mn-installer.sh
```

#### Install 1st/default wallet using IPv6:

```
sudo sh exor-mn-installer.sh
```

#### Install 1st/default wallet using the default IPv4 address:

```
sudo sh exor-mn-installer.sh -N 4
```

#### Install 2nd wallet using IPv6:

```
sudo sh exor-mn-installer.sh -n 2
```

#### Install 2nd wallet using IPv4:

**NOTE:** You cannot install more than one IPv4 wallet on the same IPv4 address. Assuming you have purchased more than one IPv4 IP address, you will need to explicitly specify the 2nd IP address using the `-i <ip address>` argument

Example:

```
sudo sh exor-mn-installer.sh -n 2 -N 4 -i 45.32.168.34
```

**NOTE:** Installing the 3rd, 4th, 5th, etc wallets are identical to the 2nd wallet except that you would change the `-n` value to 3, 4, 5, etc

```
sudo sh exor-mn-installer.sh -n 3
sudo sh exor-mn-installer.sh -n 4
sudo sh exor-mn-installer.sh -n 5
```

**NOTE:** If you are installing multiple wallets, they do not need to be installed in any specific order although it is generally easier to install in numerical sequence (install 1 then 2 then 3, etc).

## Update Instructions

#### Update Single Wallet Install

At any point after the initial installation you can "refresh" a particular wallet install by re-running the following command:

`sudo sh exor-mn-installer.sh`

This will "remember" all of your previously installed settings and allow you to update the installed wallet to the latest version (assuming a new version has been released since the last update/install).

If you would like to keep your wallet installed but just change one of the options, such as ip address type, you could update install using something like this:

`sudo sh exor-mn-installer.sh -N 4`

This would allow you to change an IPv6 installed wallet into an IPv4 wallet. **NOTE:** Changing options like this will most likely require you to reconfigure your controller wallet exor.conf and masternode.conf files. The 'Final setup instructions' are always displayed at the end of an update install the same way as they are for the initial install.

#### Update All Wallet Installs

To update all installed wallets with a single command, use the following:

`sudo sh exor-mn-installer.sh -U`

## Command-Line Options

- -h or --help

     Displays the help menu

     Usage Example: `sudo sh exor-mn-installer.sh -h`
- -t or --type

     Install type. There are 2 valid options: i = install (default), u = uninstall
     
     Usage Example: `sudo sh exor-mn-installer.sh -t i`
- -w or --wallet

     Wallet type. There are 2 valid options: d = download (default), b = build from source
     
     Usage Example: `sudo sh exor-mn-installer.sh -w b`
- -g or --genkey

     The masternode genkey value. Generate this with the `masternode genkey` command either automatically from the VPS wallet (recommended) or from your hot wallet in the Debug Console). If left blank the value will be autogenerated
     
     Usage Example: `sudo sh exor-mn-installer.sh -g 88pgtdc9rgiEFMarhuVAdDjeDBUiPbFPhqdafFsBUKcgS3XovPc`
- -N or --net

     IP address type. There are 2 valid options: 6 = IPv6 (default), 4 = IPv4
     
     Usage Example: `sudo sh exor-mn-installer.sh -N 4`
- -i or --ip

     Specify the IPv4 or IPv6 IP address to bind to the node. If left blank and -N = 4 then the main WAN IPv4 address will be used. If left blank and -N = 6 then a new IPv6 address will be registered

     Usage Example: `sudo sh exor-mn-installer.sh -i 46.5.102.49`
- -p or --port

     Specify the port # that the wallet should listen on. If left blank the value will be auto-selected
     
     Usage Example: `sudo sh exor-mn-installer.sh -p 4559`
- -n or --number

     The node install #. Default install # is 1. Increment this value to set up 2+ nodes. **Only a single wallet will be installed each time the script is run**. Valid inputs are 1-99
     
     Usage Example: `sudo sh exor-mn-installer.sh -n 2`
- -a or --adapter

     Specify the network adapter the node should be bound to. If left blank the first available and enabled adapter will be chosen
     
     Usage Example: `sudo sh exor-mn-installer.sh -a ens38`
- -s or --noswap

     Skip creating the disk swap file. The swap file only needs to be created once per computer. It is strongly recommended that you do not skip this install unless you are sure your VPS has enough memory
     
     Usage Example: `sudo sh exor-mn-installer.sh -s`
- -f or --nofirewall

     Skip the firewall setup. It is strongly recommended that you do not skip this install unless you plan to do the firewall setup manually
     
     Usage Example: `sudo sh exor-mn-installer.sh -f`
- -b or --nobruteprotect

     Skip the brute-force protection setup. Brute-force protection only needs to be installed once per computer
     
     Usage Example: `sudo sh exor-mn-installer.sh -b`
- -c or --nochainsync

     Skip waiting for the blockchain to sync after installation. Default is to wait for the blockchain to fully sync before exiting. Only works when the block explorer web address can be reached
     
     Usage Example: `sudo sh exor-mn-installer.sh -c`
- -u or --noosupgrade

     Skip applying operating system updates/upgrades before installation. Default is to run the following before doing an install:
     
     ```
     apt-get update
     apt-get upgrade
     apt-get dist-upgrade
     ```
     
     Usage Example: `sudo sh exor-mn-installer.sh -u`
- -S or --stopall

     Shutdown all wallets controlled by this script and wait for all to finish shutting down before continuing
     
     Usage Example: `sudo sh exor-mn-installer.sh -S`
- -U or --updateall

     Update all wallets controlled by this script one at a time until all are complete
     
     Usage Example: `sudo sh exor-mn-installer.sh -U`

## Uninstall Instructions

#### Uninstall 1st/default wallet:

```
sudo sh exor-mn-installer.sh -t u
```

#### Uninstall 2nd wallet:

```
sudo sh exor-mn-installer.sh -t u -n 2
```

#### Uninstall 3rd, 4th, 5th wallet:

```
sudo sh exor-mn-installer.sh -t u -n 3
sudo sh exor-mn-installer.sh -t u -n 4
sudo sh exor-mn-installer.sh -t u -n 5
```

**NOTE:** You can uninstall any wallet at any time. They do not need to be uninstalled in any specific order.

## Useful Commands

#### Stop the 1st/default wallet:

```
cexor stop
```

#### Stop the 2nd wallet:

```
cexor2 stop
```

#### Stop the 3rd, 4th, 5th wallet:

```
cexor3 stop
cexor4 stop
cexor5 stop
```

#### Start the 1st/default wallet:

```
dexor
```

#### Start the 2nd wallet:

```
dexor2
```

#### Start the 3rd, 4th, 5th wallet:

```
dexor3
dexor4
dexor5
```

#### View the 1st/default wallets current block:

```
cexor getblockcount
```

#### View the 2nd wallets current block:

```
cexor2 getblockcount
```

#### View the 3rd, 4th, 5th wallets current block:

```
cexor3 getblockcount
cexor4 getblockcount
cexor5 getblockcount
```

#### Check masternode status for the 1st/default wallet:

```
cexor getmasternodestatus
```

#### Check masternode status for the 2nd wallet:

```
cexor2 getmasternodestatus
```

#### Check masternode status for the 3rd, 4th, 5th wallets:

```
cexor3 getmasternodestatus
cexor4 getmasternodestatus
cexor5 getmasternodestatus
```

#### Shut down all running wallets:

```
sudo sh exor-mn-installer.sh -S
```

#### Sample cron job to shut down all running wallets and reboot once a month:

1st allow reboot cmd to be run without root permissions:

```
sudo chmod u+s /sbin/reboot
```

Then add the following to a crontab:

```
0 0 1 * * sh exor-mn-installer.sh -S && reboot
```

Alternate syntax in case you need to provide the full path to the reboot cmd:

```
0 0 1 * * sh exor-mn-installer.sh -S && /sbin/reboot
```