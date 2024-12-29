#!/bin/bash
#
# Version: v2.0.0
# Date:    March 3, 2021
#
# Run this script with the desired parameters or leave blank to install using defaults. Use -h for help.
#
# Tested to be working on Ubuntu 16.04+ and Debian 8.x+ x64
# Please report other working instances to:
#       Telegram: @joeuhren on https://t.me/ExorOfficialSupport
#       or
#       Discord: @joeteamexor on https://discord.gg/dSuGm3y
# A special thank you to @marsmensch for releasing the NODEMASTER script which helped immensely for integrating IPv6 support

# Global Variables
readonly SCRIPT_VERSION="2.0.0"
readonly WALLET_URL_TEMPLATE="https://github.com/team-exor/exor/releases/download/\${WALLET_VERSION}/"
readonly SOURCE_URL="https://github.com/team-exor/exor.git"
readonly SOURCE_DIR="exor"
readonly TITLE_STRING="Exor Masternode Installer"
readonly ARCHIVE_DIR_TEMPLATE="\${WALLET_PREFIX}-\${WALLET_VERSION}"
readonly DEFAULT_PORT_NUMBER=51572
readonly DEFAULT_RPC_PORT=51573
readonly DEFAULT_WALLET_DIR="Exor"
readonly DEFAULT_DATA_DIR=".exor"
readonly WALLET_CONFIG_NAME="exor.conf"
readonly IP4_CONFIG_NAME=".ip4.conf"
readonly IP6_CONFIG_NAME=".ip6.conf"
readonly NET_INTERFACE_CONFIG_NAME=".net.conf"
readonly REBOOT_SCRIPT_NAME=".reboot.sh"
readonly SHUTDOWN_SCRIPT_NAME=".shutdown.sh"
readonly WALLET_FILE_TEMPLATE="\${WALLET_PREFIX}-\${WALLET_VERSION}-x86_64-linux-gnu.tar.gz"
readonly WALLET_PREFIX="exor"
readonly PEER_DATA_CMD="getconnectioncount"
readonly BLOCKCOUNT_URL="https://explorer.exor.io/api/getblockcount"
readonly RELEASES_URL="https://api.github.com/repos/team-exor/exor/releases"
readonly SNAPSHOT_URL="https://explorer.exor.io/ext/getnewestsnapshot/tgz/url"
readonly NONE="\033[00m"
readonly ORANGE="\033[00;33m"
readonly RED="\033[01;31m"
readonly GREEN="\033[01;32m"
readonly CYAN="\033[01;36m"
readonly GREY="\033[01;30m"
readonly PURPLE="\033[01;35m"
readonly ULINE="\033[4m"
readonly RC_LOCAL="/etc/rc.local" # TODO: Remove this line in the near future
readonly NETWORK_BASE_TAG="5123"
readonly HOME_DIR="/usr/local/bin"
readonly SERVICE_DIR="/etc/systemd/system"
readonly TEMP_UPDATE_CONFIG_PATH="/tmp/exor-mn-update.conf"
readonly DAEMON_SCRIPT_PREFIX="d"
readonly CLI_SCRIPT_PREFIX="c"
readonly VERSION_URL="https://raw.githubusercontent.com/team-exor/exor-mn-installer/master/VERSION"
readonly SCRIPT_URL="https://raw.githubusercontent.com/team-exor/exor-mn-installer/master/exor-mn-installer.sh"
readonly NEW_CHANGES_URL="https://raw.githubusercontent.com/team-exor/exor-mn-installer/master/NEW_CHANGES"
readonly COPY_FILE1="blocks"
readonly COPY_FILE2="chainstate"
readonly COPY_FILE3="sporks"
readonly COPY_FILE4="zerocoin"
readonly COPY_FILE5=""
readonly COPY_FILE6=""
readonly COPY_FILE7=""
readonly COPY_FILE8=""
readonly COPY_FILE9=""
readonly COPY_FILE10=""
readonly DELETE_FILE1="blocks"
readonly DELETE_FILE2="chainstate"
readonly DELETE_FILE3="sporks"
readonly DELETE_FILE4="zerocoin"
readonly DELETE_FILE5="banlist.dat"
readonly DELETE_FILE6=""
readonly DELETE_FILE7=""
readonly DELETE_FILE8=""
readonly DELETE_FILE9=""
readonly DELETE_FILE10=""
readonly WELCOME_MSG="                   ${ORANGE}.:+ssssssssss+:.\n                :oys+${GREY}oosyhhhhys++${ORANGE}/oyo:\n              /hs+${GREY}odNMMMMMMMMMMMMNh+${ORANGE}/oh/\n            :hs/${GREY}hMMMMMMMMMMMMMMMMMMMMy${ORANGE}:oh:\n           oh+${GREY}sMMMMMmmNNNNNNNNNNNMMMMMMo${ORANGE}/ho\n          oh/${GREY}hMMMMMMh${ORANGE}\\-\`\`-ossss+o${GREY}MMMMMMMh${ORANGE}/do\n         -d+${GREY}sMMMMMMMMM${ORANGE}y\`\`+${GREY}MMMMMN${ORANGE}s${GREY}MMMMMMMMy${ORANGE}od-\n         yy:${GREY}MMMMMMMMMM${ORANGE}y\`\`+${GREY}MMMM${ORANGE}h${GREY}mMMMMMMMMMM${ORANGE}/hy\n         dy+${GREY}MMMMMMMMMM${ORANGE}y\`\`.+o+:o${GREY}dMMMMMMMMMM${ORANGE}ohd\n         dy+${GREY}MMMMMMMMMM${ORANGE}y.\`/${GREY}MMMm${ORANGE}y${GREY}hMMMMMMMMMM${ORANGE}ohd\n         yh:${GREY}NMMMMMMMMM${ORANGE}y..+${GREY}MMMMNNMMMMMMMMMM${ORANGE}/hy\n         -do${GREY}sMMMMMMMMM${ORANGE}y..+${GREY}MMMMMN${ORANGE}s:${GREY}NMMMMMMs${ORANGE}od-\n          oh/${GREY}yMMMMMMMh${ORANGE}/-.-+++/-./${GREY}mMMMMMMy${ORANGE}/do\n           oh+${GREY}oNMMMMMMMMMMMMMNNMMMMMMMN+${ORANGE}/do\n            :hs${GREY}+yNMMMMMMMMMMMMMMMMMMNs:${ORANGE}sh:\n              +hs${GREY}+ohNMMMMMMMMMMMMNy+/${ORANGE}sh+\n                :ohy${GREY}++oosyyyyso++/${ORANGE}sho:\n                   ./+syyyyyyyys+/.${NONE}"
WALLET_VERSION="1.0.0"

# Default variables
NET_TYPE=6
INSTALL_TYPE="i"
WALLET_TYPE="d"
PORT_NUMBER=`expr $DEFAULT_PORT_NUMBER - 1`
INSTALL_NUM=1
SWAP=1
FIREWALL=1
FAIL2BAN=1
SYNCCHAIN=1
OSUPGRADE=1
REINDEX=""
WAIT_TIMEOUT=5
DATA_INSTALL_DIR=""
WALLET_INSTALL_DIR=""
NET_INTERFACE=""
UPDATE_INDEX=0
WRITE_IP4_CONF=0
WRITE_IP6_CONF=0
ARCHIVE_DIR=""
CURRENT_USER="${SUDO_USER}"
USER_HOME_DIR="$(awk -F: -v v="${CURRENT_USER}" '{if ($1==v) print $6}' /etc/passwd)"

# Functions
error_message() {
  echo "${RED}Error:${NONE} $1" && echo && exit
}

welcome_screen() {
  # Check if running an updateall install
  if [ -z "${UPDATE_INDEX}" ] || [ ${UPDATE_INDEX} -eq 0 ] || [ ${UPDATE_INDEX} -eq 1 ]; then
    # Not an updateall install or it is the first updateall install
    clear
    echo "${WELCOME_MSG}"
  fi
}

help_menu() {
  clear
  echo "${0##*/}, v$SCRIPT_VERSION usage example:"
  echo "sudo sh ${0##*/} [OPTION]"
  echo && echo "Options:" && echo
  echo "  -h, --help"
  echo "            display this help information screen and exit"
  echo "  -t, --type [string]"
  echo "            install type"
  echo "            2 valid options: i = install (default), u = uninstall"
  echo "  -w, --wallet [string]"
  echo "            wallet type"
  echo "            2 valid options: d = download (default), b = build from source"
  echo "  -g, --genkey [string]"
  echo "            masternode genkey value"
  echo "            if left blank the genkey value will be autogenerated"
  echo "  -N, --net [integer]"
  echo "            ip address type"
  echo "            2 valid options: 6 = ipv6 (default), 4 = ipv4"
  echo "  -i, --ip [string]"
  echo "            bind node to a specific ipv4 or ipv6 ip address"
  echo "            if left blank and -N = 4 then the main wan ipv4 address will be used"
  echo "            if left blank and -N = 6 then a new ipv6 address will be registered"
  echo "  -p, --port [integer]"
  echo "            node will listen on specific port #"
  echo "            if left blank the port will default to ${PORT_NUMBER} + value of -n"
  echo "  -n, --number [integer]"
  echo "            node install #"
  echo "            default install # is 1"
  echo "            increment this value to set up 2+ nodes"
  echo "            only a single wallet will be installed each time the script is run"
  echo "            valid inputs are 1-99"
  echo "  -a, --adapter [string]"
  echo "            bind node to a specific network adapter by name"
  echo "            if left blank the first available and enabled adapter will be chosen"
  echo "  -s, --noswap"
  echo "            skip creating the disk swap file"
  echo "            default is to install the disk swap file"
  echo "            the swap file only needs to be created once per computer"
  echo "            it is strongly recommended that you do not skip this install"
  echo "            unless you are sure your VPS has enough memory"
  echo "  -f, --nofirewall"
  echo "            skip the firewall setup"
  echo "            default is to install and configure the firewall"
  echo "            it is strongly recommended that you do not skip this install"
  echo "            unless you plan to do the firewall setup manually"
  echo "  -b, --nobruteprotect"
  echo "            skip the brute-force protection setup"
  echo "            default is to install and configure brute-force protection"
  echo "            brute-force protection only needs to be installed once per computer"
  echo "  -c, --nochainsync"
  echo "            skip waiting for the blockchain to sync after installation"
  echo "            default is to wait for the blockchain to fully sync before exiting"
  echo "  -u, --noosupgrade"
  echo "            skip applying operating system updates/upgrades before installation"
  echo "            default is to run the following before doing an install:"
  echo "            apt-get update"
  echo "            apt-get upgrade"
  echo "            apt-get dist-upgrade"
  echo "  -r, --reindex"
  echo "            purge the blockchain data files for the current wallet install"
  echo "            use this option to get back on the main blockchain when a wallet"
  echo "            becomes corrupt or forked"
  echo "            only applicable to update installs"
  echo "            3 valid options: r = reinstall from scratch (default)"
  echo "                             c = copy blockchain from another wallet"
  echo "                             s = install from latest snapshot"
  echo "  -R, --rpcall"
  echo "            send an RPC command to all wallets controlled by this script and"
  echo "            display the results"
  echo "  -S, --stopall"
  echo "            shutdown all wallets controlled by this script and wait for all to"
  echo "            finish shutting down before continuing"
  echo "  -U, --updateall"
  echo "            update all wallets controlled by this script one at a time until all"
  echo "            are complete"
}

begins_with() { case $2 in "$1"*) true;; *) false;; esac; }
contains() { case $2 in *"$1"*) true;; *) false;; esac; }
str_replace() { echo `echo $1 | sed 's/'"${2}"'/'"${3}"'/g'`; }
count_occurances() { echo `echo "$1" | grep -o "$2" | wc -l`; }

strindex() {
  x="${1%%$2*}"
  [ "$x" = "$1" ] && echo -1 || echo "${#x}"
}

execute_command() {
  # Ensure that the command is run as the user who initiated the script
  if [ "$USER" != "${CURRENT_USER}" ]; then
    su ${CURRENT_USER} -c "${1}"
  else
    eval "${1}"
  fi
}

validate_genkey() {
  if [ $(printf "%s" "$1" | wc -m) -ne 51 ]; then
    echo "err"
  fi
}

validate_ip4address() {
  IFS=. read a b c d << EOF
  $1
EOF

  if ! ( for i in a b c d; do
      eval test \$$i -gt 0 && eval test \$$i -le 255 || exit 1
    done 2> /dev/null )
  then
    echo "err"
  fi
}

validate_ip6address() {
  if ! (echo $1 | grep -Eq '^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'); then
    echo "err"
  else
    # Format is valid so now check if the address is already available
    ip -6 addr | grep -qi "$1"
    if [ $? -ne 0 ]; then
      # IP address is not already availble so now check if the this address can be created
      if ! begins_with "${IPV6_INT_BASE}" "$1"; then
        echo "err"
      fi
    fi
  fi
}

