#!/bin/bash

# ==================================================================
# Nvkenin Stealth Suite - (Crimson Protocol)
# ==================================================================

# --- Paleta de Cores (Design Original Restaurado) ---
C_BLOOD='\033[1;31m'
C_DRIP='\033[38;5;196m'
C_GHOST='\033[38;5;250m'
C_DARK='\033[1;90m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[1;36m'
C_WHITE='\033[1;37m'
C_GREEN='\033[1;32m'
C_RESET='\033[0m'
BOLD='\033[1m'

# --- Identificação ---
BASE_DIR=$(pwd)
USE_STEALTH="false"
OPERATOR_NAME=$(echo $SUDO_USER)
[[ -z "$OPERATOR_NAME" ]] && OPERATOR_NAME=$USER
LOG_FILE="nvkenin_log.txt"
ROCKYOU="/usr/share/wordlists/rockyou.txt"

# --- Repositórios (Arsenal Original + Recomendações) ---
declare -A TOOLS_REPO=(
    ["zphisher"]="https://github.com/htr-tech/zphisher.git"
    ["CamPhish"]="https://github.com/techchipnet/CamPhish.git"
    ["seeker"]="https://github.com/thewhiteh4t/seeker.git"
    ["RED_HAWK"]="https://github.com/Tuhinshubhra/RED_HAWK.git"
    ["sqlmap"]="https://github.com/sqlmapproject/sqlmap.git"
    ["dorks-eye"]="https://github.com/BullsEye0/dorks-eye.git"
    ["subscan"]="https://github.com/zidansec/subscan.git"
    ["info-site"]="https://github.com/king-hacking/info-site.git"
    ["sherlock"]="https://github.com/sherlock-project/sherlock.git"
    ["phoneinfoga"]="https://github.com/sundowndev/phoneinfoga.git"
    ["Breacher"]="https://github.com/s0md3v/Breacher.git"
    ["theHarvester"]="https://github.com/laramies/theHarvester.git"
    ["holehe"]="https://github.com/megadose/holehe.git"
    ["gau"]="https://github.com/lc/gau.git"
    ["nuclei"]="https://github.com/projectdiscovery/nuclei.git"
)

# ==================================================================
# FUNÇÕES UTILITÁRIAS
# ==================================================================

function msg_info() { echo -e "${C_DARK}[${C_BLOOD}*${C_DARK}]${C_RESET} ${C_GHOST}$1${C_RESET}"; }
function msg_ok()   { echo -e "${C_BLOOD}[${C_GHOST}+${C_BLOOD}]${C_RESET} ${C_DRIP}$1${C_RESET}"; }
function msg_err()  { echo -e "${C_BLOOD}[!]${C_RESET} ${C_BLOOD}$1${C_RESET}"; }

function press_enter() {
    echo -e "\n${C_DARK}[${C_BLOOD}*${C_DARK}]${C_RESET} ${C_GHOST}ENTER para voltar ao menu...${C_RESET}"
    read -r
    clear
}

function emergency_exit() {
    echo -e "\n"
    msg_err "RESETANDO FIREWALL E SAINDO..."
    iptables -F 2>/dev/null
    iptables -X 2>/dev/null
    iptables -P OUTPUT ACCEPT 2>/dev/null
    systemctl stop tor >/dev/null 2>&1
    exit 0
}
trap emergency_exit SIGINT SIGTERM

# ==================================================================
# BANNER & SETUP
# ==================================================================

function draw_banner() {
    clear
    echo -e "${C_BLOOD}${BOLD}    _  __      __             _     "
    echo "   / |/ /_  __/ /_____  ____ (_)___ "
    echo "  /    /| |/ /  ' / _ \/ __ \/ / _ \\"
    echo " /_/|_/ |___/_/\_\___/_/ /_/_/_//_/"
    echo -e "   ${C_GHOST}S T E A L T H   S U I T E${C_RESET}\n"
}

