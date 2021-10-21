#!/usr/bin/env bash

# Usage Guide
function usage-guide() {
  if [ -f "${WIREGUARD_INTERFACE}" ]; then
    echo "usage: ./$(basename "$0") <command>"
    echo "  --install     Install WireGuard"
    echo "  --start       Start WireGuard"
    echo "  --stop        Stop WireGuard"
    echo "  --restart     Restart WireGuard"
    echo "  --list        Show WireGuard"
    echo "  --add         Add WireGuard Peer"
    echo "  --remove      Remove WireGuard Peer"
    echo "  --reinstall   Reinstall WireGuard"
    echo "  --uninstall   Uninstall WireGuard"
    echo "  --update      Update WireGuard Manager"
    echo "  --ddns        Update WireGuard IP Address"
    echo "  --backup      Backup WireGuard"
    echo "  --restore     Restore WireGuard"
    echo "  --purge       Purge WireGuard Peer(s)"
    echo "  --help        Show Usage Guide"
  fi
}

# The usage of the script
function usage() {
  if [ -f "${WIREGUARD_INTERFACE}" ]; then
    while [ $# -ne 0 ]; do
      case ${1} in
      --install)
        shift
        HEADLESS_INSTALL=${HEADLESS_INSTALL:-y}
        ;;
      --start)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-2}
        ;;
      --stop)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-3}
        ;;
      --restart)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-4}
        ;;
      --list)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-1}
        ;;
      --add)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-5}
        ;;
      --remove)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-6}
        ;;
      --reinstall)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-7}
        ;;
      --uninstall)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-8}
        ;;
      --update)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-9}
        ;;
      --backup)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-10}
        ;;
      --restore)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-11}
        ;;
      --notification)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-12}
        ;;
      --ddns)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-13}
        ;;
      --purge)
        shift
        WIREGUARD_OPTIONS=${WIREGUARD_OPTIONS:-15}
        ;;
      --help)
        shift
        usage-guide
        ;;
      *)
        echo "Invalid argument: ${1}"
        usage-guide
        exit
        ;;
      esac
    done
  fi
}

usage "$@"