validate_port() {
  if [ -z "$1" ] || ([ -n "$1" ] && ((echo $1 | egrep -q '^[0-9]+$' && ([ $1 -lt 1 ] || [ $1 -gt 65535 ])) || ! test "$1" -gt 0 2> /dev/null)); then
    echo "err"
  fi
}

validate_install_num() {
  if [ -z "$1" ] || ([ -n "$1" ] && ((echo $1 | egrep -q '^[0-9]+$' && ([ $1 -lt 1 ] || [ $1 -gt 99 ])) || ! test "$1" -gt 0 2> /dev/null)); then
    echo "err"
  fi
}

is_url() {
  # Regex pattern to match a valid URL
  url_regex="^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$"

  # Check if the argument matches the URL pattern
  if echo "$1" | grep -qE "$url_regex"; then
    # Argument is a valid URL
    return "0"
  else
    # Argument is not a valid URL
    return "1"
  fi
}

check_stop_wallet() {
  # Check if the wallet is currently running
  if [ -f "${HOME_DIR}/${1}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${1}/${WALLET_PREFIX}d" 2> /dev/null)" ]; then
    # Wallet is running. Issue stop command
    ${HOME_DIR}/${1}/${WALLET_PREFIX}-cli -datadir=${USER_HOME_DIR}/${2} stop >/dev/null 2>&1
    # Wait for wallet to close
    PERIOD=".  "

    while [ -f "${HOME_DIR}/${1}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${1}/${WALLET_PREFIX}d" 2> /dev/null)" ]
    do
      sleep 1 &
      printf "\rWaiting for wallet to close%s" "${PERIOD}"
      case $PERIOD in
        ".  ") PERIOD=".. "
           ;;
        ".. ") PERIOD="..."
           ;;
        *) PERIOD=".  " ;;
      esac
      wait
    done
    printf "\rWallet closed successfully    " && echo
  fi
}

init_network() {
  # Check if the network interface was already set
  if [ -z "${NET_INTERFACE}" ]; then
    # Loop through all known network interfaces
    for file in /sys/class/net/*; do
      # Remove the path from the network interface name
      NET_INTERFACE="$(basename "$file")"

      # Lookup more details about this network interface
      INTERFACE_DETAIL="$(ip address show $(basename "$file"))"

      # Interface is invalid until proven to be valid
      VALID_INTERFACE=0

      # Check if this is an IPv4 or IPv6 install
      if [ "$NET_TYPE" -eq 6 ]; then
        # This is an IPv6 install
        # Check if this is a valid IPv6 network interface
        if contains " inet6 " "${INTERFACE_DETAIL}" && ! contains " inet6 ::1" "${INTERFACE_DETAIL}"; then
          # The interface is valid
          VALID_INTERFACE=1
        fi
      else
        # This is an IPv4 install
        # Check if this is a valid IPv4 network interface
        if contains " inet " "${INTERFACE_DETAIL}" && ! contains " inet 127.0.0.1" "${INTERFACE_DETAIL}"; then
          # The interface is valid
          VALID_INTERFACE=1
        fi
      fi

      # Check if the interface is valid
      if [ "$VALID_INTERFACE" -eq 1 ]; then
        # Ensure that the interface is enabled
        if [ "$(check_network_interface_enabled ${NET_INTERFACE})" = "1" ]; then
          # This interface is enabled and meets all requirements
          VALID_INTERFACE=2
          # Stop checking for a valid network interfaces
          break
        fi
      fi
    done
  else
    # Network interface already set via command line or "remembered" via update install
    # Ensure that the interface is enabled
    if [ "$(check_network_interface_enabled ${NET_INTERFACE})" = "1" ]; then
      # This interface is enabled and meets all requirements
      VALID_INTERFACE=2
    else
      # Interface is invalid
      VALID_INTERFACE=0
    fi
  fi

  # Check if a valid network interface was found
  if [ "$VALID_INTERFACE" -ne 2 ]; then
    # No valid network interface found
    echo && error_message "Cannot find the default network interface or it is disabled"
  fi
}

init_ipv6() {
  # Initialize network variables
  init_network
  # Get the base IPv6 address
  IPV6_INT_BASE="$(ip -6 addr show dev ${NET_INTERFACE} | grep inet6 | awk -F '[ \t]+|/' '{print $3}' | grep -v ^fe80 | grep -v ^::1 | cut -f1-4 -d':' | head -1)"

  if [ -z "${IPV6_INT_BASE}" ]; then
    echo && error_message "No IPv6 support found. Did you forget to enable it during installation?"
  fi
}

check_network_interface_enabled() {
  # Check if the operstate file exists for this interface
  if [ -f /sys/class/net/${1}/operstate ]; then
    # Interface operstate file exists
    # Check the current status
    if [ "$(cat /sys/class/net/${1}/operstate)" = "up" ]; then
      # This interface is enabled and meets all requirements
      echo "1"
    else
      # This interface is disabled
      echo "0"
    fi
  else
    # This interface doesn't have a state file and is therefore invalid
    echo "0"
  fi
}

install_package() {
  # Install the package
  echo "${CYAN}#####${NONE} Install ${2} ${CYAN}#####${NONE}" && echo
  sleep 2
  apt-get install ${1} -y && echo

  # Check to ensure the package was installed
  if [ -z "$({ dpkg -l | grep -E '^ii' | grep ${1}; })" ]; then
    echo && error_message "Failed to install ${2}"
  fi
}

extract_wallet_files() {
  echo "${CYAN}#####${NONE} Extract wallet files ${CYAN}#####${NONE}" && echo
  tar -zxvf "${WALLET_BASE_DIR}/${WALLET_FILE}" -C "${USER_HOME_DIR}" && echo
}

extract_snapshot_files() {
  echo "${CYAN}#####${NONE} Extract snapshot files ${CYAN}#####${NONE}" && echo
  execute_command "tar -zxvf ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz -C ${USER_HOME_DIR}/${DATA_INSTALL_DIR}" && echo
}

delete_blockchain() {
  # Delete the necessary files from the current data directory
  if [ -n "${DELETE_FILE1}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE1}"
  fi

  if [ -n "${DELETE_FILE2}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE2}"
  fi

  if [ -n "${DELETE_FILE3}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE3}"
  fi

  if [ -n "${DELETE_FILE4}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE4}"
  fi

  if [ -n "${DELETE_FILE5}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE5}"
  fi

  if [ -n "${DELETE_FILE6}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE6}"
  fi

  if [ -n "${DELETE_FILE7}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE7}"
  fi

  if [ -n "${DELETE_FILE8}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE8}"
  fi

  if [ -n "${DELETE_FILE9}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE9}"
  fi

  if [ -n "${DELETE_FILE10}" ]; then
    rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${DELETE_FILE10}"
  fi
}

write_config() {
  {
    echo "rpcuser=${WALLET_PREFIX}rpc${INSTALL_NUM}"
    echo "rpcpassword=$(pwgen -s 32 1)"
    echo "rpcallowip=127.0.0.1"
    echo "rpcport=$(( $DEFAULT_RPC_PORT - 1 + $INSTALL_NUM ))"
    echo "port=${PORT_NUMBER}"
    echo "listen=1"
    echo "server=1"
    echo "daemon=1"
    echo "externalip=${CONFIG_ADDRESS}"

    # Check if the ip address can be bound to the wallet
    if [ -n "$({ ip -${NET_TYPE} addr | grep -i "${WAN_IP}"; })" ]; then
      # Bind this address to the wallet
      echo "bind=${CONFIG_ADDRESS}"
    fi

    # Check if there is a genkey value yet
    if [ -n "$NULLGENKEY" ]; then
      # Write the masternode config section only after a genkey value is present
      echo "masternode=1"
      echo "masternodeaddr=${CONFIG_ADDRESS}"
      echo "masternodeprivkey=$NULLGENKEY"
    fi
  } > ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME}
}

wait_wallet_loaded() {
  CURRENT_BLOCKS=""
  PERIOD=".  "

  # Wait for the wallet to fully load (getblockcount will return an error instead of a numeric block value until loaded)
  while ! (echo ${CURRENT_BLOCKS} | egrep -q '^[0-9]+$'); do
    sleep 1 &
    printf "\rWaiting for wallet to load%s" "${PERIOD}"
    CURRENT_BLOCKS=$("${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}-cli" -datadir="${USER_HOME_DIR}/${DATA_INSTALL_DIR}" getblockcount) >/dev/null 2>&1

    case $PERIOD in
      ".  ") PERIOD=".. "
         ;;
      ".. ") PERIOD="..."
         ;;
      *) PERIOD=".  " ;;
    esac && wait
  done
  printf "\rWallet loaded successfully   "
}

online_wallet_check() {
  echo && echo "${CYAN}#####${NONE} Check for wallet update ${CYAN}#####${NONE}" && echo
  # Get releases from github into a variable
  WALLET_RELEASES=$({ curl -sL "${RELEASES_URL}?$(date +%s)" | awk -F"," -v k="tag_name" '{
    gsub(/{|}/,"")
    for(i=1;i<=NF;i++){
      if ( $i ~ k ){
        print $i;
      }
    }
  }'; });
  # Count the number of releases
  s=$WALLET_RELEASES COUNTER=0
  until
    t=${s#*"tag_name"}
    [ "$t" = "$s" ]
  do
    COUNTER=$((COUNTER + 1))
    s=$t
  done
  # Check if there is more than one release
  if [ ${COUNTER} -gt 1 ]; then
    # Get the github releases json source
    NEW_WALLET_VERSION=$({ curl -sL "${RELEASES_URL}?$(date +%s)" | awk -F"," -v k="tag_name" '{
      gsub(/{|}/,"")
      for(i=1;i<=NF;i++){
        if ( $i ~ k ){
          print $i;
          exit;
        }
      }
    }'; });
    # Remove field header
    NEW_WALLET_VERSION=$({ str_replace "${NEW_WALLET_VERSION}" '"tag_name":' ""; });
    # Remove surrounding quotes
    NEW_WALLET_VERSION=$({ str_replace "${NEW_WALLET_VERSION}" '"' ""; });

    # Check if the wallet version # is blank or a very long string as that would usually indicate a problem
    if [ "${#NEW_WALLET_VERSION}" -gt 0 ] && [ "${#NEW_WALLET_VERSION}" -lt 16 ]; then
      if begins_with "v" "${NEW_WALLET_VERSION}"; then
        # Remove the 'v' from the beginning of the version string
        NEW_WALLET_VERSION=$(echo "${NEW_WALLET_VERSION}" | cut -c2-${#NEW_WALLET_VERSION})
      fi

      if [ "${WALLET_VERSION}" != "${NEW_WALLET_VERSION}" ]; then
        # A new version of the wallet is available
        echo "${CYAN}Current wallet:${NONE}  v${WALLET_VERSION}"
        echo "${CYAN}New wallet:${NONE}   v${NEW_WALLET_VERSION}"
      else
        echo "No new update found"
      fi

      # Update the wallet version with the version # found online
      WALLET_VERSION="${NEW_WALLET_VERSION}"
    else
      echo "No new update found"
    fi
  else
    # Only one release so there cannot be an updated version
    echo "No new update found"
  fi
}

unregisterIPAddress() {
  # Dynamically populate the config name based on the argument passed to the function
  IP_CONFIG_NAME="$(eval echo \$IP${1}_CONFIG_NAME)"

  # Check if the config file exists
  if [ -f ${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP_CONFIG_NAME} ]; then
    # Check if the node was previously bound to a specific network interface
    if [ -f ${HOME_DIR}/${WALLET_INSTALL_DIR}/${NET_INTERFACE_CONFIG_NAME} ]; then
      # Remember the old network interface name
      OLD_NET_INTERFACE="$(cat "${HOME_DIR}/${WALLET_INSTALL_DIR}/${NET_INTERFACE_CONFIG_NAME}")"
    else
      # Use the current network interface
      OLD_NET_INTERFACE="${NET_INTERFACE}"
    fi

    # Unregister previous IP address
     eval "unregisterIP${1}Address $(cat "${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP_CONFIG_NAME}") "${OLD_NET_INTERFACE}""
    # Remove the config file
    rm -f "${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP_CONFIG_NAME}"
  fi

  # Destroy the IP_CONFIG_NAME variable as it is no longer needed
  unset -v IP_CONFIG_NAME
}

unregisterIP4Address() {
  ip -4 addr del "${1}/23" dev ${2} >/dev/null 2>&1
}

unregisterIP6Address() {
  ip -6 addr del "${1}/64" dev ${2} >/dev/null 2>&1
}

removeWalletLinks() {
  rm -f "${HOME_DIR}/${WALLET_PREFIX}d${INSTALL_SUFFIX}"
  rm -f "${HOME_DIR}/${WALLET_PREFIX}-cli${INSTALL_SUFFIX}"
}

rpc_command() {
  WALLET_CLOSED=0
  # Check for installed wallets
  i=1; while [ $i -le 99 ]; do
    case $i in
      1) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}" ;;
      *) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}${i}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}${i}" ;;
    esac

    if [ -d "${HOME_DIR}/${WALLET_DIR_TEST}" ]; then
      # Found an installed wallet
      # Check if the wallet is currently running
      if [ -f "${HOME_DIR}/${WALLET_DIR_TEST}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${WALLET_DIR_TEST}/${WALLET_PREFIX}d" 2> /dev/null)" ]; then
        # Wallet is running
        # Add space if a wallet was already closed
        if [ $WALLET_CLOSED -eq 0 ]; then
          echo
        fi
        # Display info msg
        echo "${CYAN}#####${NONE} Wallet #${i} Response: ${CYAN}#####${NONE}" && echo
        # Issue rpc command
        ${HOME_DIR}/${WALLET_DIR_TEST}/${WALLET_PREFIX}-cli -datadir=${USER_HOME_DIR}/${DATA_DIR_TEST} ${1}
        # Keep track of wallet being closed
        echo && WALLET_CLOSED=1
      fi
    fi

    i=$(( i + 1 ))
  done

  # Check if any wallets were closed
  if [ $WALLET_CLOSED -eq 0 ]; then
    echo && echo "${GREEN}#####${NONE} No wallets are currently running ${GREEN}#####${NONE}" && echo
  fi
}

stop_all() {
  WALLET_CLOSED=0
  # Check for installed wallets
  i=1; while [ $i -le 99 ]; do
    case $i in
      1) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}" ;;
      *) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}${i}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}${i}" ;;
    esac

    if [ -d "${HOME_DIR}/${WALLET_DIR_TEST}" ]; then
      # Found an installed wallet
      # Check if the wallet is currently running and stop it if running
      if [ -f "${HOME_DIR}/${WALLET_DIR_TEST}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${WALLET_DIR_TEST}/${WALLET_PREFIX}d" 2> /dev/null)" ]; then
        # Wallet is running
        # Add space if a wallet was already closed
        if [ $WALLET_CLOSED -eq 0 ]; then
          echo
        fi
        # Issue stop command
        echo "${CYAN}#####${NONE} Closing wallet #${i} ${CYAN}#####${NONE}"
        echo && check_stop_wallet "${WALLET_DIR_TEST}" "${DATA_DIR_TEST}" && echo
        # Keep track of wallet being closed
        WALLET_CLOSED=1
      fi
    fi

    i=$(( i + 1 ))
  done

  # Check if any wallets were closed
  if [ $WALLET_CLOSED -eq 1 ]; then
    echo "${GREEN}#####${NONE} All wallets have been shut down ${GREEN}#####${NONE}"
  else
    echo && echo "${GREEN}#####${NONE} No wallets are currently running ${GREEN}#####${NONE}"
  fi
  echo
}

# TODO: Remove this function in the near future
remove_rc_local() {
  # Check if the rc.local file exists
  if [ -f ${RC_LOCAL} ]; then
    # Remove the reboot script line for the current wallet from the rc.local file
    grep -v "${HOME_DIR}/${WALLET_INSTALL_DIR}/${REBOOT_SCRIPT_NAME}" ${RC_LOCAL} > ${RC_LOCAL}.new; mv ${RC_LOCAL}.new ${RC_LOCAL}
  fi
}

add_cron_job() {
  crontab -l | { cat; echo "@reboot sleep 30; ${HOME_DIR}/${WALLET_INSTALL_DIR}/${REBOOT_SCRIPT_NAME} "\""${CURRENT_USER}"\"" & # AUTOMATICALLY ADDED VIA exor-mn-installer.sh DO NOT REMOVE OR CHANGE MANUALLY"; } | crontab -
}

get_shutdown_service_filename() {
  echo "${WALLET_PREFIX}${INSTALL_SUFFIX}_shutdown"
}

# Check linux distribution
LINUX_VERSION=$(cat /etc/issue.net)
if ! contains "Ubuntu" "$LINUX_VERSION" && ! contains "Debian" "$LINUX_VERSION"; then
  echo && echo "Your linux distribution: ${ORANGE}$LINUX_VERSION${NONE}"
  echo "This script has been designed to run on ${GREEN}Ubuntu 16.04+${NONE} and ${GREEN}Debian 8.x+${NONE}."
  echo "Would you like to continue installing anyway? [y/n]: ";
  read -p "" INSTALL_ANSWER

  case "$INSTALL_ANSWER" in
    y|Y|yes|Yes|YES) ;;
    *) exit ;;
  esac
fi

# Fix the current user and home directory variables in the event that $SUDO_USER is blank (installing as root)
if [ -z "${CURRENT_USER}" ]; then
  CURRENT_USER="$(whoami)"
  USER_HOME_DIR="$(awk -F: -v v="${CURRENT_USER}" '{if ($1==v) print $6}' /etc/passwd)"
fi

# Read command line arguments
if ! ARGS=$(getopt -o "ht:w:g:N:i:p:n:a:r:R:sfbcuSU" -l "help,type:,wallet:,genkey:,net:,ip:,port:,number:,adapter:,reindex:,rpcall:,noswap,nofirewall,nobruteprotect,nochainsync,noosupgrade,stopall,updateall" -n "${0##*/}" -- "$@"); then
  # invalid command line arguments so show help menu
  help_menu
  exit;