function draw_header() {
    local title="$1"
    local ip_display
    if [[ "$USE_STEALTH" == "true" ]]; then
        ip_display="${C_DRIP}● STEALTH ACTIVE${C_RESET} ${C_DARK}|${C_RESET} ${C_GHOST}$(curl -s --max-time 5 --proxy socks5h://127.0.0.1:9050 https://api.ipify.org 2>/dev/null || echo "OFFLINE")${C_RESET}"
    else
        ip_display="${C_YELLOW}○ NORMAL MODE${C_RESET}  ${C_DARK}|${C_RESET} ${C_GHOST}$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "OFFLINE")${C_RESET}"
    fi
    echo -e "${C_BLOOD}────────────────────────────────────────────────────────────${C_RESET}"
    echo -e " ${BOLD}${C_BLOOD}[ $title ]${C_RESET}"
    echo -e " ${C_DARK}STATUS: $ip_display${C_RESET}"
    echo -e "${C_BLOOD}────────────────────────────────────────────────────────────${C_RESET}"
}

function deep_setup() {
    draw_banner
    msg_info "SINCRONIZANDO ARSENAL & REQUERIMENTOS..."
    
    # Requerimentos do sistema
    apt-get update -y -q >/dev/null 2>&1
    apt-get install php proxychains4 tor curl jq dnsutils whois nmap git python3 python3-pip openssl wget unzip -y -q >/dev/null 2>&1
    pip3 install ddgs requests colorama --break-system-packages -q 2>/dev/null

    # Wordlist Rockyou
    if [ ! -f "$ROCKYOU" ]; then
        msg_info "Baixando wordlist rockyou.txt..."
        mkdir -p /usr/share/wordlists
        wget -q https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt -O "$ROCKYOU"
    fi

    # Configuração Proxychains
    if [ ! -f "/etc/proxychains4.conf" ] || ! grep -q "socks5 127.0.0.1 9050" /etc/proxychains4.conf; then
        msg_info "Configurando Proxychains..."
        echo "strict_chain" | sudo tee /etc/proxychains4.conf >/dev/null
        echo "proxy_dns" | sudo tee -a /etc/proxychains4.conf >/dev/null
        echo "[ProxyList]" | sudo tee -a /etc/proxychains4.conf >/dev/null
        echo "socks5 127.0.0.1 9050" | sudo tee -a /etc/proxychains4.conf >/dev/null
    fi

    mkdir -p "$BASE_DIR/Tools"
    local total=${#TOOLS_REPO[@]}
    local current=0
    local bar_len=40

    for tool in "${!TOOLS_REPO[@]}"; do
        ((current++))
        local percent=$(( (current * 100) / total ))
        local filled=$(( (current * bar_len) / total ))
        local empty=$(( bar_len - filled ))
        
        # Barra de carregamento aprimorada
        echo -ne "\r    ${C_GHOST}LOADING ARSENAL: [${C_BLOOD}"
        for ((j=0; j<filled; j++)); do echo -ne "━"; done
        echo -ne "${C_DARK}"
        for ((j=0; j<empty; j++)); do echo -ne "─"; done
        echo -ne "${C_RESET}] ${C_BLOOD}${percent}%${C_RESET} (${C_GHOST}${tool}${C_RESET})      "

        if [ ! -d "$BASE_DIR/Tools/$tool" ]; then
            git clone --depth 1 "${TOOLS_REPO[$tool]}" "$BASE_DIR/Tools/$tool" --quiet >/dev/null 2>&1
        else
            cd "$BASE_DIR/Tools/$tool" && git pull --quiet >/dev/null 2>&1 && cd "$BASE_DIR"
        fi
        chmod -R +x "$BASE_DIR/Tools/$tool" 2>/dev/null
    done
    echo -e "\n"; msg_ok "ARSENAL PRONTO."; sleep 1
}

# ==================================================================
# MÓDULO STEALTH & DIAGNÓSTICO
# ==================================================================

function network_diagnostic() {
    clear; draw_header "NETWORK DIAGNOSTIC"
    msg_info "Coletando informações de rede..."
    local private_ip; private_ip=$(hostname -I | awk '{print $1}')
    local public_ip; public_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "ERROR")
    local tor_ip; tor_ip=$(proxychains4 -q curl -s --max-time 10 https://api.ipify.org 2>/dev/null || echo "OFFLINE")

    echo -e "${C_BLOOD}────────────────────────────────────────────────────────────${C_RESET}"
    echo -e " ${C_GHOST}Private IP (Local) :${C_RESET} ${C_WHITE}${private_ip}${C_RESET}"
    echo -e " ${C_GHOST}Public IP (Real)   :${C_RESET} ${C_WHITE}${public_ip}${C_RESET}"
    echo -e " ${C_GHOST}Tor/Proxy IP       :${C_RESET} ${C_DRIP}${tor_ip}${C_RESET}"
    echo -e "${C_BLOOD}────────────────────────────────────────────────────────────${C_RESET}"

    if [[ "$tor_ip" != "OFFLINE" && "$tor_ip" != "$public_ip" ]]; then
        msg_ok "VERIFICAÇÃO: TÚNEL STEALTH ATIVO ✅"
    elif [[ "$USE_STEALTH" == "true" ]]; then
        msg_err "VERIFICAÇÃO: POSSÍVEL VAZAMENTO DE IP ⚠️"
    fi
    press_enter
}

function select_mode_panel() {
    draw_banner
    echo -e " [1] ${C_BLOOD}PROTOCOLO STEALTH${C_RESET} ${C_DARK}(Tor Killswitch)${C_RESET}"
    echo -e " [2] ${C_YELLOW}MODO NORMAL${C_RESET}"
    echo -e " [3] ${C_CYAN}DIAGNÓSTICO DE REDE${C_RESET}\n"
    read -p ">> " mode_opt

    case "$mode_opt" in
        1)
            USE_STEALTH="true"
            msg_info "Configurando Killswitch Inteligente..."
            systemctl restart tor; sleep 2
            TOR_USER=$(grep -E '^User ' /etc/tor/torrc 2>/dev/null | awk '{print $2}' || echo "debian-tor")
            [[ -z "$TOR_USER" ]] && TOR_USER="debian-tor"

            iptables -F; iptables -X
            iptables -A OUTPUT -o lo -j ACCEPT
            iptables -A OUTPUT -m owner --uid-owner 0 -j ACCEPT
            iptables -A OUTPUT -m owner --uid-owner "$TOR_USER" -j ACCEPT
            iptables -A OUTPUT -p tcp -m owner --uid-owner "$SUDO_USER" --dport 80 -j ACCEPT
            iptables -A OUTPUT -p tcp -m owner --uid-owner "$SUDO_USER" --dport 443 -j ACCEPT
            iptables -A OUTPUT -p udp -m owner --uid-owner "$SUDO_USER" --dport 53 -j ACCEPT
            iptables -P OUTPUT DROP
            msg_ok "STEALTH ATIVADO"
            network_diagnostic
            ;;
        2)
            USE_STEALTH="false"
            iptables -P OUTPUT ACCEPT; iptables -F; iptables -X
            msg_info "MODO NORMAL ATIVO"
            ;;
        3) network_diagnostic; select_mode_panel ;;
        *) select_mode_panel ;;
    esac
}

