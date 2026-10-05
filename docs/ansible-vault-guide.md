# Ansible Vault

## Oversikt

Ansible Vault brukes til å kryptere hemmeligheter (passord, API-nøkler, tokens) slik at de kan lagres trygt i Git.

I dette treningsmiljøet ligger vault-filene **ukryptert** (`vault.yml`), slik at alt fungerer uten passord fra første dag. Det gjør det enkelt å se hvordan variablene henger sammen, og å øve på kryptering og dekryptering selv.

!!! warning "Kun for trening"
    Ukrypterte vault-filer er greit i et lab-miljø uten ekte hemmeligheter. I produksjon skal vault-filene alltid være kryptert, og vault-passordet skal ligge i en passordhåndterer, ikke i repoet.

## Struktur

Hemmeligheter ligger i egne `vault.yml`-filer, og refereres fra `vars.yml` med prefikset `vault_`:

```text
group_vars/
  all/
    vars.yml      # Klartekst-variabler
    vault.yml     # Hemmeligheter (ukryptert i trening)
  grp1/
    vars.yml
    vault.yml
host_vars/
  host1/
    vars.yml
    vault.yml
```

**I vars-fil:**

```yaml
# group_vars/all/vars.yml
netbox_token: "{{ vault_netbox_token }}"
```

**I vault-fil:**

```yaml
# group_vars/all/vault.yml
vault_netbox_token: netbox-token
```

Med dette mønsteret kan du alltid se *hvilke* variabler som finnes (`grep` i `vars.yml`), selv når vault-filen er kryptert.

---

## Sette opp et vault-passord

For å kryptere trenger Ansible et vault-passord. I treningsmiljøet legger vi det i en lokal fil, `.vault_pass`, som allerede står i `.gitignore` og derfor aldri blir commitet.

```bash
# Lag passordfilen (velg ditt eget passord)
echo 'mitt-trenings-passord' > .vault_pass
chmod 600 .vault_pass

# Fortell Ansible hvor passordet ligger
export ANSIBLE_VAULT_PASSWORD_FILE=$PWD/.vault_pass
```

Legg gjerne `export`-linjen i `.env` (også i `.gitignore`) og last den inn med `source .env` når du starter en ny terminal.

Verifiser oppsettet:

```bash
echo $ANSIBLE_VAULT_PASSWORD_FILE
```

Alternativt kan du la Ansible spørre om passordet hver gang med `--ask-vault-pass`:

```bash
ansible-vault view group_vars/all/vault.yml --ask-vault-pass
```

---

## Jobbe med Ansible Vault

### Kryptere eksisterende filer

Krypter en vault-fil på stedet:

```bash
ansible-vault encrypt host_vars/host1/vault.yml
```

Krypter alle vault-filene:

```bash
ansible-vault encrypt group_vars/*/vault.yml host_vars/*/vault.yml
```

Åpne filen etterpå, så ser du at innholdet starter med `$ANSIBLE_VAULT;1.1;AES256`.

### Vise krypterte filer

```bash
ansible-vault view group_vars/all/vault.yml
```

### Redigere krypterte filer

```bash
ansible-vault edit group_vars/all/vault.yml
```

Dette vil:

1. Dekryptere filen midlertidig
2. Åpne den i editoren din
3. Kryptere den på nytt når du lagrer og lukker

### Opprette nye krypterte filer

```bash
ansible-vault create group_vars/grp2/vault.yml
```

### Dekryptere filer

Gå tilbake til klartekst (for eksempel for å nullstille treningsmiljøet):

```bash
ansible-vault decrypt group_vars/*/vault.yml host_vars/*/vault.yml
```

### Endre vault-passord

Bytt passord på krypterte filer:

```bash
ansible-vault rekey group_vars/all/vault.yml
```

Eller alle på én gang:

```bash
find . -name vault.yml -not -path './.ansible/*' -exec ansible-vault rekey {} \;
```

Husk å oppdatere `.vault_pass` med det nye passordet etterpå.