fi

eval set -- "$ARGS";

while true; do
  case "$1" in
    -h|--help)
      shift;
      help_menu;
      exit
      ;;
    -t|--type)
      shift;
      if [ -n "$1" ]; then
        INSTALL_TYPE="$1";
        shift;
      fi
      ;;
    -w|--wallet)
      shift;
      if [ -n "$1" ]; then
        WALLET_TYPE="$1";
        shift;
      fi
      ;;
    -g|--genkey)
      shift;
      if [ -n "$1" ]; then
        NULLGENKEY="$1";
        shift;
      fi
      ;;
    -N|--net)
      shift;
      if [ -n "$1" ]; then
        INITIAL_NET_TYPE="$1";
        shift;
      fi
      ;;
    -i|--ip)
      shift;
      if [ -n "$1" ]; then
        WAN_IP="$1";
        shift;
      fi
      ;;
    -p|--port)
      shift;
      if [ -n "$1" ]; then
        PORT_NUMBER_ARG="$1";
        shift;
      fi
      ;;
    -n|--number)
      shift;
      if [ -n "$1" ]; then
        INSTALL_NUM="$1";
        shift;
      fi
      ;;
    -a|--adapter)
      shift;
      if [ -n "$1" ]; then
        NET_INTERFACE="$1";
        shift;
      fi
      ;;
    -s|--noswap)
      shift;
      SWAP="0";
      ;;
    -f|--nofirewall)
      shift;
      FIREWALL="0";
      ;;
    -b|--nobruteprotect)
      shift;
      FAIL2BAN="0";
      ;;
    -c|--nochainsync)
      shift;
      SYNCCHAIN="0";
      ;;
    -u|--noosupgrade)
      shift;
      OSUPGRADE="0";
      ;;
    -r|--reindex)
      shift;
      if [ -n "$1" ]; then
        REINDEX="$1";
      else
        REINDEX="r";
      fi
      shift;
      ;;
    -R|--rpcall)
      shift;
      if [ -n "$1" ]; then
        rpc_command "$1"
        exit
      fi
      ;;
    -S|--stopall)
      shift;
      stop_all;
      exit
      ;;
    -U|--updateall)
      shift;
      # Check if the temp update config file exists
      if [ -f ${TEMP_UPDATE_CONFIG_PATH} ]; then
        # Read the contents of the config file
        UPDATE_INDEX=$(cat "${TEMP_UPDATE_CONFIG_PATH}")
        # Delete the temp update config file
        rm -f "${TEMP_UPDATE_CONFIG_PATH}"
      else
        # Config file not found, so start with index 1
        UPDATE_INDEX=1
      fi
      ;;
    --)
      shift;
      break;
      ;;
  esac
done

# Verify that user has root
if [ "$(whoami)" != "root" ]; then
  echo && error_message "${ORANGE}Root${NONE} privileges not detected. This script must be run using the keyword '${CYAN}sudo${NONE}' to enable ${ORANGE}root${NONE} user"
fi

# Ensure commands are executed from the users home directory
eval "cd ${USER_HOME_DIR}"

# Check and fix updateall install argument if necessary
if [ -n "$UPDATE_INDEX" ] && [ ${UPDATE_INDEX} -ne 0 ] && [ -n "$(validate_install_num $UPDATE_INDEX)" ]; then
  # Invalid update index specified, but do not stop. Instead, continue with install #1
  UPDATE_INDEX=1
fi

# Check if running an updateall install
if [ -n "$UPDATE_INDEX" ] && [ ${UPDATE_INDEX} -ne 0 ]; then
  # Find the next installed wallet, starting from the update index
  i=${UPDATE_INDEX}; while [ $i -le 99 ]; do
    case $i in
      1) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}" ;;
      *) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}${i}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}${i}" ;;
    esac

    if [ -d "${HOME_DIR}/${WALLET_DIR_TEST}" ] && [ -f "${USER_HOME_DIR}/${DATA_DIR_TEST}/${WALLET_CONFIG_NAME}" ]; then
      # Set the update index
      UPDATE_INDEX=${i}
      # Return from loop
      break
    fi

    i=$(( i + 1 ))
  done

  # Check if a wallet install was found
  if [ ${i} -gt 99 ]; then
    # No wallets found
    echo && error_message "No installed wallets found"
  else
    # Update the install number based on the update index
    INSTALL_NUM="${UPDATE_INDEX}"
    # Check if this is the 1st/default wallet
    if [ ${UPDATE_INDEX} -eq 1 ]; then
      # Always do an os upgrade on the 1st/default wallet update
      OSUPGRADE=1
    else
      # Skip o/s upgrade for all other wallet updates
      OSUPGRADE=0
    fi
    # Prevent from re-creating the swap file
    SWAP=0
    # Prevent from re-installing the firewall
    FIREWALL=0
    # Prevent from re-installing brute-force protection
    FAIL2BAN=0
    # Prevent from waiting for the chain to fully sync
    SYNCCHAIN=0
  fi
fi

# Set install suffix
if [ "$INSTALL_NUM" -eq 1 ]; then
  # 1st/default wallet has no suffix
  INSTALL_SUFFIX=""
else
  # All other wallets have a suffix of the Install #
  INSTALL_SUFFIX="${INSTALL_NUM}"
fi

# Set install directories
DATA_INSTALL_DIR="${DEFAULT_DATA_DIR}${INSTALL_SUFFIX}"
WALLET_INSTALL_DIR="${DEFAULT_WALLET_DIR}${INSTALL_SUFFIX}"

# Validate command line arguments
if [ -n "${INITIAL_NET_TYPE}" ]; then
  NET_TYPE="${INITIAL_NET_TYPE}"
fi

case $NET_TYPE in
  4) ;;
  6) ;;
  *) echo && error_message "Invalid ip address type" ;;
esac

case $INSTALL_TYPE in
  [iI]) INSTALL_TYPE="Install" ;;
  [uU]) INSTALL_TYPE="Uninstall" ;;
  *) echo && error_message "Invalid install type" ;;
esac

