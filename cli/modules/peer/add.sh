#!/usr/bin/env bash
set -e
. "$AZGCLI_WORKDIR/modules/common.sh"

cli_help_add() {
  echo "
AzureGuard CLI - add an interface

Usage: azg.sh [global options] add if [options]

Options:
  -n, --name        Name of the interface
  -p, --port        Port of the interface
  -t, --team        Team to assign the interface to
  -g, --gateway     IPv4 gateway that is used for interface 
  -s, --subnet      IPv4 subnet that is used for interface
  -i, --ip          Public IPv4 that is used for interface
"
  exit 1
}

while getopts ":n:p:t:g:s:i:" o; do
    case "${o}" in
        n) s=${OPTARG}
            ((s == 45 || s == 90)) || cli_help_add
            ;;
        p)
            p=${OPTARG}
            ;;
        t)
            s=${OPTARG}
            ((s == 45 || s == 90)) || cli_help_add
            ;;
        g)
            p=${OPTARG}
            ;;
        s)
            p=${OPTARG}
            ;;
        i)
            p=${OPTARG}
            ;;
        \?) echo "Invalid option -$OPTARG" >&2
            cli_help_add
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${s}" ] || [ -z "${p}" ]; then
    cli_help_add
fi

IPV4_SUBNET
PRIVATE_SUBNET_V4=${PRIVATE_SUBNET_V4:-"${IPV4_SUBNET}"}
PRIVATE_SUBNET_MASK_V4=$(echo "${PRIVATE_SUBNET_V4}" | cut -d "/" -f 2)

if [ -f "${WIREGUARD_INTERFACE}" ]; then
    SERVER_PRIVKEY=$(wg genkey)
    SERVER_PUBKEY=$(echo "${SERVER_PRIVKEY}" | wg pubkey)
    CLIENT_PRIVKEY=$(wg genkey)
    CLIENT_PUBKEY=$(echo "${CLIENT_PRIVKEY}" | wg pubkey)
    CLIENT_ADDRESS_V4="${PRIVATE_SUBNET_V4::-3}3"
    CLIENT_ADDRESS_V6="${PRIVATE_SUBNET_V6::-3}3"
    PRESHARED_KEY=$(wg genpsk)
    PEER_PORT=$(shuf -i1024-65535 -n1)
    mkdir -p ${WIREGUARD_CLIENT_PATH}
    IPTABLES_POSTUP="iptables -A FORWARD -i ${WIREGUARD_PUB_NIC} -j ACCEPT; iptables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE; ip6tables -A FORWARD -i ${WIREGUARD_PUB_NIC} -j ACCEPT; ip6tables -t nat -A POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE"
    IPTABLES_POSTDOWN="iptables -D FORWARD -i ${WIREGUARD_PUB_NIC} -j ACCEPT; iptables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE; ip6tables -D FORWARD -i ${WIREGUARD_PUB_NIC} -j ACCEPT; ip6tables -t nat -D POSTROUTING -o ${SERVER_PUB_NIC} -j MASQUERADE"
    echo "# ${PRIVATE_SUBNET_V4} ${PRIVATE_SUBNET_V6} ${SERVER_HOST}:${SERVER_PORT} ${SERVER_PUBKEY} ${CLIENT_DNS} ${MTU_CHOICE} ${NAT_CHOICE} ${CLIENT_ALLOWED_IP}
[Interface]
Address = ${GATEWAY_ADDRESS_V4}/${PRIVATE_SUBNET_MASK_V4}
DNS = ${CLIENT_DNS}
ListenPort = ${SERVER_PORT}
PrivateKey = ${SERVER_PRIVKEY}
PostUp = ${IPTABLES_POSTUP}
PostDown = ${IPTABLES_POSTDOWN}
SaveConfig = false
# ${CLIENT_NAME} start
[Peer]
PublicKey = ${CLIENT_PUBKEY}
PresharedKey = ${PRESHARED_KEY}
AllowedIPs = ${CLIENT_ADDRESS_V4}/32,${CLIENT_ADDRESS_V6}/128
# ${CLIENT_NAME} end" >>${WIREGUARD_CONFIG}

    # Service Restart
    if pgrep systemd-journal; then
        systemctl reenable wg-quick@${WIREGUARD_PUB_NIC}
        systemctl restart wg-quick@${WIREGUARD_PUB_NIC}
    else
        service wg-quick@${WIREGUARD_PUB_NIC} enable
        service wg-quick@${WIREGUARD_PUB_NIC} restart
    fi
fi