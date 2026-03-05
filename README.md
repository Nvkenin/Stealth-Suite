# Stealth Suite v1.0

Framework automatizado para **Auditoria de Segurança**, **Engenharia Social** e **Pentest Web**. Desenvolvido com foco em portabilidade, permitindo operações rápidas via clonagem direta ou em ambientes Kali Linux Live (Wardrive).



## Funcionalidades Principais

- **Cascaded Stealth Mode:** Inicia o serviço Tor e oferece ativação imediata de Kill Switch via IPTables.
- **Kill Switch Hardened:** Bloqueia todo o tráfego IPv4 e IPv6 que não passe pelo túnel do Tor, prevenindo vazamentos acidentais.
- **Auto-Dependency:** Instala automaticamente dependências de sistema (PHP, Python, Git) e bibliotecas de ferramentas específicas.
- **Identity Rotation:** Altera o circuito Tor e o endereço IP público com um único comando.
- **Forense Amigável:** Operação otimizada para rodar em RAM (diretório `/tmp`) se desejado.

## Guia de Uso

### Opção A: Clone Direto (Uso em Máquina Fixa/VM)
Ideal para laboratórios de estudo e análise persistente.
```bash
# Clonar o repositório
git clone https://github.com/nvkenin/stealth-suite.git

# Entrar no diretório e dar permissão de execução
cd stealth-suite
chmod +x stealth-suite.sh

# Executar como root
sudo ./stealth-suite.sh
```
### Opção B: Modo Wardrive (Kali Live USB)

Ideal para auditorias em campo onde não se pode deixar rastros no hardware.

1. Conecte-se à rede alvo (Wi-Fi/Ethernet).

2. Abra o terminal e baixe o script diretamente para a RAM:

```bash
cd /tmp
git clone https://github.com/nvkenin/stealth-suite.git
cd stealth-suite && sudo bash stealth-suite.sh
```

3. Ao finalizar, use a opção [0] Sair para limpar as regras de firewall e parar os serviços.

## Ferramentas Integradas
    
- **Zphisher**: Phishing avançado para testes de Engenharia Social.
- **Sherlock**: Busca OSINT de nomes de usuário em redes sociais.
- **SQLMap**: Detecção e exploração automatizada de falhas de Injeção SQL.
- **Seeker**: Localização geográfica precisa através de links de engenharia social.

# ⚠️Aviso Legal

**Este software foi desenvolvido apenas para fins educacionais e de auditoria de segurança autorizada. O uso desta ferramenta para atacar alvos sem consentimento prévio é ilegal. O desenvolvedor não se responsabiliza pelo uso indevido deste código.**