if [ "$INSTALL_TYPE" = "Install" ]; then
  if [ -f ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME} ]; then
    # Update install
    if [ -z "$NULLGENKEY" ]; then
      # Read the genkey value from the config file
      NULLGENKEY=$(grep "masternodeprivkey" ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME} | sed -e "s/masternodeprivkey=//g")
    fi

    # Read network interface information
    if [ -z "$NET_INTERFACE" ] && [ -f ${HOME_DIR}/${WALLET_INSTALL_DIR}/${NET_INTERFACE_CONFIG_NAME} ]; then
      # Remember network interface from last install
      NET_INTERFACE=$(cat "${HOME_DIR}/${WALLET_INSTALL_DIR}/${NET_INTERFACE_CONFIG_NAME}")
    fi

    # Read ip address information
    if [ -f ${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP4_CONFIG_NAME} ]; then
      # Previous install was IPv4, check to see if it should still be IPv4
      if [ -z "${WAN_IP}" ] && ([ -z "${INITIAL_NET_TYPE}" ] || [ "$INITIAL_NET_TYPE" -eq 4 ]); then
        # Ensure that the IPv4 config file is re-created
        WRITE_IP4_CONF=1
        # Set install to IPv4
        NET_TYPE=4
        # Remember IPv4 address from last install
        WAN_IP=$(cat "${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP4_CONFIG_NAME}")
      fi

      # Initialize network variables
      init_network
    fi

    if [ -f ${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP6_CONFIG_NAME} ]; then
      # Previous install was IPv6, check to see if it should still be IPv6
      if [ -z "${WAN_IP}" ] && ([ -z "${INITIAL_NET_TYPE}" ] || [ "$INITIAL_NET_TYPE" -eq 6 ]); then
        # Ensure that the IPv6 config file is re-created
        WRITE_IP6_CONF=1
        # Set install to IPv6
        NET_TYPE=6
        # Remember IPv6 address from last install
        TEMP_WAN_IP=$(cat "${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP6_CONFIG_NAME}")
        # Ensure that the IPv6 address is valid
        if [ -z "$(validate_ip6address ${TEMP_WAN_IP})" ]; then
          WAN_IP="${TEMP_WAN_IP}"
        fi
      fi

      # Initialize network variables
      init_network
    fi

    if [ -z "${WAN_IP}" ] && [ -z "${INITIAL_NET_TYPE}" ]; then
      # Read the ip address value from the config file
      WAN_IP=$(grep "masternodeaddr" ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME} | sed -e "s/masternodeaddr=//g")
      # Check if the WAN IP is blank
      if [ -n "$WAN_IP" ]; then
        # Check if this is an IPv6 or IPv4 address
        if begins_with "[" "${WAN_IP}"; then
          # Strip the []'s and port from this IPv6 address
          WAN_IP=$(echo "${WAN_IP}" | cut -c2-$({ echo "${#WAN_IP} - $(printf "%s" "$(echo "${WAN_IP}" | rev | cut -d "]" -f1 | rev)" | wc -c)" | awk '{print $1 - $3 - 1}'; }))
          NET_TYPE=6
        else
          # Strip the port from this IPv4 address
          WAN_IP=$(echo "${WAN_IP}" | cut -c1-$({ echo "${#WAN_IP} - $(printf "%s" "$(echo "${WAN_IP}" | rev | cut -d ":" -f1 | rev)" | wc -c)" | awk '{print $1 - $3 - 1}'; }))
          NET_TYPE=4
        fi
      fi
    fi

    if [ -z "$PORT_NUMBER_ARG" ]; then
      # Read the port value from the config file
      PORT_NUMBER=$(grep "^port=" ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME} | sed -e "s/port=//g")
      # Check if port number was read correctly
      if [ -z "$PORT_NUMBER" ]; then
        # Port cannot be read. Revert back to default port
        PORT_NUMBER=`expr $DEFAULT_PORT_NUMBER - 1`
      fi
    fi
  fi

  case $WALLET_TYPE in
    [dD]) WALLET_TYPE="d" ;;
    [bB]) WALLET_TYPE="b" ;;
    *) echo && error_message "Invalid wallet type" ;;
  esac

  if [ -n "$NULLGENKEY" ] && [ -n "$(validate_genkey $NULLGENKEY)" ]; then
    echo && error_message "Invalid masternode genkey value"
  fi

  if [ -n "${REINDEX}" ] && [ "${REINDEX}" != "r" ] && [ "${REINDEX}" != "c" ] && [ "${REINDEX}" != "s" ]; then
    echo && error_message "Invalid reindex value"
  fi

  if [ "$NET_TYPE" -eq 6 ]; then
    # Setup IPv6 support before validating ip address
    init_ipv6
  else
    # Initialize network variables
    init_network
  fi

  if [ -n "$WAN_IP" ] && (([ "$NET_TYPE" -eq 4 ] && [ -n "$(validate_ip4address $WAN_IP)" ]) || ([ "$NET_TYPE" -eq 6 ] && [ -n "$(validate_ip6address $WAN_IP)" ])); then
    echo && error_message "Invalid ip address"
  fi

  if [ -n "$PORT_NUMBER_ARG" ]; then
    if [ -n "$(validate_port $PORT_NUMBER_ARG)" ]; then
      echo && error_message "Invalid port #"
    else
      PORT_NUMBER=$PORT_NUMBER_ARG
    fi
  else
    PORT_NUMBER=$(( $PORT_NUMBER + $INSTALL_NUM ))
  fi
fi

if [ -n "$INSTALL_NUM" ] && [ -n "$(validate_install_num $INSTALL_NUM)" ]; then
  echo && error_message "Invalid install #"
fi

# Get the current user id for later
readonly CURRENT_USER_ID=$(execute_command "id -ur")
# Welcome
welcome_screen
# Check if running an updateall install
if [ -z "${UPDATE_INDEX}" ] || [ ${UPDATE_INDEX} -eq 0 ]; then
  # Not an updateall install
  # Show default install title
  echo && echo "${GREY}///////////////////////////////////////////////////////${NONE}"
  # Center-align the title
  i=1; while [ "$i" -le "$(((55-$(printf "%s" "${TITLE_STRING}" | wc -m))/2))" ]; do
    echo -n " "
    i=$(($i+1))
  done
  echo -n "${TITLE_STRING}"
  echo && echo "${GREY}///////////////////////////////////////////////////////${NONE}"
else
  # This is an updateall install
  # Check if this is the first/default wallet
  if [ ${UPDATE_INDEX} -eq 1 ]; then
    # Add an extra blank line
    echo
  fi
  # Show updateall install title
  NEW_TITLE_STRING="Update wallet #${UPDATE_INDEX}"
  echo "${GREY}///////////////////////////////////////////////////////${NONE}"
  # Center-align the title
  i=1; while [ "$i" -le "$(((55-$(printf "%s" "${NEW_TITLE_STRING}" | wc -m))/2))" ]; do
    echo -n " "
    i=$(($i+1))
  done
  echo -n "${NEW_TITLE_STRING}"
  echo && echo "${GREY}///////////////////////////////////////////////////////${NONE}"
fi
# Wait 2 seconds with the splash screen up before starting
sleep 2 && echo
# Check if curl is installed
if [ "$({ dpkg-query --show --showformat='${db:Status-Status}\n' 'curl'; })" = "not-installed" ]; then
  # Install curl
  install_package "curl" "curl (required for script usage)"
fi
# Check if running an updateall install
if [ -z "${UPDATE_INDEX}" ] || [ ${UPDATE_INDEX} -eq 0 ] || [ ${UPDATE_INDEX} -eq 1 ]; then
  # Check for an updated version of the script
  echo "${CYAN}#####${NONE} Check for script update ${CYAN}#####${NONE}" && echo
  NEWEST_VERSION=$(curl -s -k "${VERSION_URL}?$(date +%s)")
  VERSION_LENGTH=$(printf "%s" "${NEWEST_VERSION}" | wc -m)

  if [ ${VERSION_LENGTH} -gt 0 ] && [ ${VERSION_LENGTH} -lt 10 ]; then
    # Split current script version
    TEMP_VERSION="${SCRIPT_VERSION}"
    CURRENT_BUILD_VERSION=$({ echo "${TEMP_VERSION}" | awk -v FS="." '{ print $NF }'; })
    TEMP_VERSION=$(echo "${TEMP_VERSION}" | cut -c1-`expr ${#TEMP_VERSION} - ${#CURRENT_BUILD_VERSION} - 1` | head -1)
    CURRENT_MINOR_VERSION=$({ echo "${TEMP_VERSION}" | awk -v FS="." '{ print $NF }'; })
    CURRENT_MAJOR_VERSION=$(echo "${TEMP_VERSION}" | cut -c1-`expr ${#TEMP_VERSION} - ${#CURRENT_MINOR_VERSION} - 1` | head -1)
    # Split new script version
    TEMP_VERSION="${NEWEST_VERSION}"
    NEWEST_BUILD_VERSION=$({ echo "${TEMP_VERSION}" | awk -v FS="." '{ print $NF }'; })
    TEMP_VERSION=$(echo "${TEMP_VERSION}" | cut -c1-`expr ${#TEMP_VERSION} - ${#NEWEST_BUILD_VERSION} - 1` | head -1)
    NEWEST_MINOR_VERSION=$({ echo "${TEMP_VERSION}" | awk -v FS="." '{ print $NF }'; })
    NEWEST_MAJOR_VERSION=$(echo "${TEMP_VERSION}" | cut -c1-`expr ${#TEMP_VERSION} - ${#NEWEST_MINOR_VERSION} - 1` | head -1)

    if [ "${NEWEST_MAJOR_VERSION}" -gt "${CURRENT_MAJOR_VERSION}" ] || ([ "${NEWEST_MAJOR_VERSION}" -eq "${CURRENT_MAJOR_VERSION}" ] && ([ "${NEWEST_MINOR_VERSION}" -gt "${CURRENT_MINOR_VERSION}" ] || ([ "${NEWEST_MINOR_VERSION}" -eq "${CURRENT_MINOR_VERSION}" ] && [ "${NEWEST_BUILD_VERSION}" -gt "${CURRENT_BUILD_VERSION}" ]))); then
      # A new version of the script is available
      echo "${CYAN}Current script:${NONE}  v${SCRIPT_VERSION}"
      echo "${CYAN}New script:${NONE}   v${NEWEST_VERSION}"
      echo && echo "${CYAN}CHANGES:${NONE}"
      echo "$(curl -s -k "${NEW_CHANGES_URL}?$(date +%s)")"
      echo && echo -n "Would you like to update now? [y/n]: "
      read -p "" UPDATE_NOW
      case "$UPDATE_NOW" in
        y|Y|yes|Yes|YES)
          # Update to newest version of script
          echo "Updating, please wait..."
          # Overwrite the current script with the newest version
          {
            echo "$(curl -s -k "${SCRIPT_URL}?$(date +%s)")"
          } > ${USER_HOME_DIR}/${0##*/}
          # Ensure script is executable
          chmod +x ${USER_HOME_DIR}/${0##*/}
          # Fix parameters before restarting
          case $INSTALL_TYPE in
            "Install") INSTALL_TYPE="i" ;;
            *) INSTALL_TYPE="u" ;;
          esac
          if [ -n "$NULLGENKEY" ]; then
            NULLGENKEY=" -g ${NULLGENKEY}"
          fi
          if [ -n "$WAN_IP" ]; then
            WAN_IP=" -i ${WAN_IP}"
          fi
          if [ -n "$PORT_NUMBER" ]; then
            PORT_NUMBER=" -p ${PORT_NUMBER}"
          fi
          if [ -z "$NET_INTERFACE" ]; then
            init_network
          fi
          NET_INTERFACE=" -a ${NET_INTERFACE}"
          if [ "$SWAP" -eq 0 ]; then
            SWAP=" -s"
          else
            SWAP=""
          fi
          if [ "$FIREWALL" -eq 0 ]; then
            FIREWALL=" -f"
          else
            FIREWALL=""
          fi
          if [ "$FAIL2BAN" -eq 0 ]; then
            FAIL2BAN=" -b"
          else
            FAIL2BAN=""
          fi
          if [ "$SYNCCHAIN" -eq 0 ]; then
            SYNCCHAIN=" -c"
          else
            SYNCCHAIN=""
          fi
          if [ "$OSUPGRADE" -eq 0 ]; then
            OSUPGRADE=" -u"
          else
            OSUPGRADE=""
          fi
          if [ -z "${UPDATE_INDEX}" ] || [ ${UPDATE_INDEX} -eq 0 ]; then
            UPDATE_INDEX=""
          else
            UPDATE_INDEX=" -U"
          fi
          # Restart the newest version of the script
          eval "sh ${USER_HOME_DIR}/${0##*/} -t ${INSTALL_TYPE} -w ${WALLET_TYPE}${NULLGENKEY} -N ${NET_TYPE}${WAN_IP}${PORT_NUMBER}${NET_INTERFACE} -n ${INSTALL_NUM}${SWAP}${FIREWALL}${FAIL2BAN}${SYNCCHAIN}${OSUPGRADE}${UPDATE_INDEX}"
          exit
          ;;
      esac
    else
      echo "No new update found"
    fi
  else
    echo "No new update found"
  fi

  # Check online for the most recent wallet version
  online_wallet_check && echo
fi

# Set the wallet archive filename based on the template
WALLET_FILE=$({ str_replace "$({ str_replace "${WALLET_FILE_TEMPLATE}" "\${WALLET_PREFIX}" "${WALLET_PREFIX}"; })" "\${WALLET_VERSION}" "${WALLET_VERSION}"; });

if [ "${ARCHIVE_DIR_TEMPLATE}" != "" ]; then
  TEMP_WALLET_VERSION="${WALLET_VERSION}"

  if [ $(count_occurances "${TEMP_WALLET_VERSION}" "\.") -eq 3 ]; then
    # Remove the last version number as it isn't being used in the wallet build currently
    TEMP_WALLET_VERSION="${TEMP_WALLET_VERSION%\.*}"
  fi

  # Set the archive directory based on the template
  ARCHIVE_DIR=$({ str_replace "$({ str_replace "${ARCHIVE_DIR_TEMPLATE}" "\${WALLET_PREFIX}" "${WALLET_PREFIX}"; })" "\${WALLET_VERSION}" "${TEMP_WALLET_VERSION}"; });
