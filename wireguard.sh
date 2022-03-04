#!/bin/bash

helpmsg="""
\n\tinterface_name: Nom a donner pour l'interface vpn (tun0, wg0, proxtun, ...).\n
\tremote_ip: L'adresse ip ou domaine du serveur vpn.\n
\tremote_port: le port du serveur vpn.\n
\tnb_client: Le nombre de client à générer.\n
\twan_iface: Interface réseau connecté à internet/au réseau local.\n
"""

if [[ $# -lt 5 ]]; then
    echo "Usage: $0 <interface_name> <remote_ip> <remote_port> <nb_client (MAX 253)> <wan_iface (e.g: wlan0)>"
    echo -e $helpmsg
    echo "  Exemple: $0 tunproxmox 212.119.243.71 51194 3 wlp2s0"
    exit 1
fi

iface=${1}
remote_ip=${2}
remote_port=${3}
nb_client=${4}
iface_wan=${5}

if [[ ${nb_client} -ge 253 ]]; then
    echo "Le nombre de clients doit être INFERIEUR à 253."
    exit 1
fi

# Generate public and private key for server
wg genkey | tee "${iface}_private.key" | wg pubkey > "${iface}_public.key"

cat << EOF > "${iface}.conf"
[Interface]
Address = 10.0.0.1/24
PrivateKey = $(cat "${iface}_private.key")
ListenPort = ${remote_port}
PreUp = sysctl -w net/ipv4/ip_forward=1; iptables -A INPUT -i ${iface_wan} -p udp --dport ${remote_port} -j ACCEPT && iptables -A FORWARD -i ${iface} -o ${iface_wan} -j ACCEPT && iptables -A FORWARD -i ${iface_wan} -o ${iface} -j ACCEPT && iptables -t nat -A POSTROUTING -o ${iface_wan} -j MASQUERADE
PreDown = sysctl -w net/ipv4/ip_forward=0
EOF

echo "[*] génération des clients..."
for i in $(seq 1 ${nb_client}); do
    ip=$(($i+1))

    wg genkey | tee "client_${i}_private.key" | wg pubkey > "client_${i}_public.key"

    # Adding client to server conf
    echo -e "\n# Client ${i}" >> "${iface}.conf"
    echo "[peer]" >> "${iface}.conf"
    echo "PublicKey = $(cat "client_${i}_public.key")" >> "${iface}.conf"
    echo "AllowedIPs = 10.0.0.${ip}/32" >> "${iface}.conf"

    # Create client conf
    cat << EOF > client_${i}.conf
[Interface]
PrivateKey = $(cat "client_${i}_private.key")
Address = 10.0.0.${ip}/24
DNS = 1.1.1.1

[Peer]
PublicKey = $(cat "${iface}_public.key")
Endpoint =  ${remote_ip}:${remote_port}
AllowedIPs = 0.0.0.0/0
EOF

    echo " + Client ${i} @10.0.0.${ip} [$(cat "client_${i}_public.key")]"

done

echo -en "\n[?] Voulez vous enregistrer la conf du serveur dans /etc/wireguard ? [O/n]: "
read c

if [[ ! $c  || $c == "O" || $c == "o" ]]; then
    sudo cp "${iface}.conf" "${iface}_public.key" "${iface}_private.key" /etc/wireguard/

    echo "[i] Pour activer le vpn: sudo wg-quick up ${iface}"
    echo "[i] Pour désactiver le vpn: sudo wg-quick down ${iface}"
fi