# ==================================================================
# MÓDULO ARSENAL - FERRAMENTAS EXTERNAS
# ==================================================================

function run_tool() {
    local name=$1; local t_dir=""
    if [ -d "$BASE_DIR/Tools/$name" ]; then
        t_dir="$BASE_DIR/Tools/$name"
    else
        msg_info "Buscando ferramenta..."
        t_dir=$(find / -type d -iname "$name" -not -path "/mnt/*" -not -path "/proc/*" -not -path "/sys/*" 2>/dev/null | head -n 1)
    fi

    if [[ -z "$t_dir" ]]; then msg_err "Ferramenta '$name' não encontrada."; read -p "..."; return; fi
    cd "$t_dir" || return

    local cmd=""
    case "$name" in
        "zphisher"|"CamPhish"|"RED_HAWK") cmd="bash ${name,,}.sh" ;;
        "seeker") cmd="python3 seeker.py" ;;
        "sqlmap") read -p "URL Alvo: " u; cmd="python3 sqlmap.py -u \"$u\" --batch --random-agent" ;;
        "Breacher") read -p "URL Admin: " u; cmd="python3 Breacher.py -u \"$u\"" ;;
        "sherlock") read -p "Username: " u; cmd="python3 sherlock.py \"$u\"" ;;
        "phoneinfoga") read -p "Phone: " p; cmd="python3 phoneinfoga.py -n \"$p\"" ;;
        "theHarvester") read -p "Domain: " d; cmd="python3 theHarvester.py -d \"$d\" -l 500 -b all" ;;
        "dorks-eye") read -p "Dork: " d; cmd="python3 dorkseye.py -d \"$d\"" ;;
        "subscan") read -p "Domain: " d; cmd="python3 subscan.py -d \"$d\"" ;;
        "info-site") read -p "Domain: " d; cmd="bash info.sh \"$d\"" ;;
        "holehe") read -p "Email: " e; cmd="python3 holehe/holehe.py \"$e\"" ;;
        "gau") read -p "Domain: " d; cmd="./gau \"$d\"" ;;
        "nuclei") read -p "Target: " t; cmd="./nuclei -u \"$t\"" ;;
    esac

    [[ "$USE_STEALTH" == "true" ]] && proxychains4 -q $cmd || $cmd
    cd "$BASE_DIR"; read -p "ENTER..."
}