fi

# Get IP Address (if not already specified via command line)
if [ -z "$WAN_IP" ]; then
  if [ "$NET_TYPE" -eq 4 ]; then
    # Get the default external IPv4 ip address
    WAN_IP=$(curl -s -k http://icanhazip.com --ipv4)
  else
    # Build the IPv6 ip address
    WAN_IP="${IPV6_INT_BASE}:${NETWORK_BASE_TAG}::${INSTALL_NUM}"
  fi
fi

if [ "$INSTALL_TYPE" = "Install" ] && [ "${WALLET_TYPE}" = "d" ] && [ -n "${WALLET_URL_TEMPLATE}" ]; then
  # Ensure the wallet download url is valid
  HTTP_CODE=$(curl -w %{http_code} -s --output /dev/null "$({ str_replace "${WALLET_URL_TEMPLATE}" "\${WALLET_VERSION}" "${WALLET_VERSION}"; })${WALLET_FILE}")
  if [ "$HTTP_CODE" -eq 404 ]; then
    # Check the same download url with a letter 'v' in front of the version
    HTTP_CODE=$(curl -w %{http_code} -s --output /dev/null "$({ str_replace "${WALLET_URL_TEMPLATE}" "\${WALLET_VERSION}" "v${WALLET_VERSION}"; })${WALLET_FILE}")
  fi
fi

echo "${ULINE}${CYAN}${INSTALL_TYPE} Settings:${NONE}" && echo

if [ "$INSTALL_TYPE" = "Install" ]; then
  echo "${CYAN}New Wallet Version:${NONE}     v$WALLET_VERSION"

  if [ -f ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME} ]; then
    echo "${CYAN}Install Type:${NONE}           UPDATE"
  else
    echo "${CYAN}Install Type:${NONE}           NEW INSTALL"
  fi

  if [ "${WALLET_TYPE}" = "b" ]; then
    echo "${CYAN}Wallet Type:${NONE}            Build from source"
  elif [ "${WALLET_TYPE}" = "d" ] && [ -n "${WALLET_URL_TEMPLATE}" ] && ([ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 302 ]); then
    echo "${CYAN}Wallet Type:${NONE}            Download"
  else
    WALLET_TYPE="b"
    echo "${CYAN}Wallet Type:${NONE}            ${ORANGE}Build from source (Download not available)${NONE}"
  fi

  if [ -n "$NULLGENKEY" ]; then
    echo "${CYAN}Genkey Value:${NONE}           $NULLGENKEY"
  else
    echo "${CYAN}Genkey Value:${NONE}           <Autogenerate during install>"
  fi

  echo "${CYAN}IP Address:${NONE}             $WAN_IP"
  echo "${CYAN}Port #:${NONE}                 $PORT_NUMBER"
  echo "${CYAN}Network Interface:${NONE}      ${NET_INTERFACE}"
  echo "${CYAN}Install Directory:${NONE}      ${HOME_DIR}/${WALLET_INSTALL_DIR}"

  if [ "$SWAP" -eq 0 ]; then
    echo "${CYAN}Disk Swap:${NONE}              ${ORANGE}No${NONE}"
  else
    echo "${CYAN}Disk Swap:${NONE}              Yes"
  fi

  if [ "$FIREWALL" -eq 0 ]; then
    echo "${CYAN}Firewall:${NONE}               ${ORANGE}No${NONE}"
  else
    echo "${CYAN}Firewall:${NONE}               Yes"
  fi

  if [ "$FAIL2BAN" -eq 0 ]; then
    echo "${CYAN}Brute-Force Protection:${NONE} ${ORANGE}No${NONE}"
  else
    echo "${CYAN}Brute-Force Protection:${NONE} Yes"
  fi

  if [ "$BLOCKCOUNT_URL" = "" ]; then
    echo "${CYAN}Blockchain Sync:${NONE}        ${ORANGE}No (Block explorer not found)${NONE}"
  else
    if [ "$SYNCCHAIN" -eq 0 ]; then
      echo "${CYAN}Blockchain Sync:${NONE}        ${ORANGE}No${NONE}"
    else
      echo "${CYAN}Blockchain Sync:${NONE}        Yes"
    fi
  fi

  if [ "$OSUPGRADE" -eq 0 ]; then
    echo "${CYAN}O/S Upgrade:${NONE}            ${ORANGE}No${NONE}"
  else
    echo "${CYAN}O/S Upgrade:${NONE}            Yes"
  fi

  # Wait for timeout
  echo
  while [ $WAIT_TIMEOUT -gt 0 ]
  do
    sleep 1 &
    printf "\rInstallation will continue in: %01d..." ${WAIT_TIMEOUT}
    WAIT_TIMEOUT=`expr $WAIT_TIMEOUT - 1`
    wait
  done
  printf "\r                                      "

  if [ "$OSUPGRADE" -eq 1 ]; then
    # Update package lists, repositories and new software versions to keep the vps up-to-date
    echo && echo "${CYAN}#####${NONE} Updating package lists, repositories and new software versions ${CYAN}#####${NONE}" && echo
    apt-get update
    apt-get upgrade -y
    apt-get dist-upgrade -y
  fi

  # Add a blank line
  echo

  if [ "$SWAP" -eq 1 ]; then
    # Install and configure disk swap file
    if [ -z "$({ fallocate -l 4G /swapfile; } 2>&1)" ]; then
      echo "${CYAN}#####${NONE} Configuring disk swap file ${CYAN}#####${NONE}" && echo
      chmod 600 /swapfile
      mkswap /swapfile >/dev/null 2>&1
      swapon /swapfile
      grep -q "/swapfile none swap sw 0 0" /etc/fstab; [ $? -eq 1 ] && bash -c "echo '/swapfile none swap sw 0 0' >> /etc/fstab"
      bash -c "echo 'vm.swappiness = 10' >> /etc/sysctl.conf"
      echo "Done" && echo
    else
      echo "${ORANGE}#####${NONE} Disk swap already configured ${ORANGE}#####${NONE}" && echo
    fi
  fi

  if [ "$FIREWALL" -eq 1 ]; then
    # Install firewall
    install_package "ufw" "firewall"
    # Configure firewall
    echo "${CYAN}#####${NONE} Configure firewall ${CYAN}#####${NONE}" && echo
    ufw default allow outgoing
    ufw default deny incoming

    # Check if ssh is installed
    if [ -n "$({ ufw app list | grep -E '^' | grep OpenSSH; })" ]; then
      # Allow and limit ssh through firewall
      ufw allow OpenSSH
      ufw limit OpenSSH
    fi

    # Allow wallet port through firewall
    ufw allow ${PORT_NUMBER}
    ufw logging on
    ufw --force enable && echo
  fi

  if [ "$FAIL2BAN" -eq 1 ]; then
    # Install brute-force protection
    install_package "fail2ban" "brute-force protection"
    # Configure brute-force protection
    echo "${CYAN}#####${NONE} Configure brute-force protection ${CYAN}#####${NONE}" && echo
    systemctl enable fail2ban
    systemctl start fail2ban && echo
  fi

  # Check if the password generator has already been installed
  if [ -z "$({ dpkg -l | grep -E '^ii' | grep pwgen; })" ]; then
    # Install password generator
    install_package "pwgen" "password generator (required for wallet setup)"
  fi

  # Create wallet directory if not exists
  if [ ! -d "${HOME_DIR}/${WALLET_INSTALL_DIR}" ]; then
    mkdir "${HOME_DIR}/${WALLET_INSTALL_DIR}"
  fi

  # Attempt to unregister an old IP4 address
  unregisterIPAddress "4"
  # Attempt to unregister an old IP6 address
  unregisterIPAddress "6"

  if [ "$NET_TYPE" -eq 4 ]; then
    # IPv4 address setup
    CONFIG_ADDRESS="${WAN_IP}:${DEFAULT_PORT_NUMBER}"

    # Check if IPv4 address is already available
    if [ -z "$({ ip -4 addr | grep -i "${WAN_IP}"; })" ]; then
      # IPv4 address is not already available
      echo "${CYAN}#####${NONE} Registering public IPv4 address: ${WAN_IP} ${CYAN}#####${NONE}" && echo
      # Add public IPv4 address to the system
      ip -4 addr add "${WAN_IP}/23" dev ${NET_INTERFACE} >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        # Public ip address registered successfully
        # Remember the ip4 address for later
        WRITE_IP4_CONF=1
        sleep 2
        echo "Done" && echo
      else
        # Error while trying to create the IPv4 adddress
        error_message "Unable to create IPv4 address"
      fi
    fi

    # Check if the IPv4 address should be remembered
    if [ $WRITE_IP4_CONF -eq 1 ]; then
      # Create a small file in the wallet directory to be used for removal of ip4 address at a later time
      echo "${WAN_IP}" > ${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP4_CONFIG_NAME}
    fi
  else
    # IPv6 address setup
    CONFIG_ADDRESS="[${WAN_IP}]:${DEFAULT_PORT_NUMBER}"

    # Check if IPv6 address is already available
    if [ -z "$({ ip -6 addr | grep -i "${WAN_IP}"; })" ]; then
      # IPv6 address is not already available
      echo "${CYAN}#####${NONE} Registering new IPv6 address: ${WAN_IP} ${CYAN}#####${NONE}" && echo
      # Add new IPv6 address to the system
      ip -6 addr add "${WAN_IP}/64" dev ${NET_INTERFACE} >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        # New ip address registered successfully
        # Remember the ip6 address for later
        WRITE_IP6_CONF=1
        sleep 2
        echo "Done" && echo
      else
        # Error while trying to create the IPv6 adddress
        error_message "Unable to create IPv6 address"
      fi
    fi

    # Check if the IPv6 address should be remembered
    if [ $WRITE_IP6_CONF -eq 1 ]; then
      # Create a small file in the wallet directory to be used for removal of ip6 address at a later time
      echo "${WAN_IP}" > ${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP6_CONFIG_NAME}
    fi
  fi

  # Check if there is already a saved wallet available instead of downloading a new one again
  WALLET_BASE_DIR="${HOME_DIR}"
  i=1; while [ $i -le 99 ]; do
    case $i in
      1) DIR_TEST="${DEFAULT_WALLET_DIR}" ;;
      *) DIR_TEST="${DEFAULT_WALLET_DIR}${i}" ;;
    esac

    if [ -d "${HOME_DIR}/${DIR_TEST}" ]; then
      # Remove all old wallet backups from this install directory
      find ${HOME_DIR}/${DIR_TEST} -name "*.tar.gz" ! -name "${WALLET_FILE}" -type f -exec rm -f {} +

      # Check if this install directory has a copy of the current wallet
      if [ "$WALLET_BASE_DIR" = "${HOME_DIR}" ] && [ -d "${HOME_DIR}/${DIR_TEST}" ] && [ -f "${HOME_DIR}/${DIR_TEST}/${WALLET_FILE}" ]; then
        # Found a copy of the current wallet
        # Save wallet directory
        WALLET_BASE_DIR="${HOME_DIR}/${DIR_TEST}"
      fi
    fi

    i=$(( i + 1 ))
  done

  # Remove old links to wallet binaries
  removeWalletLinks

  if [ "$WALLET_BASE_DIR" = "${HOME_DIR}" ]; then
    if [ "$WALLET_TYPE" = "d" ]; then
      # Download wallet
      echo "${CYAN}#####${NONE} Download wallet ${CYAN}#####${NONE}" && echo
      wget -q "$({ str_replace "${WALLET_URL_TEMPLATE}" "\${WALLET_VERSION}" "${WALLET_VERSION}"; })${WALLET_FILE}" -O "${WALLET_BASE_DIR}/${WALLET_FILE}" --show-progress
      # Ensure wallet downloaded successfully
      if [ ! -f "${WALLET_BASE_DIR}/${WALLET_FILE}" ] || [ $(stat -c%s "${WALLET_BASE_DIR}/${WALLET_FILE}") -eq 0 ]; then
        # Failed to download wallet - but try again with a letter 'v' in front of the version
        wget -q "$({ str_replace "${WALLET_URL_TEMPLATE}" "\${WALLET_VERSION}" "v${WALLET_VERSION}"; })${WALLET_FILE}" -O "${WALLET_BASE_DIR}/${WALLET_FILE}" --show-progress
        if [ ! -f "${WALLET_BASE_DIR}/${WALLET_FILE}" ] || [ $(stat -c%s "${WALLET_BASE_DIR}/${WALLET_FILE}") -eq 0 ]; then
          error_message "Failed to download wallet"
        fi
      fi
      echo
      # Extract wallet files from downloaded archive
      extract_wallet_files
    else
      BUILD_SOURCE=0
      INSTALL_DEPENDENCIES=0
      # Check if the source directory already exists
      if [ -d "${SOURCE_DIR}" ]; then
        # Update the git repository
        echo "${CYAN}#####${NONE} Updating local wallet source code ${CYAN}#####${NONE}" && echo
        # Change directory into existing repo
        eval "cd ${SOURCE_DIR}"
        # Pull the newest updates
        exec 5>&1 && SOME_TEST=$(git pull 2>&1 | tee /dev/fd/5;)
        # Check if the repo is already up to date
        if [ "${SOME_TEST}" != "Already up-to-date." ]; then
          INSTALL_DEPENDENCIES=1
        fi
        # Check if there is a make file
        if [ ! -f "${USER_HOME_DIR}/${SOURCE_DIR}/Makefile" ]; then
          # Make file is missing = need to rebuild the entire source
          INSTALL_DEPENDENCIES=1
          BUILD_SOURCE=1
        fi
      else
        # Source directory does not exist
        INSTALL_DEPENDENCIES=1
        BUILD_SOURCE=1
      fi

      if [ "${INSTALL_DEPENDENCIES}" -eq 1 ]; then
        # Install wallet source and all dependencies
        # Update package lists and repositories
        echo "${CYAN}#####${NONE} Updating package lists and repositories ${CYAN}#####${NONE}" && echo
        apt-get update && echo
        # Install build dependencies
        install_package "automake" "automake"
        install_package "build-essential" "build-essential"
        install_package "libtool" "libtool"
        install_package "autotools-dev" "autotools-dev"
        install_package "git" "git"
        install_package "curl" "curl"
        install_package "pkg-config" "pkg-config"
      fi

      if [ "${BUILD_SOURCE}" -eq 1 ]; then
        # Remember current directory
        CURRENT_DIR=${PWD}
        # Check if source directory exists
        if [ ! -d "${USER_HOME_DIR}/${SOURCE_DIR}" ]; then
          # Download the github repo
          echo "${CYAN}#####${NONE} Downloading source code ${CYAN}#####${NONE}" && echo
          eval "git clone ${SOURCE_URL} ${SOURCE_DIR}"
        fi
        # Change directory into "depends" directory of new repo
        eval "cd ${SOURCE_DIR}/depends"
        # Build the dependencies for 64-bit linux systems
        echo && echo "${CYAN}#####${NONE} Start build from source code ${CYAN}#####${NONE}" && echo
        eval "make HOST=x86_64-linux-gnu NO_QT=1"
        # Change directory into root of new repo
        eval "cd .."
        # Build wallet from source code
        eval "./autogen.sh"
        eval "./configure --prefix=${USER_HOME_DIR}/${SOURCE_DIR}/depends/x86_64-linux-gnu --without-gui --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests --disable-tests"
      fi

      # Make the files
      eval "make"
      echo && echo "${CYAN}#####${NONE} Finalizing build ${CYAN}#####${NONE}" && echo
      # Return to previous directory
      eval "cd ${CURRENT_DIR}"
      # Move wallet files
      find ${SOURCE_DIR} -name "${WALLET_PREFIX}d" -type f -exec strip {} \; -exec mv {} "${USER_HOME_DIR}/" \;
      find ${SOURCE_DIR} -name "${WALLET_PREFIX}-cli" -type f -exec strip {} \; -exec mv {} "${USER_HOME_DIR}/" \;
      # Change directory to the wallet install location
      eval "cd ${USER_HOME_DIR}"
      # Add wallet files to a new archive that can be used to install faster for 2+ installs
      tar -cvzf ${WALLET_FILE} ${WALLET_PREFIX}d ${WALLET_PREFIX}-cli >/dev/null 2>&1
      # Move the archive into the root wallet directory
      mv "${WALLET_FILE}" "${HOME_DIR}/${WALLET_FILE}"
      # Return to previous directory
      eval "cd ${CURRENT_DIR}"
      echo "Done" && echo
    fi
  else
    # Extract wallet files from saved archive
    extract_wallet_files
  fi

  # Check if wallet is currently running and stop it if running
  if [ -f "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d" 2> /dev/null)" ]; then
    # Wallet is running. Issue stop command
    echo "${CYAN}#####${NONE} Close wallet ${CYAN}#####${NONE}"
    echo && check_stop_wallet "${WALLET_INSTALL_DIR}" "${DATA_INSTALL_DIR}" && echo
  fi

  # Now that the wallet is not running, delete the old wallet files
  rm -f "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d"
  rm -f "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}-cli"

  # Wallet setup
  echo "${CYAN}#####${NONE} Wallet setup ${CYAN}#####${NONE}" && echo

  # Create a small file in the wallet directory to be used for remembering the network interface used for this node
  echo "${NET_INTERFACE}" > ${HOME_DIR}/${WALLET_INSTALL_DIR}/${NET_INTERFACE_CONFIG_NAME}

  # Create a small script that will be used to auto-start the wallet on reboot and register IP address if necessary
  {
    echo "#!/bin/bash"
    echo 'readonly CURRENT_USER="${1}"'
    echo 'readonly WAN_IP="'"${WAN_IP}"'"'
    echo 'readonly NET_INTERFACE="'"${NET_INTERFACE}"'"'
    echo
    echo "execute_command() {"
    echo '  if [ "$USER" != "${CURRENT_USER}" ]; then'
    echo '    su ${CURRENT_USER} -c "${1}"'
    echo '  else'
    echo '    eval "${1}"'
    echo '  fi'
    echo "}"
    echo
    echo 'if ([ -f "${0%/*}/'"${IP4_CONFIG_NAME}"'" ] || [ -f "${0%/*}/'"${IP6_CONFIG_NAME}"'" ]) && [ -n "${WAN_IP}" ] && [ -n "${NET_INTERFACE}" ]; then'
    echo '  ETH_STATUS=$(cat /sys/class/net/${NET_INTERFACE}/operstate)'
    echo
    echo '  if [ "${ETH_STATUS}" = "up" ]; then'
    echo '    if [ -f "${0%/*}/'"${IP6_CONFIG_NAME}"'" ]; then'
    echo '      while [ -z "${IPV6_INT_BASE}" ]; do'
    echo '        sleep 1'
    echo '        IPV6_INT_BASE="$(ip -6 addr show dev ${NET_INTERFACE} | grep inet6 | awk -F '"'"'[ \t]+|/'"'"' '"'"'{print $3}'"'"' | grep -v ^fe80 | grep -v ^::1 | cut -f1-4 -d'"'"':'"'"' | head -1)"'
    echo '        wait'
    echo '      done'
    echo
    echo '      if [ -z "$({ ip -6 addr | grep -i "${WAN_IP}"; })" ]; then'
    echo '        ip -6 addr add "${WAN_IP}/64" dev ${NET_INTERFACE} >/dev/null 2>&1'
    echo '        if [ $? -eq 0 ]; then'
    echo '          sleep 2'
    echo '        fi'
    echo '      fi'
    echo '    else'
    echo '      if [ -z "$({ ip -4 addr | grep -i "${WAN_IP}"; })" ]; then'
    echo '        ip -4 addr add "${WAN_IP}/23" dev ${NET_INTERFACE} >/dev/null 2>&1'
    echo '        if [ $? -eq 0 ]; then'
    echo '          sleep 2'
    echo '        fi'
    echo '      fi'
    echo '     fi'
    echo '  fi'
    echo 'fi'
    echo
    echo 'execute_command "'"${HOME_DIR}"'/'"${WALLET_INSTALL_DIR}"'/'"${WALLET_PREFIX}"'d -datadir='"${USER_HOME_DIR}"'/'"${DATA_INSTALL_DIR}"'"'
  } > ${HOME_DIR}/${WALLET_INSTALL_DIR}/${REBOOT_SCRIPT_NAME}

  # Create a small script that will be used to auto-stop the wallet on shutdown or reboot to help prevent blockchain corruption
  {
    echo "#!/bin/sh"
    echo 'readonly CURRENT_USER="'"${CURRENT_USER}"'"'
    echo 'readonly USER_HOME_DIR="$(awk -F: -v v="${CURRENT_USER}" '"'"'{if ($1==v) print $6}'"'"' /etc/passwd)"'
    echo
    echo 'readonly WALLET_PREFIX="'"${WALLET_PREFIX}"'"'
    echo 'readonly WALLET_DIR="'"${DEFAULT_WALLET_DIR}${INSTALL_SUFFIX}"'"'
    echo 'readonly DATA_DIR="'"${DEFAULT_DATA_DIR}${INSTALL_SUFFIX}"'"'
    echo 'readonly HOME_DIR="'"${HOME_DIR}"'"'
    echo
    echo 'if [ -d "${HOME_DIR}/${WALLET_DIR}" ]; then'
    echo '  if [ -f "${HOME_DIR}/${WALLET_DIR}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${WALLET_DIR}/${WALLET_PREFIX}d" 2> /dev/null)" ]; then'
    echo '    if [ -f "${HOME_DIR}/${WALLET_DIR}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${WALLET_DIR}/${WALLET_PREFIX}d" 2> /dev/null)" ]; then'
    echo '      ${HOME_DIR}/${WALLET_DIR}/${WALLET_PREFIX}-cli -datadir=${USER_HOME_DIR}/${DATA_DIR} stop >/dev/null 2>&1'
    echo
    echo '      while [ -f "${HOME_DIR}/${WALLET_DIR}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${WALLET_DIR}/${WALLET_PREFIX}d" 2> /dev/null)" ]'
    echo "      do"
    echo "        sleep 1 &"
    echo "        wait"
    echo "      done"
    echo "    fi"
    echo "  fi"
    echo "fi"
  } > ${HOME_DIR}/${WALLET_INSTALL_DIR}/${SHUTDOWN_SCRIPT_NAME}

  if [ ! -f ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME} ]; then
    # This is a new install
    # Add a new crontab entry for the root user to ensure that the wallet automatically starts up after reboot
    add_cron_job
  else
    # This is an update install
    # Check if this is an older install that was using the rc.local startup approach
    grep -i "${HOME_DIR}/${WALLET_INSTALL_DIR}/${REBOOT_SCRIPT_NAME}" ${RC_LOCAL} >/dev/null 2>&1

    if [ $? -eq 0 ]; then
      # Remove the reboot script for this wallet from the rc.local file
      remove_rc_local
      # Add a new crontab entry for the root user to ensure that the wallet automatically starts up after reboot
      add_cron_job
    fi
  fi

  # Create a small script that will be used to forward cmds to the wallet daemon app to make it easier to interact with the wallet outside of the install script
  {
    echo "#!/bin/bash"
    echo 'BINARY_PATH="'${HOME_DIR}/${DEFAULT_WALLET_DIR}${INSTALL_SUFFIX}/${WALLET_PREFIX}d -datadir=${USER_HOME_DIR}/${DEFAULT_DATA_DIR}${INSTALL_SUFFIX}'"'
    echo '${BINARY_PATH} "$@"'
  } > ${HOME_DIR}/${DAEMON_SCRIPT_PREFIX}${WALLET_PREFIX}${INSTALL_SUFFIX}

  # Create a small script that will be used to forward cmds to the wallet cli app to make it easier to interact with the wallet outside of the install script
  {
    echo "#!/bin/bash"
    echo 'BINARY_PATH="'${HOME_DIR}/${DEFAULT_WALLET_DIR}${INSTALL_SUFFIX}/${WALLET_PREFIX}-cli -datadir=${USER_HOME_DIR}/${DEFAULT_DATA_DIR}${INSTALL_SUFFIX}'"'
    echo '${BINARY_PATH} "$@"'
  } > ${HOME_DIR}/${CLI_SCRIPT_PREFIX}${WALLET_PREFIX}${INSTALL_SUFFIX}

  # Get the shutdown service filename
  SHUTDOWN_SERVICE_FILE="$(get_shutdown_service_filename)"

  # Check if shutdown service is already installed for this wallet
  if [ -z "$({ systemctl list-units --all --type=service --no-pager | grep "${SHUTDOWN_SERVICE_FILE}.service"; })" ]; then
    # Create the service file that will be used to auto-stop the wallet on shutdown or reboot to help prevent blockchain corruption
    {
      echo "[Unit]"
      echo "Description=Stop and wait for a ${WALLET_PREFIX} wallet to close before shutdown/restart"
      echo
      echo "[Service]"
      echo "Type=oneshot"
      echo "RemainAfterExit=true"
      echo "ExecStart=/bin/true"
      echo "ExecStop=${HOME_DIR}/${WALLET_INSTALL_DIR}/${SHUTDOWN_SCRIPT_NAME}"
      echo
      echo "[Install]"
      echo "WantedBy=multi-user.target"
    } > "${SERVICE_DIR}/${SHUTDOWN_SERVICE_FILE}.service"

    # Enable the shutdown service
    systemctl enable ${SHUTDOWN_SERVICE_FILE} >/dev/null 2>&1
    # Start the shutdown service
    systemctl start ${SHUTDOWN_SERVICE_FILE} >/dev/null 2>&1
  fi

  if [ "${ARCHIVE_DIR}" != "" ] && [ -d "${USER_HOME_DIR}/${ARCHIVE_DIR}" ]; then
    # Find the proper files from within the extracted directory and move them to the install directory
    find ${USER_HOME_DIR}/${ARCHIVE_DIR} -name "${WALLET_PREFIX}d" -type f -exec mv {} "${HOME_DIR}/${WALLET_INSTALL_DIR}/" \;
    find ${USER_HOME_DIR}/${ARCHIVE_DIR} -name "${WALLET_PREFIX}-cli" -type f -exec mv {} "${HOME_DIR}/${WALLET_INSTALL_DIR}/" \;
    # Remove extracted directory
    rm -rf "${USER_HOME_DIR}/${ARCHIVE_DIR}"
  else
    # Move extracted files from the home directory to the install directory
    mv "${USER_HOME_DIR}/${WALLET_PREFIX}d" "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d"
    mv "${USER_HOME_DIR}/${WALLET_PREFIX}-cli" "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}-cli"
  fi

  # Create easier links to the wallet files
  ln -s ${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d ${HOME_DIR}/${WALLET_PREFIX}d${INSTALL_SUFFIX}
  ln -s ${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}-cli ${HOME_DIR}/${WALLET_PREFIX}-cli${INSTALL_SUFFIX}

  # Mark wallet files and scripts as executable
  chmod +x ${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d
  chmod +x ${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}-cli
  chmod +x ${HOME_DIR}/${WALLET_INSTALL_DIR}/${REBOOT_SCRIPT_NAME}
  chmod +x ${HOME_DIR}/${WALLET_INSTALL_DIR}/${SHUTDOWN_SCRIPT_NAME}
  chmod +x ${HOME_DIR}/${DAEMON_SCRIPT_PREFIX}${WALLET_PREFIX}${INSTALL_SUFFIX}
  chmod +x ${HOME_DIR}/${CLI_SCRIPT_PREFIX}${WALLET_PREFIX}${INSTALL_SUFFIX}

  if [ "$WALLET_BASE_DIR" = "${HOME_DIR}" ]; then
    # Save a copy of the downloaded wallet into the current install directory
    mv "${WALLET_BASE_DIR}/${WALLET_FILE}" "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_FILE}"
  fi

  # Do not copy the blockchain from another installed wallet by default
  COPY_BLOCKCHAIN=0

  # Check if the config file already exists (if yes, this is most likely an upgrade install)
  if [ ! -f ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME} ]; then
    # The config file does not exist
    if [ ! -d "${USER_HOME_DIR}/${DATA_INSTALL_DIR}" ]; then
      # Manually create the data directory
      execute_command "mkdir ${USER_HOME_DIR}/${DATA_INSTALL_DIR}"
    fi

    # Attempt to copy the blockchain from another installed wallet near the end of the install
    COPY_BLOCKCHAIN=1
  elif [ "$REINDEX" = "c" ]; then
    # Attempt to copy the blockchain from another installed wallet near the end of the install
    COPY_BLOCKCHAIN=1
  fi

  # Overwrite configuration file settings
  write_config

  # Check if a reindex should be done
  if [ -n "${REINDEX}" ]; then
    # Delete existing blockchain files
    delete_blockchain
  fi

  # If there is no genkey value then generate it from the current wallet
  if [ -z "$NULLGENKEY" ]; then
    echo "Temporarily starting new wallet"

    # Start wallet
    execute_command "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d -datadir=${USER_HOME_DIR}/${DATA_INSTALL_DIR}"

    # Wait for wallet to load
    wait_wallet_loaded

    # Get the genkey value
    NULLGENKEY=$("${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}-cli" -datadir="${USER_HOME_DIR}/${DATA_INSTALL_DIR}" masternode genkey) >/dev/null 2>&1
    echo && printf "Generated new genkey value: ${NULLGENKEY}"

    # Stop the wallet
    echo && check_stop_wallet "${WALLET_INSTALL_DIR}" "${DATA_INSTALL_DIR}"

    # Overwrite configuration file settings (now with the proper genkey value)
    write_config
  fi

  # Add a variable to determine if the blockchain was copied from another wallet install
  BLOCKCHAIN_COPIED=0

  # Check if another wallets blockchain should be copied to this installation
  if [ "$COPY_BLOCKCHAIN" -eq 1 ]; then
    # Determine if there is another install that can be copied over to save time on re-syncing the blockchain
    i=1; while [ $i -le 99 ]; do
      case $i in
        1) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}"
           DATA_DIR_TEST="${DEFAULT_DATA_DIR}" ;;
        *) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}${i}"
           DATA_DIR_TEST="${DEFAULT_DATA_DIR}${i}" ;;
      esac

      if [ -d "${USER_HOME_DIR}/${DATA_DIR_TEST}" ] && [ "${DATA_DIR_TEST}" != "${DATA_INSTALL_DIR}" ]; then
        # Found another data directory
        # Delete the necessary files from the current data directory
        delete_blockchain
        NEED_RESTART=0

        # Check if the other wallet is currently running and stop it if running
        if [ -f "${HOME_DIR}/${WALLET_DIR_TEST}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${WALLET_DIR_TEST}/${WALLET_PREFIX}d" 2> /dev/null)" ]; then
          # Wallet is running. Issue stop command
          echo "Temporarily closing wallet #${i}"
          check_stop_wallet "${WALLET_DIR_TEST}" "${DATA_DIR_TEST}"
          NEED_RESTART=1
        fi

        # Copy blockchain files from the other data directory
        echo "Copy blockchain from wallet #${i}"

        if [ -n "${COPY_FILE1}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE1} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE1}"
        fi

        if [ -n "${COPY_FILE2}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE2} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE2}"
        fi

        if [ -n "${COPY_FILE3}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE3} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE3}"
        fi

        if [ -n "${COPY_FILE4}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE4} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE4}"
        fi

        if [ -n "${COPY_FILE5}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE5} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE5}"
        fi

        if [ -n "${COPY_FILE6}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE6} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE6}"
        fi

        if [ -n "${COPY_FILE7}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE7} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE7}"
        fi

        if [ -n "${COPY_FILE8}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE8} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE8}"
        fi

        if [ -n "${COPY_FILE9}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE9} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE9}"
        fi

        if [ -n "${COPY_FILE10}" ]; then
          execute_command "cp -rf ${USER_HOME_DIR}/${DATA_DIR_TEST}/${COPY_FILE10} ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${COPY_FILE10}"
        fi

        execute_command "sync && wait"

        # Indicate that the blockchain was copied from another wallet install
        BLOCKCHAIN_COPIED=1

        # Check if other wallet needs to be restarted
        if [ $NEED_RESTART -eq 1 ]; then
          # Restart other wallet
          echo "Restart wallet #${i}"
          execute_command "${HOME_DIR}/${WALLET_DIR_TEST}/${WALLET_PREFIX}d -datadir=${USER_HOME_DIR}/${DATA_DIR_TEST}"
        fi

        # Return from loop
        break
      fi

      i=$(( i + 1 ))
    done
  fi

  # Check if the blockchain could not be copied from another wallet install and the snapshot url is set or this is a snapshot reindex
  if ([ "$COPY_BLOCKCHAIN" -eq 1 ] && [ "$BLOCKCHAIN_COPIED" -eq 0 ] && [ -n "${SNAPSHOT_URL}" ] || [ "$REINDEX" = "s" ]); then
    # Download snapshot
    echo && echo "${CYAN}#####${NONE} Download snapshot ${CYAN}#####${NONE}" && echo
    wget -q "${SNAPSHOT_URL}" -O "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz" -P "${USER_HOME_DIR}/${DATA_INSTALL_DIR}" --show-progress
    SNAPSHOT_OK=0

    # Check if the snapshot downloaded successfully
    if [ ! -f "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz" ] || [ $(stat -c%s "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz") -eq 0 ]; then
      # Something went wrong because the file does not exist
      echo "Failed to download snapshot"
    else
      # Check if the snapshot file is larger than 1 MB (1048576 bytes)
      if [ $(stat -c%s "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz") -gt 1048576 ]; then
        # Indicate that the snapshot seems OK to extract
        SNAPSHOT_OK=1
      else
        # Snapshot file is less than 1 MB
        # Read contents of the file into a variable
        SNAPSHOT_CONTENTS=$(cat "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz")

        # Check if the contents of the file is another url
        if [ "$(is_url ${SNAPSHOT_CONTENTS})" = "0" ]; then
          # Something went wrong because the file does not contain a url
          echo "Failed to download snapshot"
        else
          # Download snapshot again using the new url
          wget -q "${SNAPSHOT_CONTENTS}" -O "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz" -P "${USER_HOME_DIR}/${DATA_INSTALL_DIR}" --show-progress

          # Check if the snapshot downloaded successfully and is larger than 1 MB
          if [ -f "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz" ] && [ $(stat -c%s "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz") -gt 1048576 ]; then
            # Indicate that the snapshot seems OK to extract
            SNAPSHOT_OK=1
          else
            # Something went wrong because the file is still less than 1 MB
            echo "Failed to download snapshot"
          fi
        fi
      fi
    fi
    echo

    # Check if it is OK to extract the snapshot
    if [ "$SNAPSHOT_OK" -eq 1 ]; then
      # Delete existing blockchain files
      delete_blockchain

      # Extract snapshot files from downloaded archive
      extract_snapshot_files
    fi

    # Check if the snapshot file exists
    if [ -f "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz" ]; then
      # Delete the snapshot file
      rm -f "${USER_HOME_DIR}/${DATA_INSTALL_DIR}/snapshot.tgz"
    fi
  fi

  # Wallet setup complete
  echo "Wallet setup complete" && echo
  # Start wallet
  echo "${CYAN}#####${NONE} Start Wallet ${CYAN}#####${NONE}" && echo
  execute_command "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d -datadir=${USER_HOME_DIR}/${DATA_INSTALL_DIR}"
  # Wait for wallet to load
  echo && echo "${CYAN}#####${NONE} Wait for wallet to load ${CYAN}#####${NONE}" && echo
  wait_wallet_loaded && echo && echo
  # Wait for at least one peer connection to the wallet
  PEER_DATA=""
  PERIOD=".  "
  EMPTY_ARRAY="[
]"
  while [ -z "${PEER_DATA}" ] || [ "${PEER_DATA}" = "" ] || [ "${PEER_DATA}" = "0" ] || [ "${PEER_DATA}" = "${EMPTY_ARRAY}" ]; do
    sleep 1 &
    printf "\rWaiting for peer connections%s" "${PERIOD}"
    PEER_DATA=$("${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}-cli" -datadir="${USER_HOME_DIR}/${DATA_INSTALL_DIR}" ${PEER_DATA_CMD}) >/dev/null 2>&1

    case $PERIOD in
      ".  ") PERIOD=".. "
         ;;
      ".. ") PERIOD="..."
         ;;
      *) PERIOD=".  " ;;
    esac && wait
  done
  printf "\rWallet successfully connected to peers" && echo

  # If there is an active block explorer to check, the last step is to wait for the wallet to fully sync with the network (if not skipped)
  if [ "$SYNCCHAIN" -eq 1 ] && [ -n "${BLOCKCOUNT_URL}" ]; then
    # Ensure blockcount url returns a proper value
    TOTAL_BLOCKS=$(curl -s -k "${BLOCKCOUNT_URL}")

    if (echo ${TOTAL_BLOCKS} | egrep -q '^[0-9]+$'); then
      # Wait for the wallet to sync
      echo && echo "${CYAN}#####${NONE} Wait for blocks to sync ${CYAN}#####${NONE}" && echo
      printf "\rSyncing: %s (?.?? %%)" "${CURRENT_BLOCKS}/?"
      TOTAL_BLOCKS=$(curl -s -k "${BLOCKCOUNT_URL}")
      SECONDS=0
      LAST_BLOCKS="${CURRENT_BLOCKS}"
      LAST_SECONDS=0
      WALLET_STUCK=0

      while [ $CURRENT_BLOCKS -lt $TOTAL_BLOCKS ] && [ $WALLET_STUCK -eq 0 ]; do
        sleep 1
        SECONDS=`expr $SECONDS + 1`

        if [ "$SECONDS" -gt 60 ]; then
          # Re-get the total blocks from the block explorer every minute and reset the seconds counter
          TOTAL_BLOCKS=$(curl -s -k "${BLOCKCOUNT_URL}")
          SECONDS=0
        fi

        CURRENT_BLOCKS=$(${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}-cli -datadir=${USER_HOME_DIR}/${DATA_INSTALL_DIR} getblockcount)
        printf "\rSyncing: %s (%.2f %%)" "${CURRENT_BLOCKS}/${TOTAL_BLOCKS}" $(awk "BEGIN { print (100*(${CURRENT_BLOCKS}/${TOTAL_BLOCKS}))-0.005 }")

        if [ "$LAST_BLOCKS" -eq "$CURRENT_BLOCKS" ]; then
          # The block count hasn't moved since last check
          LAST_SECONDS=`expr $LAST_SECONDS + 1`

          if [ "$LAST_SECONDS" -gt 60 ]; then
            # The wallet is stuck
            WALLET_STUCK=1
          fi
        else
          # The block count is moving
          LAST_BLOCKS="${CURRENT_BLOCKS}"
          LAST_SECONDS=0
        fi

        wait
      done

      if [ $WALLET_STUCK -eq 0 ]; then
        # Sync finished successfully
        printf "\rSyncing: %s (%.2f %%)" "${TOTAL_BLOCKS}/${TOTAL_BLOCKS}" $(awk "BEGIN { print 100*${TOTAL_BLOCKS}/${TOTAL_BLOCKS} }") && echo
      else
        # Wallet is stuck and will not sync
        printf "\rSyncing halted                                           " && echo
        echo && echo "${ORANGE}#####${NONE} WARNING: Blockchain does not appear to be downloading ${ORANGE}#####${NONE}" && echo
        echo "1) Check to ensure you are connected to the internet"
        echo "2) If the block count still does not move after a few minutes then"
        echo "   a full resync may be be necessary using the following cmds:"

        if [ "$INSTALL_NUM" -eq 1 ]; then
          echo "   ${WALLET_PREFIX}-cli stop"
          echo "   ${WALLET_PREFIX}d -resync"
        else
          echo "   ${WALLET_PREFIX}-cli${INSTALL_NUM} -datadir=${USER_HOME_DIR}/${DATA_INSTALL_DIR} stop"
          echo "   ${WALLET_PREFIX}d${INSTALL_NUM} -datadir=${USER_HOME_DIR}/${DATA_INSTALL_DIR} -resync"
        fi

        echo && echo -n "Press [ENTER] to continue"
        read -p "" WALLET_STUCK
      fi
    else
      # The block explorer isn't working
      echo && echo "${ORANGE}#####${NONE} ${BLOCKCOUNT_URL} is down ${ORANGE}#####${NONE}"
      echo "${ORANGE}#####${NONE} Blockchain sync will continue in the background ${ORANGE}#####${NONE}"
    fi
  fi

  # Final setup instructions
  echo && echo "${ORANGE}===================================================================${NONE}"
  echo "${ORANGE}                     Final setup instructions${NONE}"
  echo "${ORANGE}===================================================================${NONE}"
  # masternode.conf file setup
  echo && echo "${PURPLE}#####${NONE} masternode.conf file setup ${PURPLE}#####${NONE}" && echo
  echo "Add the following line to the bottom of your masternode.conf file in your controller wallet (Tools > Open Masternode Configuration File):" && echo
  echo "${CYAN}<alias>${NONE} ${CONFIG_ADDRESS} ${NULLGENKEY} ${CYAN}<txhash>${NONE} ${CYAN}<outputidx>${NONE}"

  echo && echo "${ORANGE}NOTE: You must make the following replacements:${NONE}"
  echo "Replace ${CYAN}<alias>${NONE} with the alias from step 1 on the controller wallet setup (getaccountaddress <alias>)"
  echo "Replace ${CYAN}<txhash>${NONE} with the proper value from 'getmasternodeoutputs'"
  echo "Replace ${CYAN}<outputidx>${NONE} with the proper value from 'getmasternodeoutputs'"
  # Output the list of useful commands for the newly installed wallet
  echo && echo "${PURPLE}#####${NONE} Useful commands ${PURPLE}#####${NONE}" && echo

  if [ "$INSTALL_NUM" -eq 1 ]; then
    echo "${CYAN}Uninstall wallet:${NONE} sudo sh ${0##*/} -t u"
    echo "${CYAN}Manually stop wallet:${NONE} c${WALLET_PREFIX} stop"
    echo "${CYAN}Manually start wallet:${NONE} d${WALLET_PREFIX}"
    echo "${CYAN}View wallets current block:${NONE} c${WALLET_PREFIX} getblockcount"
    echo "${CYAN}Masternode status check:${NONE} c${WALLET_PREFIX} getmasternodestatus"
  else
    echo "${CYAN}Uninstall wallet:${NONE} sudo sh ${0##*/} -t u -n $INSTALL_NUM"
    echo "${CYAN}Manually stop wallet:${NONE} c${WALLET_PREFIX}${INSTALL_NUM} stop"
    echo "${CYAN}Manually start wallet:${NONE} d${WALLET_PREFIX}${INSTALL_NUM}"
    echo "${CYAN}View wallets current block:${NONE} c${WALLET_PREFIX}${INSTALL_NUM} getblockcount"
    echo "${CYAN}Masternode status check:${NONE} c${WALLET_PREFIX}${INSTALL_NUM} getmasternodestatus"
  fi

  echo && echo "${ORANGE}===================================================================${NONE}"
  echo "${ORANGE}Scroll up for useful commands and additional configuration settings${NONE}"
  echo "${ORANGE}===================================================================${NONE}"
else
  # Check to ensure this wallet # is actually installed
  if [ ! -d "${HOME_DIR}/${WALLET_INSTALL_DIR}" ] && [ ! -d "${USER_HOME_DIR}/${DATA_INSTALL_DIR}" ]; then
    # Wallet is not installed
    error_message "Cannot find installed wallet in ${HOME_DIR}/${WALLET_INSTALL_DIR}"
  fi

  echo "The following directories will be deleted:" && echo
  echo "${CYAN}Wallet Directory:${NONE}    ${HOME_DIR}/${WALLET_INSTALL_DIR}"
  echo "${CYAN}Data Directory:${NONE}      ${USER_HOME_DIR}/${DATA_INSTALL_DIR}"
  echo && echo -n "Are you sure you want to completely uninstall the wallet? [y/n]: "
  read -p "" UNINSTALL_ANSWER

  case "$UNINSTALL_ANSWER" in
    y|Y|yes|Yes|YES) ;;
    *) exit ;;
  esac

  # Check if the wallet is currently running
  if [ -f "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d" ] && [ -n "$(lsof "${HOME_DIR}/${WALLET_INSTALL_DIR}/${WALLET_PREFIX}d" 2> /dev/null)" ]; then
    # Stop the running wallet
    echo && check_stop_wallet "${WALLET_INSTALL_DIR}" "${DATA_INSTALL_DIR}"
  fi

  # Check if the wallet was bound to a specific network interface
  if [ -f "${HOME_DIR}/${WALLET_INSTALL_DIR}/${NET_INTERFACE_CONFIG_NAME}" ]; then
    # Remember network interface from last install
    NET_INTERFACE=$(cat "${HOME_DIR}/${WALLET_INSTALL_DIR}/${NET_INTERFACE_CONFIG_NAME}")
  fi

  # Check if the wallet created an IPv4 address
  if [ -f "${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP4_CONFIG_NAME}" ]; then
    # Initialize network variables for use below
    init_network
    # Unregister the IPv4 address
    unregisterIP4Address $(cat "${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP4_CONFIG_NAME}") "${NET_INTERFACE}"
  fi

  # Check if the wallet created an IPv6 address
  if [ -f "${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP6_CONFIG_NAME}" ]; then
    # Initialize IPv6 variables for use below
    init_ipv6
    # Unregister the IPv6 address
    unregisterIP6Address $(cat "${HOME_DIR}/${WALLET_INSTALL_DIR}/${IP6_CONFIG_NAME}") "${NET_INTERFACE}"
  fi

  # Check if the wallet config file exists
  if [ -f ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME} ]; then
    # Check if the ufw firewall is installed
    if [ -n "$({ dpkg -l | grep -E '^ii' | grep ufw; })" ]; then
      # Read the port value from the config file
      PORT_NUMBER=$(grep "^port=" ${USER_HOME_DIR}/${DATA_INSTALL_DIR}/${WALLET_CONFIG_NAME} | sed -e "s/port=//g")
      # Check if port number was read correctly
      if [ -n "$PORT_NUMBER" ]; then
        # Remove the firewall rule for this nodes port number
        ufw delete allow ${PORT_NUMBER} >/dev/null 2>&1
      fi
    fi
  fi

  # Remove the reboot script for this wallet from the rc.local file
  remove_rc_local
  # Remove the reboot script for this wallet from the crontab
  ( crontab -l | grep -v -F "@reboot sleep 30; ${HOME_DIR}/${WALLET_INSTALL_DIR}/${REBOOT_SCRIPT_NAME}" ) | crontab -
  # Get the shutdown service filename
  SHUTDOWN_SERVICE_FILE="$(get_shutdown_service_filename)"
  # Stop the shutdown service for this wallet
  systemctl stop ${SHUTDOWN_SERVICE_FILE} >/dev/null 2>&1
  # Disable the shutdown service for this wallet
  systemctl disable ${SHUTDOWN_SERVICE_FILE} >/dev/null 2>&1
  # Remove the shutdown service file from systemd
  rm -f "${SERVICE_DIR}/${SHUTDOWN_SERVICE_FILE}.service"
  # Soft reload the systemd configuration to pick up the new service changes
  systemctl daemon-reload
  # The final step of removing the shutdown service is to clear out any error state that may have resulted from removal of the service
  systemctl reset-failed
  # Remove old links to wallet binaries
  removeWalletLinks
  # Remove the wallet daemon forwarding script
  rm -f "${HOME_DIR}/${DAEMON_SCRIPT_PREFIX}${WALLET_PREFIX}${INSTALL_SUFFIX}"
  # Remove the wallet cli forwarding script
  rm -f "${HOME_DIR}/${CLI_SCRIPT_PREFIX}${WALLET_PREFIX}${INSTALL_SUFFIX}"
  # Remove the wallet and data directories
  rm -rf "${HOME_DIR}/${WALLET_INSTALL_DIR}"
  rm -rf "${USER_HOME_DIR}/${DATA_INSTALL_DIR}"

  # Check if there are any more installs
  FULL_UNINSTALL=1
  i=1; while [ $i -le 99 ]; do
    case $i in
      1) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}" ;;
      *) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}${i}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}${i}" ;;
    esac

    if [ "${FULL_UNINSTALL}" -eq 1 ] && [ -d "${HOME_DIR}/${WALLET_DIR_TEST}" ] && [ -f "${USER_HOME_DIR}/${DATA_DIR_TEST}/${WALLET_CONFIG_NAME}" ]; then
      # There is still an existing wallet
      FULL_UNINSTALL=0
    fi

    i=$(( i + 1 ))
  done

  if [ "${FULL_UNINSTALL}" -eq 1 ]; then
    # Remove the source directory if it exists to ensure that all data is completely uninstalled
    rm -rf "${USER_HOME_DIR}/${SOURCE_DIR}"
  fi
