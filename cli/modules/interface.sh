#!/usr/bin/env bash
set -e

. "$AZGCLI_WORKDIR/modules/common.sh"

cli_help_add() {
    echo "
AzureGuard CLI

Usage: azg.sh [global options] interface <operation>

Main operations:
  add       Add a wireguard interface
  remove    Remove a wireguard interface
  update    Update a wireguard interface
  show      Show wireguard interface details
  list      List wireguard interfaces
    "
    exit 1
}

[ ! -n "$1" ] && cli_help_add

case "$1" in
    add)
        shift
        "$AZGCLI_WORKDIR/modules/interface/add.sh" "$@" | tee -ia "$AZGCLI_WORKDIR/logs/interface_add.log"
    ;;
    remove)
        shift
        "$AZGCLI_WORKDIR/modules/interface/remove.sh" "$@" | tee -ia "$AZGCLI_WORKDIR/logs/interface_remove.log"
    ;;
    update)
        shift
        "$AZGCLI_WORKDIR/modules/interface/update.sh" "$@" | tee -ia "$AZGCLI_WORKDIR/logs/interface_update.log"
    ;;
    show)
        shift
        "$AZGCLI_WORKDIR/modules/interface/show.sh" "$@" | tee -ia "$AZGCLI_WORKDIR/logs/interface_show.log"
    ;;
    list)
        shift
        "$AZGCLI_WORKDIR/modules/interface/list.sh" "$@" | tee -ia "$AZGCLI_WORKDIR/logs/interface_list.log"
    ;;
    *)
        cli_help_add
    ;;
esac