# ==================================================================
# MÓDULO OSINT (NATIVO)
# ==================================================================

function cs_ip_info() {
    clear; draw_header "IP ADDRESS SEARCH"
    read -p "IP Address: " ip; [[ -z "$ip" ]] && return
    msg_info "Consultando IP: $ip..."
    curl -s "https://ipinfo.io/${ip}/json" | jq -r 'to_entries[] | " \(.key): \(.value)"' 2>/dev/null
    press_enter
}

function cs_dns_lookup() {
    clear; draw_header "DNS RECORD SEARCH"
    read -p "Domínio: " domain; [[ -z "$domain" ]] && return
    domain="${domain#http://}"; domain="${domain#https://}"; domain="${domain%%/*}"
    for rtype in A MX NS TXT; do
        echo -e " ${C_DRIP}[+] $rtype:${C_RESET}"
        dig +short "$rtype" "$domain" | sed 's/^/     /'
    done
    press_enter
}

function cs_subdomain_enum() {
    clear; draw_header "SUBDOMAIN SEARCH"
    read -p "Domínio: " domain; [[ -z "$domain" ]] && return
    domain="${domain#http://}"; domain="${domain#https://}"; domain="${domain%%/*}"
    msg_info "Consultando crt.sh..."
    curl -s "https://crt.sh/?q=%.${domain}&output=json" | jq -r '.[].name_value' 2>/dev/null | sort -u | head -20
    press_enter
}

function cs_port_scan() {
    clear; draw_header "PORT SCAN SEARCH"
    read -p "Host / IP: " target; [[ -z "$target" ]] && return
    local ports=(21 22 80 443 3306 8080)
    for port in "${ports[@]}"; do
        if timeout 1 bash -c "echo >/dev/tcp/${target}/${port}" 2>/dev/null; then
            echo -e "  ${C_GREEN}[OPEN]${C_RESET} Porta ${port}"
        else
            echo -e "  ${C_DARK}[CLOSED]${C_RESET} Porta ${port}"
        fi
    done
    press_enter
}

