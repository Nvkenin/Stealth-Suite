#!/bin/bash

# ==================================================================
# Nvkenin Stealth Suite - v1.0 (Auditor & Wardrive Edition)
# Coded by Nvkenin | GitHub: github.com/nvkenin/stealth-suite
# ==================================================================

# Cores
C_RED='\033[1;31m'
C_GREEN='\033[1;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[1;36m'
C_RESET='\033[0m'

# --- FUNÇÃO DE LIMPEZA DE EMERGÊNCIA (TRAP) ---
# Executa automaticamente se o script for interrompido (Ctrl+C, Sinais de Sistema)
function emergency_exit() {
    echo -e "\n${C_RED}[!] Interrupção detectada. Restaurando rede de segurança...${C_RESET}"
    sudo iptables -P INPUT ACCEPT 2>/dev/null
    sudo iptables -P FORWARD ACCEPT 2>/dev/null
    sudo iptables -P OUTPUT ACCEPT 2>/dev/null
    sudo iptables -F 2>/dev/null
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null 2>&1
    sudo service tor stop >/dev/null 2>&1
    print_success "Rede restaurada e IPv6 reativado. Saindo."
    exit 0
}

# Captura sinais de interrupção (SIGINT = Ctrl+C, SIGTERM = Encerramento de processo)
trap emergency_exit SIGINT SIGTERM

# --- Utilitários de Mensagem ---
function print_status() { echo -e "${C_CYAN}[*] $1${C_RESET}"; }
function print_success() { echo -e "${C_GREEN}[+] $1${C_RESET}"; }
function print_error() { echo -e "${C_RED}[!] $1${C_RESET}"; }

# --- Verificação de Dependências ---
function setup_environment() {
    print_status "Validando dependências do sistema..."
    local deps=(tor proxychains4 python3 python3-pip git curl php iptables)
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            print_status "Instalando $dep..."
            sudo apt-get update && sudo apt-get install -y "$dep"
        fi
    done
    
    if [ -f /etc/proxychains4.conf ]; then
        sudo sed -i 's/^#proxy_dns/proxy_dns/' /etc/proxychains4.conf
        if ! grep -q "socks5 127.0.0.1 9050" /etc/proxychains4.conf; then
            echo "socks5 127.0.0.1 9050" | sudo tee -a /etc/proxychains4.conf > /dev/null
        fi
    fi
}

# --- Controle de Stealth ---
function start_stealth() {
    sudo service tor start
    sleep 2
    if systemctl is-active --quiet tor; then
        print_success "Tor ativo."
        read -p "Deseja ativar o KILL SWITCH (Firewall)? (s/n): " ks
        if [[ "$ks" == "s" || "$ks" == "S" ]]; then
            # Desativa IPv6 para evitar vazamentos
            sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null
            sudo iptables -F
            sudo iptables -P OUTPUT DROP
            sudo iptables -A OUTPUT -o lo -j ACCEPT
            sudo iptables -A OUTPUT -m owner --uid-owner debian-tor -j ACCEPT
            sudo iptables -A OUTPUT -p tcp --dport 9050 -j ACCEPT
            print_success "Kill Switch ATIVO. IPv6 Desativado."
        fi
    else
        print_error "Erro ao iniciar o Tor."
    fi
}

# --- Execução de Auditoria ---
function run_audit() {
    local name=$1 repo=$2 cmd=$3
    mkdir -p Tools && cd Tools || exit
    [[ ! -d "$name" ]] && git clone "$repo" "$name"
    cd "$name" || exit
    
    print_status "Preparando dependências de $name..."
    [[ -f "requirements.txt" ]] && pip3 install -r requirements.txt --break-system-packages 2>/dev/null
    
    print_status "Executando: $name"
    proxychains4 $cmd
    cd ../..
}

# --- Menu Principal ---
function main_menu() {
    setup_environment
    while true; do
        clear
        echo -e "${C_RED}    Nvkenin Stealth Suite v11.5${C_RESET}"
        echo -e "${C_CYAN}------------------------------------------------${C_RESET}"
        echo -e " [1] Iniciar Stealth Mode    [2] New Identity (IP)"
        echo -e " [3] Zphisher (Social Eng)   [4] Sherlock (OSINT)"
        echo -e " [5] SQLMap (Web Audit)      [6] Seeker (GPS)"
        echo -e " [7] Testar Vazamento IP     [8] Resetar Network (Reativar IPv6)"
        echo -e " [0] Sair e Limpar Tudo"
        echo -e "${C_CYAN}------------------------------------------------${C_RESET}"
        read -p ">> " opt
        case $opt in
            1) start_stealth ;;
            2) sudo killall -HUP tor && print_success "Circuito renovado." && sleep 2 ;;
            3) run_audit "zphisher" "https://github.com/htr-tech/zphisher.git" "bash zphisher.sh" ;;
            4) run_audit "sherlock" "https://github.com/sherlock-project/sherlock.git" "python3 sherlock.py --help" ;;
            5) run_audit "sqlmap" "https://github.com/sqlmapproject/sqlmap.git" "python3 sqlmap.py --help" ;;
            6) run_audit "seeker" "https://github.com/thewhiteh4t/seeker.git" "python3 seeker.py" ;;
            7) ip=$(proxychains4 curl -s https://api.ipify.org || echo "OFFLINE"); echo -e "IP Atual: ${C_YELLOW}$ip${C_RESET}"; sleep 3 ;;
            8) sudo iptables -P OUTPUT ACCEPT && sudo iptables -F && sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0 >/dev/null; print_success "Rede e IPv6 restaurados."; sleep 2 ;;
            0) emergency_exit ;; # Reutiliza a função de limpeza para sair
            *) print_error "Opção inválida." ;;
        esac
    done
}

if [[ $EUID -ne 0 ]]; then echo -e "${C_RED}Execute como root (sudo).${C_RESET}"; exit 1; fi
main_menu