---

## Kryptere spesifikke variabler

Du kan kryptere individuelle variabler i en klartekst-fil med `encrypt_string`:

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

Da havner ikke hemmeligheten i shell-historikken.

---

## Kjøre playbooks

Så lenge vault-filene er ukryptert, kjører playbooks uten spesielle flagg:

```bash
ansible-playbook playbooks/debug/show-secrets-all.yml
```

Når filene er kryptert, må Ansible ha passordet. Det får den automatisk hvis `ANSIBLE_VAULT_PASSWORD_FILE` er satt, ellers bruker du:

```bash
ansible-playbook playbooks/debug/show-secrets-all.yml --ask-vault-pass
```

### Kjøre mot spesifikke hosts

```bash
ansible-playbook playbooks/debug/show-secrets-all.yml --limit host1
ansible-playbook playbooks/debug/show-secrets-all.yml --limit grp1
```

---

## Feilsøking

### "Attempting to decrypt but no vault secrets found"

Filen er kryptert, men Ansible har ikke fått passordet. Sett `ANSIBLE_VAULT_PASSWORD_FILE` eller bruk `--ask-vault-pass`.

### "Decryption failed"

Passordet stemmer ikke med det filen ble kryptert med. Sjekk innholdet i `.vault_pass`, eller dekrypter med `--ask-vault-pass` og riktig passord.

### "The vault password file ... was not found"

`ANSIBLE_VAULT_PASSWORD_FILE` peker på en fil som ikke finnes. Lag filen, eller fjern variabelen:

```bash
unset ANSIBLE_VAULT_PASSWORD_FILE
```

---

## Sikkerhetspraksis

### Gjør

- Hold vault-filer kryptert i Git i alle miljøer med ekte hemmeligheter
- Bruk beskrivende navn for hemmelige variabler (prefiks med `vault_`)
- Lagre vault-passordet i en passordhåndterer i produksjon
- Roter vault-passord regelmessig

### Ikke gjør

- Commit klartekst-hemmeligheter fra ekte miljøer til Git
- Commit `.vault_pass` eller `.env`
- Del vault-passord i Slack/e-post
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
| Kjør playbook med passord-prompt | `ansible-playbook playbook.yml --ask-vault-pass` |
| Vis debug-variabler | `ansible-playbook playbooks/debug/show-secrets-all.yml` |

---

## Øvelser

### Øvelse 1: Krypter og dekrypter

```bash
# Se på verdiene i klartekst
ansible-playbook playbooks/debug/show-secrets-all.yml

# Krypter alle vault-filene
ansible-vault encrypt group_vars/*/vault.yml host_vars/*/vault.yml

# Kjør samme playbook igjen - verdiene er de samme
ansible-playbook playbooks/debug/show-secrets-all.yml

# Gå tilbake til klartekst
ansible-vault decrypt group_vars/*/vault.yml host_vars/*/vault.yml
```

### Øvelse 2: Legg til en ny hemmelighet i en gruppe

```bash
# Legg til hemmeligheten i vault-filen
echo 'vault_new_api_key: "hemmelig-nøkkel-her"' >> group_vars/grp1/vault.yml

# Referer til den i vars-filen
echo 'new_api_key: "{{ vault_new_api_key }}"' >> group_vars/grp1/vars.yml
```

### Øvelse 3: Opprett ny host med kryptert vault

```bash
mkdir -p host_vars/newhost

cat > host_vars/newhost/vars.yml << EOF
---
ansible_host: 192.168.1.100
ansible_user: admin
EOF

ansible-vault create host_vars/newhost/vault.yml
# Legg til hemmeligheter i editoren som åpnes:
# ---
# vault_ansible_password: "hemmelig-passord"
```

---

## Ytterligere ressurser

- [Offisiell Ansible Vault-dokumentasjon](https://docs.ansible.com/ansible/latest/vault_guide/index.html)
- Prosjektets sikkerhetsvurdering: [security-assessment](security-assessment.md)