function cs_password_strength() {
    clear; draw_header "PASSWORD ANALYZER"
    read -p "Senha: " password; [[ -z "$password" ]] && return
    local score=0 len=${#password}
    [[ $len -ge 8 ]] && ((score++))
    echo "$password" | grep -q '[A-Z]' && ((score++))
    echo "$password" | grep -q '[0-9]' && ((score++))
    echo -e " Comprimento: $len"
    if [ -f "$ROCKYOU" ]; then
        if grep -qF "$password" "$ROCKYOU"; then
            echo -e " Rockyou Check: ${C_BLOOD}VULNERÁVEL${C_RESET}"
        else
            echo -e " Rockyou Check: ${C_GREEN}LIMPO${C_RESET}"
        fi
    fi
    press_enter
}

# ==================================================================
# MENU PRINCIPAL
# ==================================================================

function main_menu() {
    while true; do
        draw_banner
        local CUR_IP
        if [[ "$USE_STEALTH" == "true" ]]; then
            CUR_IP=$(proxychains4 -q curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "STEALTH - OFFLINE")
            ST_DISP="${C_DRIP}● STEALTH ACTIVE${C_RESET}"
        else
            CUR_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null || echo "OFFLINE")
            ST_DISP="${C_YELLOW}○ NORMAL MODE${C_RESET}"
        fi

        echo -e "${C_BLOOD}────────────────────────────────────────────────────────────${C_RESET}"
        echo -e " PROTOCOLO: ${ST_DISP}  ${C_DARK}|${C_RESET}  IP: ${C_GHOST}${CUR_IP}${C_RESET}"
        echo -e " OPERADOR: ${C_GHOST}${OPERATOR_NAME}${C_RESET}"
        echo -e "${C_BLOOD}────────────────────────────────────────────────────────────${C_RESET}"
        
        echo -e "\n ${BOLD}${C_BLOOD}[ A R S E N A L ]${C_RESET}"
        echo -e "  [1] Phishing (Zphisher, CamPhish, Seeker)"
        echo -e "  [2] Web & Audit (RED_HAWK, SQLMap, Breacher, Nuclei)"
        echo -e "  [3] OSINT Arsenal (Sherlock, PhoneInfoga, Harvester, Gau, Holehe)"

        echo -e "\n ${BOLD}${C_BLOOD}[ C L A T S C O P E ]${C_RESET}"
        echo -e "  [4] IP Info      [5] DNS Lookup   [6] Subdomain Enum"
        echo -e "  [7] Port Scan    [8] Password Check"

        echo -e "\n${C_BLOOD}────────────────────────────────────────────────────────────${C_RESET}"
        echo -e "  [M] Modo    [D] Diagnóstico    [C] Wipe    [0] Sair"
        echo -e "${C_BLOOD}────────────────────────────────────────────────────────────${C_RESET}"

        read -p ">> " opt
        case $opt in
            1) clear; draw_header "PHISHING"; echo -e " [1] Zphisher\n [2] CamPhish\n [3] Seeker\n\n [0] Voltar"; read -p ">> " p; case $p in 1) run_tool "zphisher" ;; 2) run_tool "CamPhish" ;; 3) run_tool "seeker" ;; esac ;;
            2) clear; draw_header "WEB & AUDIT"; echo -e " [1] RED_HAWK\n [2] SQLMap\n [3] Breacher\n [4] Nuclei\n\n [0] Voltar"; read -p ">> " w; case $w in 1) run_tool "RED_HAWK" ;; 2) run_tool "sqlmap" ;; 3) run_tool "Breacher" ;; 4) run_tool "nuclei" ;; esac ;;
            3) clear; draw_header "OSINT ARSENAL"; echo -e " [1] Sherlock\n [2] PhoneInfoga\n [3] theHarvester\n [4] Dorks-Eye\n [5] Subscan\n [6] Gau\n [7] Holehe\n\n [0] Voltar"; read -p ">> " o; case $o in 1) run_tool "sherlock" ;; 2) run_tool "phoneinfoga" ;; 3) run_tool "theHarvester" ;; 4) run_tool "dorks-eye" ;; 5) run_tool "subscan" ;; 6) run_tool "gau" ;; 7) run_tool "holehe" ;; esac ;;
            4) cs_ip_info ;; 5) cs_dns_lookup ;; 6) cs_subdomain_enum ;; 7) cs_port_scan ;; 8) cs_password_strength ;;
            [Mm]) select_mode_panel ;; [Dd]) network_diagnostic ;; [Cc]) rm -rf "$BASE_DIR/Tools" && msg_ok "WIPED." && sleep 2 ;; 0) emergency_exit ;;
        esac
    done
}

if [[ $EUID -ne 0 ]]; then echo -e "Execute como root (sudo)."; exit 1; fi
deep_setup
select_mode_panel
main_menu