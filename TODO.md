# Ansible TODOs

This Document collects Ideas and Todos

## General ideas

### Naming

* Name Server after nordic gods.

### Role Ideas

* nach os trennen in machine
* main if -> vars debinsa
* -> defaults debina
* Verschiedene Rollen

### vault

* Einrichten

## Usermanagment

* In allen Rollen
* Unprevilegierete User
* etc

## Server specific

### 1&1 Server

* im DMZ netz? zB durch Site to Site vpn
* Alternativ nur portfreigabe/forward
* weiter autossh? Oder ipv4forward und/oder vpn?

## Specific Roles

### dns.install

* DNS aus inventory bauen
* pihole als Container?
* Regex filter hinzufügen
* https://github.com/mmotti/pihole-regex

### vpn.install

* Pivpn, ovpn oder/und wireguard install + setup

### mailserver.install

* Setup for 1&1 just smtp -> client hostet local

### machine.prepare

* User anlegen für normal ohne automatisierung - evtl jedes mal neuen key generieren?
* unattended-upgrades
* https://libre-software.net/ubuntu-automatic-updates/

### docker.install

* ansible user + sudo
* setup docker + compose

### autossh.install

* Setup autossh as service and configured based on hostvars/defaults

### machine.harden

* SSH Hardening
* VPN Hardening
* Intrusion Detection
* ??

### nextcloud.install

* Only office?
* Addons
* database and proxy

### bitwarden.install

### gitlab.install

### tekbase.install

### media.install

* Jellyfin
* Subsonic
* Sonarr
* Radarr
* VPN killswitch and configuration
* Ombi?
* Deluge or DelugeVPN
* NFS Einbinden? Oder Dateimanagment

### monitoring.install

* prepare and install grafana/loki/prometheus

### heimdall.install

* install and configure heimdall

### certbot.install

* get certificate and install automated certbot

### proxy.install

* Setup proxy for diffrent application - also make ssl possible
* Build entrys based on iventory and ports in inventory

* Where to locate?
* Point *.knell.dev internal there?
* https://github.com/linuxserver/reverse-proxy-confs
* https://fardog.io/blog/2017/12/30/client-side-certificate-authentication-with-nginx/
* Keycloak SSO page?

### keycloak.install

* Single Authetification Server for all Applications

### postgres.install

### rotate.certs

* using cert_path in host_vars + bool

## Open Applications to Evaluate

* Ad on Windows Server
* Freenas Setup?
* Own Search Engine - Searx.me
* AntiVirus on Firewall
* Lychee
* Bvckup2
* Rancher / Kubernetes
* Rocketchat or similiar
* Onetimesegret eg. cryptonode
* Link Shorteneer
* One Click Hoster - probably unescesary bc of nectcloud
* pyload mit VPN Killswitch
* Jira+ Confluence
* Dokuwiki?
* Minidlna?
* Youtrack? Flox? https://github.com/devfake/flox
* Phabricator
* KanboarD
* Restyaboard
* Redmine
* Duplicati (for jellyfin?)
* portainer
* BookStack
* elabftw
* ckeditor
* own pastebin
* coder? Codeserver? VSCode im Browser
* Keeweb?

## Needs refining

* Backup plan
* Next Steps Network/NAS
* Wetterstation und Blitzradar betreiben und daten verfügbar machen


## New ideas 02/10
* gitlab runner
* prepare überarbeiten

