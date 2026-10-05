# Ansible Vault med LastPass-integrasjon

## Oversikt

Dette prosjektet bruker LastPass CLI for å sikret håndtere Ansible Vault-passordet. Vault-passordet lagres i LastPass og hentes dynamisk, noe som sikrer at ingen klartekst-passord eksisterer i repositoriet.

## Oppsett

### 1. Innledende LastPass-pålogging

Etter at devcontaineren er startet, logg inn på LastPass:

```bash
lpass-login
```

Dette vil:
- Be om din LastPass-e-post (hvis du ikke allerede er logget inn)
- Autentisere med LastPass
- Sette miljøvariabelen `ANSIBLE_VAULT_PASSWORD_FILE`
- Aktivere transparent tilgang til vault-passordet for alle Ansible-kommandoer

### 2. Verifiser oppsettet

Sjekk at miljøvariabelen er satt:

```bash
echo $ANSIBLE_VAULT_PASSWORD_FILE
# Skal gi: /workspaces/dev-setup/.devcontainer/vault-password-file.sh
```

Test vault-tilgang:

```bash
ansible-vault --version
```

---

## Jobbe med Ansible Vault

Når du har kjørt `lpass-login`, fungerer alle Ansible Vault-kommandoer automatisk uten passord-prompt.

### Vise krypterte filer

Vis innholdet i en kryptert fil:

```bash
ansible-vault view group_vars/all/vault
```

Vis en spesifikk hosts vault:

```bash
ansible-vault view host_vars/host1/vault
```

### Redigere krypterte filer

Rediger en kryptert fil i standardeditoren din:

```bash
ansible-vault edit group_vars/all/vault
```

Dette vil:
1. Dekryptere filen midlertidig
2. Åpne den i editoren din
3. Kryptere den på nytt når du lagrer og lukker

### Opprette nye krypterte filer

Opprett en ny kryptert fil:

```bash
ansible-vault create group_vars/grp2/vault
```

Eller opprett fra en eksisterende klartekst-fil:

```bash
# Opprett først en klartekst-fil
cat > /tmp/secrets.yml << EOF
---
api_key: "my-secret-key"
db_password: "super-secret"
EOF

# Krypter den
ansible-vault encrypt /tmp/secrets.yml
mv /tmp/secrets.yml group_vars/all/vault
```

### Kryptere eksisterende filer

Krypter en klartekst-fil på stedet:

```bash
ansible-vault encrypt host_vars/host1/vault
```

Krypter flere filer:

```bash
ansible-vault encrypt group_vars/*/vault host_vars/*/vault
```

### Dekryptere filer

Dekrypter for å vise i klartekst (bruk med forsiktighet):

```bash
ansible-vault decrypt group_vars/all/vault
```

**Advarsel:** Dette etterlater filen ukryptert. Husk å kryptere den på nytt:

```bash
ansible-vault encrypt group_vars/all/vault
```

### Endre Vault-passord

Hvis vault-passordet endres i LastPass, må du re-kryptere eksisterende krypterte filer:

```bash
# Oppdater alle vault-filer med nytt passord
ansible-vault rekey group_vars/all/vault
ansible-vault rekey group_vars/grp1/vault
ansible-vault rekey host_vars/host1/vault
```

Eller re-krypter alle på én gang:

```bash
find . -path "*/vault" -exec ansible-vault rekey {} \;
```

---

## Kryptere spesifikke variabler

Du kan kryptere individuelle variabler i en klartekst-fil ved å bruke `encrypt_string`:

### Krypter en enkelt variabel

```bash
ansible-vault encrypt_string 'my-secret-value' --name 'my_secret_var'
```

Output:
```yaml
my_secret_var: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653966653431626...
```

Kopier dette inn i vars-filen din.

### Krypter fra prompt

```bash
ansible-vault encrypt_string --name 'db_password'
# Skriv eller lim inn hemmeligheten, trykk deretter Ctrl+D to ganger
```

### Eksempel: Kombinerte krypterte og klartekst-variabler

```yaml
# group_vars/all/vars
---
# Klartekst-variabler
app_name: my-application
app_port: 8080

# Krypterte variabler
db_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653966653431626...

api_key: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          31323334353637383930616...
```

---

## Kjøre playbooks

Med LastPass-integrasjonen kjører playbooks uten spesielle flagg:

```bash
ansible-playbook playbooks/your-playbook.yml
```

### Debugge krypterte variabler

Test at vault-variabler er tilgjengelige:

```bash
ansible-playbook playbooks/debug/show-secrets-all.yml
```

Dette vil vise alle krypterte variabler fra inventaret ditt.

### Kjøre mot spesifikke hosts

```bash
ansible-playbook playbooks/your-playbook.yml --limit host1
ansible-playbook playbooks/your-playbook.yml --limit grp1
```

---

## Vanlige Vault-mønstre

