# Security Assessment Report: dev-env

**Dato:** 6. oktober 2026
**Repository:** git.opdal.net/arne/dev-env
**Vurdert av:** Security Review
**Formål:** Opplæringsmiljø for nettverkskonsulenter i DevOps og nettverksautomasjon

---

## Executive Summary

Samlet sikkerhetsvurdering: **GOD for opplæring** ✅ | **FORBEDRING NØDVENDIG for produksjon** ⚠️

Dette repoet er et **praktisk opplæringsmiljø** for nettverkskonsulenter som trenger trening i DevOps-basert drift og nettverksautomasjon. Vurderingen tar hensyn til:

- 📚 **Pedagogisk verdi** vs. produksjonssikkerhet
- 🎓 **Læringskurve** for personer uten DevOps-erfaring
- 🛡️ **Sikkerhetspraksis** som kan tas med til produksjon
- ⚠️ **Tydelig skille** mellom lab-oppsett og produksjon

Miljøet er bevisst holdt enkelt: ingen eksterne tjenester for hemmeligheter, ingen CI/CD og ingen automatisk publisering. Alt kjører lokalt i en DevContainer.

### 🎯 NÅVÆRENDE STATUS

✅ **GOD OPPLÆRINGSPRAKSIS:**

- Ansible Vault-mønster for hemmeligheter (`vars.yml` + `vault.yml`)
- Pre-commit hooks for kodekvalitet (markdownlint, ansible-lint, filsjekker)
- Conventional Commits validert lokalt ved hver commit
- Omfattende dokumentasjon på norsk (bygges lokalt med Zensical)
- `.gitignore` beskytter `.env` og `.vault_pass`
- Minimal container: kun `git`, `bash-completion`, `ca-certificates` og `libatomic1` installert utover base-imaget

⚠️ **BEVISSTE TRADE-OFFS FOR OPPLÆRING:**

- Ukrypterte vault-filer (kun dummy-verdier, studentene øver selv på kryptering)
- Passwordless sudo i container (praktisk for læring, begrenset til containeren)
- SSH host key checking deaktivert (inventoryet bruker i dag kun `ansible_connection=local`)
- Debug-playbooks som viser hemmeligheter (pedagogisk verktøy, klart merket)
- Unpinned/åpne avhengigheter (får nyeste versjoner)

🚨 **FORBEDRINGER FØR PRODUKSJON:**

