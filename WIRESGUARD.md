# Pour crééer la configuration du serveur VPN et des clients

`./make_vpn.sh proxtun 192.168.0.20 51194 2 wlp2s0`

> Cette commande permet de créer une configuration VPN du nom de "proxtun", le serveur écoute sur 192.168.0.20:51194, elle genère 2 profiles clients et internet est accessible via l'interface `wlp2s0`.

lors de cette question: 
```
[?] Voulez vous enregistrer la conf du serveur dans /etc/wireguard ? [O/n]:
```

Si tu appuie sur Entrer ou sur 'O' ou 'o', la configuration du serveur sera enregistrer dans /etc/wireguard. *C'est recommandé de le faire*
Toutes autres touche sera interpété comme un refus et le fichier ne sera pas copier.

# Pour activer le serveur VPN ou les clients

Il faut obligatoirement copier le fichier de configuration du serveur ou du client dans `/etc/wireguard`.
Le script `make_vpn.sh` permet de copier directement la configuration du **SERVEUR* dans `/etc/wireguard`.

## Serveur
Activer le serveur
```sh
wg-quick up proxtun
```

Désactiver le serveur
```sh
wg-quick down proxtun
```

## Client
Activer le client
```sh
wg-quick up client_x
```

Désactiver le serveur
```sh
wg-quick down client_x
```

Le serveur activera par défaut le forwarding, et NATera les paquets des clients quand ceux ci voudront aller sur internet.
Le forwarding sera activer et désactiver a l'activation et désactivation du serveur VPN, **mais pas les règles iptables !**

Les clients généré utiliseront le serveur DNS 1.1.1.1 par défaut.

