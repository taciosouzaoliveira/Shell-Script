#!/bin/bash

# Função para configurar regras de firewall locais
local(){

    # Libera tráfego com o servidor Samba AD DC na interface bond0 para o IP específico
    iptables -t filter -A INPUT -i bond0 -s 10.10.10.5 -j ACCEPT
    iptables -t filter -A OUTPUT -o bond0 -d 10.10.10.5 -j ACCEPT

    # Libera acesso remoto SSH externo na interface enp0s3
    iptables -t filter -A INPUT -i enp0s3 -p tcp --dport 22 -j ACCEPT
    iptables -t filter -A OUTPUT -o enp0s3 -p tcp --sport 22 -j ACCEPT

    # Libera acesso SSH do servidor firewall para os servidores da rede 10.10.10.0/24 na interface bond0
    iptables -t filter -A INPUT -i bond0 -p tcp --sport 22 -s 10.10.10.0/24 -j ACCEPT
    iptables -t filter -A OUTPUT -o bond0 -p tcp --dport 22 -d 10.10.10.0/24 -j ACCEPT

    # Libera portas 443 (HTTPS), 80 (HTTP), 53 (DNS), e 123 (NTP) na interface enp0s3 para o firewall
    iptables -t filter -A INPUT -i enp0s3 -p tcp -m multiport --sports 80,443 -j ACCEPT
    iptables -t filter -A INPUT -i enp0s3 -p udp -m multiport --sports 53,123 -j ACCEPT
    iptables -t filter -A OUTPUT -o enp0s3 -p tcp -m multiport --dports 80,443 -j ACCEPT
    iptables -t filter -A OUTPUT -o enp0s3 -p udp -m multiport --dports 53,123 -j ACCEPT

    # Libera conexões ICMP (ping) na interface enp0s3
    iptables -t filter -A OUTPUT -o enp0s3 -p icmp --icmp-type 8 -d 0/0 -j ACCEPT
    iptables -t filter -A INPUT -i enp0s3 -p icmp --icmp-type 0 -s 0/0 -j ACCEPT

    # Libera tráfego na interface loopback (localhost)
    iptables -t filter -A INPUT -i lo -j ACCEPT
    iptables -t filter -A OUTPUT -o lo -j ACCEPT

    # Libera tráfego nas portas SSH e proxy Squid na interface bond0 para a rede 10.10.10.0/24
    iptables -t filter -A INPUT -i bond0 -p tcp -m multiport --dports 22,3128 -s 10.10.10.0/24 -j ACCEPT
    iptables -t filter -A OUTPUT -o bond0 -p tcp -m multiport --sports 22,3128 -d 10.10.10.