fi

echo && echo "${GREEN}#####${NONE} ${INSTALL_TYPE}ation complete ${GREEN}#####${NONE}" && echo

# Check if this was an updateall install
if [ -n "$UPDATE_INDEX" ] && [ ${UPDATE_INDEX} -ne 0 ]; then
  # Check if there are any more wallets to update
  i=$(( UPDATE_INDEX + 1 )); while [ $i -le 99 ]; do
    case $i in
      1) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}" ;;
      *) WALLET_DIR_TEST="${DEFAULT_WALLET_DIR}${i}"
         DATA_DIR_TEST="${DEFAULT_DATA_DIR}${i}" ;;
    esac

    if [ -d "${HOME_DIR}/${WALLET_DIR_TEST}" ] && [ -f "${USER_HOME_DIR}/${DATA_DIR_TEST}/${WALLET_CONFIG_NAME}" ]; then
      # Set the update index
      UPDATE_INDEX=${i}
      # Return from loop
      break
    fi

    i=$(( i + 1 ))
  done

  # Check if a new wallet install was found
  if [ ${i} -le 99 ]; then
    # Save the update index to the temp update config file
    echo "${UPDATE_INDEX}" > ${TEMP_UPDATE_CONFIG_PATH}
    # Restart the script to update the next wallet
    eval "sh ${USER_HOME_DIR}/${0##*/} -U"
    exit
  else
    # Finished updating all wallets
    echo "${GREEN}#####${NONE} All installed wallets were updated successfully ${GREEN}#####${NONE}" && echo
  fi
fi