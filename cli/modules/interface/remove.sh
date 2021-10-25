#!/usr/bin/env bash
set -e
. "$AZGCLI_WORKDIR/modules/common.sh"

cli_help_remove() {
    echo "
AzureGuard CLI - remove an interface

Usage: azg [global options] interface remove [options]

Options:
  -n, --name        Name of the interface
  -t, --team        Team to assign the interface to

Examples:
  ./azg interface remove -n MyNewInterface -t Prodigy
    "
    exit 1
}
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -n|--name)
            INTERFACENAME="$2"
            shift
            shift
        ;;
        -t|--team)
            TEAM="$2"
            shift
            shift
        ;;
        *)  cli_log "[ERROR] Invalid argument: $1"
            shift
            cli_help_remove
        ;;
    esac
done

if [ -n "${INTERFACENAME}" ] && [ -n "${TEAM}" ]; then
    WIREGUARD_CONFIG="${WIREGUARD_PATH}/${INTERFACENAME}.conf"
    cli_log "[INFO] New WireGuard config: ${WIREGUARD_CONFIG}"
    if [ -f "${WIREGUARD_CONFIG}" ]; then
        if [ -d "${WIREGUARD_PATH}/${TEAM}/servers/${INTERFACENAME}" ]; then
            cli_log "[INFO] Stopping and disabling services ..."
            if pgrep systemd-journal; then
                systemctl stop wg-quick@"${INTERFACENAME}"
                systemctl disable wg-quick@"${INTERFACENAME}"
            else
                service wg-quick@"${INTERFACENAME}" stop
                service wg-quick@"${INTERFACENAME}" disable
            fi
            
            cli_log "[INFO] Removing server directory ..."
            WIREGUARD_SERVER_PATH="${WIREGUARD_PATH}/${TEAM}/servers/${INTERFACENAME}"
            [[ -d "${WIREGUARD_SERVER_PATH}" ]] && rm -rf "${WIREGUARD_SERVER_PATH}"
            cli_log "[INFO] Removing config file ..."
            [[ -f "${WIREGUARD_CONFIG}" ]] && rm "${WIREGUARD_CONFIG}"
        else
            cli_log "[ERROR] Interface does not exists for this team"
        fi
    else
        cli_log "[ERROR] Interface does not exists"
    fi
else
    cli_log "[ERROR] Missing required arguments"
    cli_help_remove
fi