### Mønster 1: Separate krypterte og klartekst-variabler

**Struktur:**
```
group_vars/
  all/
    vars          # Klartekst-variabler
    vault         # Krypterte hemmeligheter
```

**I vars-fil:**
```yaml
# group_vars/all/vars
db_host: "database.example.com"
db_port: 5432
db_user: "app_user"
# Referer til kryptert variabel
db_password: "{{ vault_db_password }}"
```

**I vault-fil:**
```yaml
# group_vars/all/vault
vault_db_password: "faktisk-hemmelig-passord"
vault_api_key: "hemmelig-api-nøkkel"
```

### Mønster 2: Krypterte strenger i klartekst-filer

```yaml
# group_vars/all/vars
db_host: "database.example.com"
db_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          66386439653966653431626...
```

### Mønster 3: Fullt krypterte filer

```yaml
# Hele filen er kryptert
ansible-vault create group_vars/production/vault
```

---

## Feilsøking

### Miljøvariabel ikke satt

Hvis `ANSIBLE_VAULT_PASSWORD_FILE` ikke er satt:

```bash
# Kjør påloggings-skriptet på nytt
source .devcontainer/lpass-login.sh

# Eller bruk funksjonen
lpass-login
```

### LastPass-sesjon utløpt

```bash
# Logg ut og inn igjen
lpass logout
lpass-login
```

### Feil Vault-passord

Hvis du får dekrypteringsfeil:

1. Verifiser at du kan hente passordet:
   ```bash
   lpass show vault-password -p
   ```

2. Sjekk at vault-filen ble kryptert med samme passord:
   ```bash
   ansible-vault view group_vars/all/vault
   ```

3. Om nødvendig, re-krypter filen med riktig passord

### Sjekk gjeldende LastPass-status

```bash
lpass status
```

---

## Sikkerhetspraksis

### ✅ GJØR:
- Kjør alltid `lpass-login` ved start av økten din
- Hold vault-filer i `.gitignore` eller kryptert i Git
- Bruk beskrivende navn for krypterte variabler (prefiks med `vault_`)
- Roter vault-passord regelmessig
- Logg ut av LastPass når du er ferdig: `lpass logout`

### ❌ IKKE GJØR:
- Commit klartekst-hemmeligheter til Git
- Del vault-passord i Slack/e-post
- Dekrypter filer og la dem stå i klartekst
- Lagre vault-passord i shell-historikk

---

## Hurtigreferanse

| Oppgave | Kommando |
|---------|----------|
| Vis kryptert fil | `ansible-vault view FIL` |
| Rediger kryptert fil | `ansible-vault edit FIL` |
| Opprett kryptert fil | `ansible-vault create FIL` |
| Krypter eksisterende fil | `ansible-vault encrypt FIL` |
| Dekrypter fil | `ansible-vault decrypt FIL` |
| Krypter streng | `ansible-vault encrypt_string 'verdi' --name 'var'` |
| Endre vault-passord | `ansible-vault rekey FIL` |
| Kjør playbook | `ansible-playbook playbook.yml` |
| Vis debug-variabler | `ansible-playbook playbooks/debug/show-secrets-all.yml` |

---

## Eksempler

### Eksempel 1: Legg til en ny hemmelighet i gruppe

```bash
# Rediger vault-filen for grp1
ansible-vault edit group_vars/grp1/vault

# Legg til hemmeligheten din:
# ---
# vault_new_api_key: "hemmelig-nøkkel-her"

# Referer til den i vars-filen
echo 'new_api_key: "{{ vault_new_api_key }}"' >> group_vars/grp1/vars
```

### Eksempel 2: Opprett ny host med hemmeligheter

```bash
# Opprett mappe
mkdir -p host_vars/newhost

# Opprett klartekst-variabler
cat > host_vars/newhost/vars << EOF
---
ansible_host: 192.168.1.100
ansible_user: admin
EOF

# Opprett kryptert vault
ansible-vault create host_vars/newhost/vault
# Legg til hemmeligheter i editoren som åpnes:
# ---
# vault_ansible_password: "hemmelig-passord"
# vault_api_key: "hemmelig-nøkkel"
```

### Eksempel 3: Krypter sensitiv streng

```bash
# Generer kryptert streng for et passord
ansible-vault encrypt_string 'MittHemmeligePassord123!' --name 'vault_sudo_password'

# Kopier output inn i vars-filen din
# Referer deretter som: ansible_become_pass: "{{ vault_sudo_password }}"
```

---

## Ytterligere ressurser

- [Offisiell Ansible Vault-dokumentasjon](https://docs.ansible.com/ansible/latest/vault_guide/index.html)
- [LastPass CLI-dokumentasjon](https://github.com/lastpass/lastpass-cli)
- Prosjektets sikkerhetsvurdering: `docs/security-assessment.md`
- Status kritiske fikser: `docs/CRITICAL-FIXES.md`
