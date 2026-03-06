# Nvkenin Stealth Suite 

![License](https://img.shields.io/badge/License-MIT-red.svg)

**Nvkenin Stealth Suite** é um framework avançado de **OSINT**, **Phishing** e **Auditoria Web**, projetado para operadores que exigem anonimato total e eficiência. O suite integra o **Stealth Mode**, garantindo que todo o tráfego seja roteado via rede Tor com um Killswitch ativo para prevenir vazamentos de IP.

---

## Funcionalidades Principais

### Stealth Mode
- **Tor Killswitch:** Bloqueio total de tráfego fora do túnel Tor via IPTables.
- **Network Diagnostic:** Verificação em tempo real de IP Real vs. IP Tor.
- **Proxychains Integration:** Roteamento automático para ferramentas externas.

### Arsenal de Ferramentas (Integrado)
- **Phishing:** Zphisher, CamPhish, Seeker.
- **Web & Audit:** RED_HAWK, SQLMap, Breacher, **Nuclei** (Vulnerability Scanner).
- **OSINT Arsenal:** Sherlock, PhoneInfoga, theHarvester, **Gau** (URL Collector), **Holehe** (Email OSINT).

### OSINT (Nativo)
- **IP Info:** Geolocalização e detalhes de ISP.
- **DNS Lookup:** Registros A, MX, NS, TXT.
- **Subdomain Enum:** Descoberta via certificados CRT.sh.
- **Password Analyzer:** Checagem de força e integração com **Rockyou.txt**.

---

## Instalação e Uso

O script automatiza todas as dependências (apt, pip e git clones).

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/nvkenin-stealth-suite.git
cd Hacking-Tools

# Dê permissão de execução
chmod +x stealth-suite.sh

# Execute como root (necessário para IPTables/Tor)
sudo ./stealth-suite.sh
```

---

## Interface (Design)

O Suite mantém o design clássico **Crimson Protocol**:
- **C_BLOOD:** Vermelho intenso para alertas e títulos.
- **C_GHOST:** Cinza suave para informações.
- **Barra de Carregamento:** Visual aprimorado para sincronização do arsenal.

---

## English Version

**Nvkenin Stealth Suite** is an advanced framework for **OSINT**, **Phishing**, and **Web Auditing**, designed for operators requiring total anonymity.

### Features:
- **Tor Killswitch:** Full traffic blocking outside Tor via IPTables.
- **Network Diagnostics:** Real-time check of Real IP vs. Tor IP.
- **Integrated Arsenal:** Nuclei, Gau, Holehe, SQLMap, Zphisher, and more.
- **Native OSINT:** IP geolocation, DNS lookup, and Rockyou password analysis.

### Quick Start:
1. `chmod +x stealth-suite.sh`
2. `sudo ./stealth-suite.sh`

--- 

## Aviso Legal (Disclaimer)

Este software foi criado exclusivamente para fins educacionais e testes de penetração autorizados. O uso desta ferramenta para atacar alvos sem consentimento prévio é ilegal. O desenvolvedor não se responsabiliza pelo uso indevido deste software.

---