- Krypter alle vault-filer og lagre vault-passordet i en passordhåndterer
- Bruk `!vault`-krypterte enkeltverdier og ikke eksporter `ANSIBLE_VAULT_PASSWORD_FILE` permanent, så `ansible-inventory` ikke viser hemmeligheter i klartekst (se [ansible-vault-guide](ansible-vault-guide.md#hvem-kan-se-hemmelighetene))
- Slett debug-playbooks
- Pin Docker-image og Python-pakker
- Aktiver SSH host key checking
- Begrens sudo
- Legg til sårbarhetsskanning

---

## 🎓 OPPLÆRINGSPERSPEKTIV

### ✅ HVA SOM ER BRA FOR OPPLÆRING

#### 1. **Realistisk, men trygt miljø**

- DevContainer isolerer risiko fra vertssystemet
- Inventoryet kjører mot `localhost` (`ansible_connection=local`), så ingen ekte enheter berøres
- Praktisk hands-on erfaring med reelle verktøy
- Feilgjøring har lave konsekvenser (kun containeren påvirkes)

#### 2. **Gode sikkerhetsvaner innebygd**

- **Ansible Vault** viser hvordan man skiller og beskytter hemmeligheter
- **Pre-commit hooks** lærer automatisert kvalitetskontroll
- **Git best practices** med Conventional Commits

#### 3. **Tydelig dokumentasjon**

- Alle verktøy dokumentert på norsk
- Forklarer *hvorfor* ting gjøres på en bestemt måte
- Skiller mellom lab-oppsett og produksjonsanbefalinger

#### 4. **Progressiv læring**

- Starter enkelt (Git, Ansible, Vault i klartekst)
- Bygger opp kompleksitet (kryptering, pre-commit, Conventional Commits)
- Kan utvides med CI/CD og mer avanserte scenarioer senere

### ⚠️ TRADE-OFFS FOR PEDAGOGISK VERDI

| Konfigurasjon | Lab-oppsett | Produksjonsanbefaling | Pedagogisk verdi |
|---------------|-------------|----------------------|------------------|
| Ukrypterte vault-filer | ✅ OK (dummy-verdier) | ❌ Krypter alltid | Lett å se sammenhengen, øve på `encrypt`/`decrypt` |
| `NOPASSWD:ALL` sudo | ✅ OK | ⚠️ Begrens | Friksjonsfritt for eksperimentering |
| `host_key_checking = False` | ✅ OK | ✅ Aktiver på prod-server | Ingen SSH-mål i dag, unngår problemer ved container-rebuild |
| Debug-playbooks | ✅ OK | ❌ Fjern | Viser hvordan variabler fungerer |
| Unpinned packages | ⚠️ Akseptabelt | ❌ Pin alt | Får nyeste versjoner, lettere å starte |

**Viktig:** Alle disse trade-offs er **bevisste valg** for opplæring og er **dokumentert** som ikke-produksjonsklare.

---

## Detaljerte funn

### ✅ POSITIVE SIKKERHETSPRAKSISER

#### 1. **🔒 Ansible Vault-mønster for sensitive data**

- **Status:** ✅ GOOD (for opplæring)
- **Detaljer:** Hemmeligheter ligger i egne vault-filer. I treningsmiljøet er de ukryptert og inneholder kun dummy-verdier.
- **Struktur:**

  ```text
  group_vars/all/vars.yml    # netbox_token: "{{ vault_netbox_token }}"
  group_vars/all/vault.yml   # vault_netbox_token: netbox-token
  ```

- **Hvorfor dette er bra:**
    - Standard Ansible beste praksis
    - Tydelig separasjon mellom offentlige og hemmelige data
    - Studentene oppretter selv `.vault_pass` og øver på `ansible-vault encrypt`/`decrypt`
    - Ingen avhengighet til eksterne passordtjenester i treningsmiljøet
- **Produksjonskrav:** Krypter alle vault-filer, og lagre vault-passordet i en passordhåndterer. Merk at en hel kryptert fil vises i klartekst i `ansible-inventory` når passordet er tilgjengelig; krypter enkeltverdier for å unngå det.
- **Produksjonsverdi:** ⭐⭐⭐⭐⭐ (Industri-standard når filene er kryptert)

#### 2. **🛡️ .gitignore for hemmeligheter**

- **Status:** ✅ GOOD
- **Utdrag:**

  ```text
  # Secrets og credentials
  .env
  .envrc
  .vault_pass

  # Python environment
  .venv
  __pycache__/
  ```

- **Hvorfor dette er bra:**
    - `.env` og `.vault_pass` opprettes lokalt i hver læringsøkt og kan ikke commites ved et uhell
    - Dekker Python-, IDE- og cloud provider-filer
- **Forbedring:** Legg til mønstre for private nøkler (`*.pem`, `*.key`, `id_rsa*`, `id_ed25519*`)
- **Pedagogisk verdi:** Lærer studentene hva som IKKE skal commites

#### 3. **🔨 Pre-commit hooks for kodekvalitet**

- **Status:** ✅ EXCELLENT
- **Konfigurerte hooks:**
    - Filsjekker (trailing whitespace, EOF, YAML-syntaks, store filer, merge-konflikter)
    - Markdown linting (markdownlint)
    - Ansible linting (ansible-lint, `production`-profil, `--strict`)
    - Conventional Commits-validering (`commit-msg`)
- **Installasjon:** Automatisk via `.devcontainer/post-create.sh`
- **Hvorfor dette er bra:**
    - Automatisk kvalitetskontroll før hver commit, uten CI/CD
    - Lærer DevOps beste praksis tidlig
    - Hindrer vanlige feil
- **Begrensning:** Hooks kjører kun lokalt og kan omgås med `git commit --no-verify`. Uten CI finnes ingen sentral kontroll.
- **Pedagogisk verdi:** ⭐⭐⭐⭐⭐ (Introduserer automatisering fra dag 1)

#### 4. **📦 Conventional Commits**

- **Status:** ✅ GOOD
- **Implementasjon:**
    - Commit-meldinger valideres lokalt mot Conventional Commits-formatet
    - Versjonen ligger i `VERSION` og oppdateres manuelt
- **Hvorfor dette er bra:**
    - Lærer moderne Git-workflow
    - Tydelig og lesbar historikk
    - Klargjør for automatisk versjonering og changelog hvis CI/CD innføres senere

#### 5. **🐳 Non-root container-bruker**

- **Status:** ✅ GOOD
- **Implementasjon:**

  ```dockerfile
  USER $USERNAME  # vscode-bruker, ikke root
  ```

- **Hvorfor dette er bra:**
    - Følger Docker security best practices
    - Begrenser skade ved feil eller kompromittering
    - Lærer security-by-default
- **Merk:** Effekten reduseres av passwordless sudo (se lab-konfigurasjoner)

#### 6. **📦 Minimalt base-image**

- **Status:** ✅ GOOD
- **Implementasjon:** `python:3.12-slim` med kun nødvendige pakker:

  ```dockerfile
  RUN apt-get update && apt-get install -y \
      git \
      bash-completion \
      ca-certificates \
      libatomic1 \
      && rm -rf /var/lib/apt/lists/*
  ```

- **Hvorfor dette er bra:**
    - Ingen kompilator/byggverktøy i imaget, redusert angrepsflate
    - Færre pakker å holde oppdatert
    - Raskere builds
- **Merk:** `libatomic1` trengs av Node.js-binæren som pre-commit laster ned for markdownlint

#### 7. **📚 Dokumentasjon på norsk**

- **Status:** ✅ EXCELLENT for målgruppen
- **Dokumentasjon:**
    - Oppsett av PC og Docker-vedlikehold
    - Ansible Vault
    - Git, Git workflows, pre-commit og Conventional Commits
    - Sikkerhetsbetraktninger (denne siden)
- **Bygging:** Lokalt med `zensical serve` / `zensical build`. Ingen automatisk publisering.
- **Hvorfor dette er bra:**
    - Senker terskelen for norske nettverkskonsulenter
    - Forklarer *hvorfor*, ikke bare *hvordan*
    - Dokumentasjon som kode, versjonert sammen med miljøet

---

## ⚠️ LAB-KONFIGURASJONER (OK for opplæring, ikke for produksjon)

### 1. **Ukrypterte vault-filer**

- **Konfigurasjon:** Alle `vault.yml` under `group_vars/` og `host_vars/` ligger i klartekst
- **Innhold:** Kun dummy-verdier (`grp1_password`, `netbox-token` osv.)
- **Hvorfor det er OK i lab:**
    - Ingen ekte hemmeligheter
    - Playbooks fungerer uten vault-passord fra første dag
    - Studentene ser sammenhengen mellom `vars.yml` og `vault.yml` før de krypterer
- **KRAV:** **Krypter alltid vault-filer i miljøer med ekte hemmeligheter!**

#### 📋 Produksjonsanbefaling

```bash
ansible-vault encrypt group_vars/*/vault.yml host_vars/*/vault.yml
```

Vault-passordet hentes fra en passordhåndterer via et skript i `ANSIBLE_VAULT_PASSWORD_FILE`, eller fra hemmelighetslageret til automasjonsplattformen (AAP, Semaphore UI o.l.). Se [Ansible Vault-guiden](ansible-vault-guide.md).

### 2. **Passwordless sudo (NOPASSWD:ALL)**

- **Konfigurasjon:**

  ```dockerfile
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
  ```

- **Risiko i produksjon:** ⚠️ MEDIUM - enhver prosess i containeren kan bli root
- **Hvorfor det er OK i lab:**
    - DevContainer er isolert fra vertssystemet
    - Friksjonsfritt for pakkeinstallasjon og feilsøking
    - Enklere for personer nye til Linux/containere
- **Vurdering:** OK i DevContainer, men dokumenter risikoen

#### 📋 Forbedringer for hardening

```dockerfile
# ALTERNATIV 1: Krev passord (sikrest)
echo $USERNAME ALL=\(root\) ALL > /etc/sudoers.d/$USERNAME

# ALTERNATIV 2: Begrens sudo til spesifikke kommandoer
echo "$USERNAME ALL=(root) NOPASSWD: /usr/bin/apt-get" > /etc/sudoers.d/$USERNAME
```

```json
// ALTERNATIV 3: devcontainer.json
"runArgs": ["--security-opt=no-new-privileges"]
```

### 3. **SSH host key checking deaktivert**

- **Konfigurasjon:**

  ```ini
  # ansible.cfg
  host_key_checking = False
  ```

- **Kontekst:** Inventoryet bruker i dag kun `ansible_connection=local`, så innstillingen har ingen effekt ennå. Den er satt for når studentene senere kobler til lab-enheter over SSH.
- **Hvorfor deaktivert i DevContainer:**
    - Container-rebuild nullstiller `~/.ssh/known_hosts`
    - Lab-enheter bygges ofte på nytt og får nye host keys
    - Pedagogisk fokus på Ansible, ikke SSH-infrastruktur

#### 📋 Produksjonsanbefaling

I produksjon kjøres Ansible fra **dedikerte servere** (AAP/Tower, Semaphore UI, CI-runnere eller en dedikert control node) med persistent filsystem. Der skal host key checking være aktivert:

```ini
# ansible.cfg - PRODUKSJON
[defaults]
host_key_checking = True
```

```bash
# Førstegangsoppsett på produksjonsserver
ssh-keyscan -H target-host >> ~/.ssh/known_hosts
```

### 4. **Debug-playbooks som viser hemmeligheter**

- **Filer:**
    - `playbooks/debug/show-secrets-all.yml`
    - `playbooks/debug/show-vars-localhost.yml`
- **Formål:** 🎓 Pedagogisk - viser at variabler fra vault-filene blir lest riktig, både før og etter kryptering
- **Risiko:** ⚠️ Kan lekke hemmeligheter til terminal/logger
- **Hvorfor det er OK i lab:**
    - Klart navngitt som DEBUG-playbooks
    - Lab har ingen ekte hemmeligheter
- **KRAV:** **FJERN eller beskytt i produksjon!**

#### 📋 Produksjonsanbefaling

```yaml
# ALDRI i produksjon:
- name: Show password
  ansible.builtin.debug:
    msg: "PASSWORD: {{ password }}"  # ❌ IKKE gjør dette!

# Bruk heller:
- name: Test password (no output)
  ansible.builtin.assert:
    that:
      - password is defined
      - password | length > 0
    fail_msg: "Password not configured"
  no_log: true  # ✅ Skjuler output
```

---

## 🚨 FORBEDRINGER FØR PRODUKSJON

Disse endringene er **ikke kritiske for opplæring**, men **nødvendige for produksjon**.

### 1. **Pin Docker base-image (MEDIUM)**

- **Nåværende:**

  ```dockerfile
  FROM python:3.12-slim  # ⚠️ Flytende tag
  ```

- **Risiko:** Imaget kan endres mellom builds
- **Produksjonsfiks:**

  ```dockerfile
  # ANBEFALT: Pin til digest
  FROM python:3.12-slim@sha256:abc123...

  # MINIMUM: Pin til patch-versjon
  FROM python:3.12.7-slim
  ```

### 2. **Pin Python-pakker (MEDIUM)**

- **Nåværende:**

  ```text
  # requirements.txt
  zensical
  ansible-core>=2.19.10,<2.20.0
  ansible-lint
  pre-commit
  ```

- **Risiko:** Uventede endringer ved ny rebuild av containeren
- **Produksjonsfiks:** Lås eksakte versjoner, f.eks. med `pip freeze > requirements.txt` eller `pip-compile`
- **Hvorfor ikke gjort ennå:** Studentene får nyeste versjoner automatisk

### 3. **Sårbarhetsskanning av avhengigheter (LAV-MEDIUM)**

- **Nåværende:** Ingen automatisk skanning
- **Uten CI/CD:** Kjør manuelt i containeren ved jevne mellomrom:

  ```bash
  pip install pip-audit
  pip-audit -r requirements.txt
  ```

  ```bash
  # Skann container-imaget (fra verten)
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
    aquasec/trivy image <devcontainer-image>
  ```

- **Med CI/CD:** Legg de samme stegene inn i pipelinen, og vurder [Renovate](https://docs.renovatebot.com/) for automatiske oppdateringer. Renovate fungerer med de fleste Git-plattformer, også selvhostede.

### 4. **Secrets-skanning (LAV)**

- **Nåværende:** Kun `.gitignore` og manuell gjennomgang
- **Anbefaling:** Legg til en pre-commit hook, så den kjører lokalt uten CI:

  ```yaml
  # .pre-commit-config.yaml
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2
    hooks:
      - id: gitleaks
  ```

- **Merk:** Med dummy-verdier i klartekst i vault-filene vil en slik skanner trenge unntak for `vault.yml` i treningsmiljøet.

### 5. **Dokumenter sikkerhetsunntak (LAV)**

- **Anbefaling:** Opprett `SECURITY.md` som lister lab-konfigurasjonene som ikke er produksjonsklare, og en sjekkliste for produksjon (se under).

---

## 🎯 SIKKERHETSPRAKSIS FOR OPPLÆRING

### ✅ HVA STUDENTENE LÆRER

1. **Hemmelighetshåndtering:**
    - Ansible Vault-mønsteret (`vars.yml` + `vault.yml`)
    - Kryptering og dekryptering med `ansible-vault`
    - Vault-passord i lokal fil (`.vault_pass`) og miljøvariabel
    - `.gitignore` for å hindre lekkasje av hemmeligheter
    - At produksjon krever passordhåndterer og krypterte filer

2. **Automatisert kodekvalitet:**
    - Pre-commit hooks
    - Markdown- og Ansible-linting
    - Conventional Commits for ryddig historikk

3. **DevOps-arbeidsflyt:**
    - Git best practices, fork & branch-workflows
    - Infrastructure as Code (Ansible)
    - Documentation as Code (Zensical)

4. **Grunnleggende containersikkerhet:**
    - Non-root brukere
    - Minimale base-images
    - Rydding av apt-cache i imaget
    - SSH agent forwarding

### ⚠️ HVA SOM MÅ ENDRES FOR PRODUKSJON

1. **Hemmeligheter:**

   ```bash
   ansible-vault encrypt group_vars/*/vault.yml host_vars/*/vault.yml
   ```

2. **Ansible-hardening:**

   ```ini
   # ansible.cfg - PRODUKSJON
   [defaults]
   host_key_checking = True
   retry_files_enabled = False

   [privilege_escalation]
   become_ask_pass = True
   ```

3. **Container-hardening:**

   ```dockerfile
   FROM python:3.12.7-slim@sha256:abc...
   RUN echo "$USERNAME ALL=(root) /usr/bin/apt-get" > /etc/sudoers.d/$USERNAME
   ```

4. **Låste avhengigheter:**

   ```text
   # requirements.txt - PRODUKSJON
   ansible-core==2.19.10
   ansible-lint==25.11.0
   pre-commit==4.0.1
   zensical==0.0.67
   ```

5. **Fjern debug-verktøy:**

   ```bash
   rm -rf playbooks/debug/
   ```

---

## 📋 SIKKERHETSSJEKKLISTE

### 🎓 Opplæringsmiljø (nåværende status)

| Punkt | Status | Vurdering |
|-------|--------|-----------|
| Ansible Vault-struktur | ✅ Implementert | Production-ready mønster |
| Krypterte vault-filer | ⚠️ Ukryptert | **OK for lab, IKKE produksjon** |
| `.gitignore` for `.env` / `.vault_pass` | ✅ Implementert | Production-ready |
| `.gitignore` for private nøkler | ⚠️ Mangler | Anbefalt å legge til |
| Pre-commit hooks | ✅ Implementert | Kun lokalt, kan omgås |
| Conventional Commits | ✅ Implementert | Validert lokalt |
| Non-root container-bruker | ✅ Implementert | Production-ready |
| Minimalt container-image | ✅ Implementert | Ingen byggverktøy |
| Norsk dokumentasjon | ✅ Implementert | Utmerket for målgruppen |
| SSH host key checking | ⚠️ Deaktivert | **Ingen effekt i dag (kun local)** |
| Passwordless sudo | ⚠️ Aktivert | **OK for lab, IKKE produksjon** |
| Debug-playbooks | ⚠️ Inkludert | **OK for læring, IKKE produksjon** |
| Låste avhengigheter | ⚠️ Mangler | **Må fikses før produksjon** |
| Sårbarhetsskanning | ⚠️ Mangler | **Anbefalt for produksjon** |
| CI/CD | ➖ Ikke i bruk | Bevisst utelatt i treningsversjonen |

### 🏢 Produksjonsmiljø (nødvendige endringer)

| Punkt | Prioritet | Tiltak |
|-------|-----------|--------|
| Krypter alle vault-filer | HIGH | `ansible-vault encrypt` + passordhåndterer |
| Slett debug-playbooks | HIGH | `rm -rf playbooks/debug/` |
| Gjennomgå alle hemmeligheter | HIGH | Erstatt dummy-verdier, roter passord |
| Aktiver SSH host key checking | MEDIUM | `host_key_checking = True` på kontrollnoden |
| Fjern/begrens passwordless sudo | MEDIUM | Endre `Dockerfile` |
| Pin Docker-image | MEDIUM | Endre `Dockerfile` |
| Pin Python-pakker | MEDIUM | Endre `requirements.txt` |
| Sårbarhetsskanning | MEDIUM | `pip-audit` / Trivy, manuelt eller i CI |
| Branch protection på Git-serveren | MEDIUM | Krev merge request og godkjenning for `main` |
| Secrets-skanning | LOW | gitleaks som pre-commit hook |
| `.gitignore` for private nøkler | LOW | Legg til `*.pem`, `*.key`, `id_rsa*`, `id_ed25519*` |
| Opprett `SECURITY.md` | LOW | Dokumenter sikkerhetspolicy |

---

## 🎓 LÆRINGSVERDI vs. SIKKERHET

✅ **Pedagogisk tilgjengelighet:**

- Ingen eksterne kontoer eller tjenester trengs for å komme i gang
- Studentene fokuserer på Ansible og automatisering, ikke SSH- eller passordtjeneste-feilsøking
- Hands-on erfaring med verktøy som brukes i produksjon

✅ **Sikkerhetsvaner:**

- Hemmelighetshåndtering fra dag 1 (Ansible Vault)
- Automatisert kodekvalitet (pre-commit)
- Moderne Git-workflow (Conventional Commits)
- Sikkerhetsbetraktninger dokumentert tydelig

✅ **Realistisk progresjon:**

- Starter trygt i isolert DevContainer mot `localhost`
- Kryptering, CI/CD og hardening kan innføres steg for steg
- Tydelig vei fra lab til produksjon

### Anbefalinger for instruktør

1. **Kommuniser tydelig:**

   ```text
   "Dette er et lab-miljø. I produksjon:
   - Krypter alle vault-filer, passordet ligger i en passordhåndterer
   - Slett debug-playbooks
   - Aktiver SSH host key checking på kontrollnoden
   - Fjern passwordless sudo
   - Pin alle avhengigheter"
   ```

2. **Inkluder produksjonsøvelse:**
    - La studentene kryptere vault-filene som en del av kurset
    - La studentene "herde" miljøet som sluttoppgave
    - Sammenlign lab-config og prod-config side ved side

3. **Bruk eksisterende dokumentasjon:**
    - [Ansible Vault](ansible-vault-guide.md) for hemmelighetshåndtering
    - [Pre-commit](pre-commit-guide.md) for kodekvalitet
    - Denne siden for full oversikt

---

## 🏆 KONKLUSJON

### Opplæringsmiljø: ⭐⭐⭐⭐⭐

**Dette er et godt opplæringsmiljø** som:

- Lærer hemmelighetshåndtering med Ansible Vault
- Introduserer moderne DevOps-praksis (pre-commit, Conventional Commits, dokumentasjon som kode)
- Kan brukes uten eksterne tjenester eller kontoer
- Balanserer pedagogikk med sikkerhet
- Kommuniserer tydelig forskjellen mellom lab og produksjon

**Akseptable trade-offs for læring:**

- ⚠️ Ukrypterte vault-filer (kun dummy-verdier)
- ⚠️ Passwordless sudo i containeren
- ⚠️ SSH host key checking deaktivert
- ⚠️ Debug-playbooks
- ⚠️ Åpne pakkeversjoner

### Produksjonsmiljø: ⚠️ (krever hardening)

**Risikonivå:** LAV for lab, MEDIUM-HIGH for produksjon før hardening

**Nødvendige endringer:** Se "Sikkerhetssjekkliste - Produksjonsmiljø"

**Estimert innsats:** 2-4 timer for alle HIGH/MEDIUM-punkter

---

## 📚 TILLEGGSDOKUMENTASJON

- [Ansible Vault](ansible-vault-guide.md) - hemmelighetshåndtering
- [Pre-commit](pre-commit-guide.md) - automatisert kodekvalitet
- [Conventional Commits](conventional-commits.md) - commit-format

---

**Sist oppdatert:** 6. oktober 2026
**Neste review:** Ved oppgradering til produksjon eller innføring av CI/CD
