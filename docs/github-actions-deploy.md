# GitHub Actions - Deploy MkDocs til Egen Server

## Oversikt

Dette prosjektet bruker GitHub Actions for å automatisk bygge og deploye MkDocs-dokumentasjonen til din egen server hver gang det gjøres endringer i dokumentasjonen. Dette sikrer at dokumentasjonen alltid er oppdatert uten manuell inngripen.

## Hvordan det fungerer

Workflowen (`.github/workflows/deploy-docs.yml`) kjører automatisk når:

1. **Du pusher til main-branchen** og endringer påvirker:
    - Filer i `docs/`-mappen
    - `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`
    - `mkdocs.yml` (konfigurasjonsfil)
    - `requirements-docs.txt` (Python-avhengigheter)
    - Selve workflow-filen

2. **Manuell kjøring** via GitHub's "Actions" tab (workflow_dispatch)

## Workflow-stegene

### 1. Checkout repository

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
  with:
    fetch-depth: 0  # Full history for git-revision-date-localized plugin
```

Henter hele repository-historikken. `fetch-depth: 0` trengs hvis du bruker plugins som viser sist-endret-dato basert på Git-historikk.

### 2. Sett opp Python

```yaml
- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: '3.11'
    cache: 'pip'
```

Installerer Python 3.11 og cacher pip-pakker for raskere kjøring.

### 3. Installer avhengigheter

```yaml
- name: Install dependencies
  run: |
    pip install -r requirements-docs.txt
```

Installerer MkDocs og alle plugins definert i `requirements-docs.txt`.

### 4. Bygg dokumentasjonen

```yaml
- name: Build documentation
  run: |
    mkdocs build --clean --verbose
```
Bygger statiske HTML-filer fra Markdown-dokumentasjonen. Resultatet plasseres i `site/`-mappen.

### 5. Valider deployment-secrets

```yaml
- name: Validate deployment secrets
  run: |
    if [ -z "${{ secrets.DEPLOY_HOST }}" ]; then
      echo "❌ Error: DEPLOY_HOST secret is not set"
      exit 1
    fi
    # ...validerer alle påkrevde secrets
```

Sjekker at alle nødvendige secrets er konfigurert før deployment kjøres.

### 6. Deploy til server via rsync

```yaml
- name: Deploy to server via rsync
  uses: burnett01/rsync-deployments@6.0.0
  with:
    switches: -avz --delete --exclude='.git' --exclude='.DS_Store'
    path: site/
    remote_path: ${{ secrets.DEPLOY_PATH }}
    remote_host: ${{ secrets.DEPLOY_HOST }}
    remote_port: ${{ secrets.DEPLOY_PORT }}
    remote_user: ${{ secrets.DEPLOY_USER }}
    remote_key: ${{ secrets.DEPLOY_KEY }}
```

Bruker rsync til å synkronisere de byggede filene til din server:

- `-avz`: Archive mode, verbose, komprimering
- `--delete`: Fjerner filer på serveren som ikke lenger eksisterer lokalt
- `--exclude`: Ignorerer Git- og systemfiler

### 7. Deployment-oppsummering

```yaml
- name: Deployment summary
  run: |
    echo "✅ Documentation deployed successfully!"
    echo "📍 Server: ${{ secrets.DEPLOY_HOST }}"
```
Viser en oppsummering av deploymentet.

---

## Repository Secrets

For at workflowen skal fungere, må du konfigurere følgende secrets i GitHub-repositoryet ditt.

### Hvor legger du inn secrets?

1. Gå til ditt GitHub-repository
2. Klikk på **Settings**
3. I venstremenyen, velg **Secrets and variables** → **Actions**
4. Klikk på **New repository secret**

### Påkrevde secrets

| Secret Name | Beskrivelse | Eksempel |
|-------------|-------------|----------|
| `DEPLOY_HOST` | Hostname eller IP til serveren din | `docs.example.com` eller `192.168.1.100` |
| `DEPLOY_USER` | Brukernavn for SSH-tilgang | `deploy` eller `www-data` |
| `DEPLOY_PATH` | Full sti til webserver-mappen på serveren | `/var/www/html/docs` |
| `DEPLOY_PORT` | SSH-port (valgfri, default: 22) | `22` eller `2222` |
| `DEPLOY_KEY` | Privat SSH-nøkkel for autentisering | (se nedenfor) |

### Hvordan generere og konfigurere SSH-nøkkel

#### 1. Generer et SSH-nøkkelpar (på din lokale maskin)

```bash
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github_deploy_key
```

Dette genererer to filer:

- `github_deploy_key` (privat nøkkel - brukes i GitHub secret)
- `github_deploy_key.pub` (offentlig nøkkel - legges på serveren)

**Viktig:** Ikke sett passord på nøkkelen siden GitHub Actions trenger å bruke den automatisk.

#### 2. Legg til offentlig nøkkel på serveren

Logg inn på serveren og legg til den offentlige nøkkelen:

```bash
# På serveren
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Legg til offentlig nøkkel
cat >> ~/.ssh/authorized_keys << 'EOF'
ssh-ed25519 AAAAC3Nza... github-actions-deploy
EOF

chmod 600 ~/.ssh/authorized_keys
```

#### 3. Legg til privat nøkkel som GitHub Secret

```bash
# På din lokale maskin - kopier innholdet av privat nøkkel
cat ~/.ssh/github_deploy_key
```

Kopier **hele** innholdet (inkludert `-----BEGIN OPENSSH PRIVATE KEY-----` og `-----END OPENSSH PRIVATE KEY-----`) og legg det inn som `DEPLOY_KEY`-secret i GitHub.

#### 4. Test SSH-tilkoblingen

Test at nøkkelen fungerer:

```bash
ssh -i ~/.ssh/github_deploy_key brukernavn@din-server.com
```

Hvis dette fungerer, er du klar!

---

## Eksempel på secret-konfigurasjon

For et typisk oppsett:

```
DEPLOY_HOST:   docs.opdal.net
DEPLOY_USER:   deploy
DEPLOY_PATH:   /var/www/html/docs
DEPLOY_PORT:   22
DEPLOY_KEY:    -----BEGIN OPENSSH PRIVATE KEY-----
               b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9...
               ...hele den private nøkkelen...
               -----END OPENSSH PRIVATE KEY-----
```

---

## Webserver-oppsett

### Nginx eksempel

For å serve dokumentasjonen med Nginx:

```nginx
server {
    listen 80;
    server_name docs.example.com;

    root /var/www/html/docs;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Valgfritt: SSL/TLS med Let's Encrypt
    # listen 443 ssl;
    # ssl_certificate /etc/letsencrypt/live/docs.example.com/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/docs.example.com/privkey.pem;
}
```

Aktiver konfigurasjonen:

```bash
sudo ln -s /etc/nginx/sites-available/docs /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Apache eksempel

For Apache:

```apache
<VirtualHost *:80>
    ServerName docs.example.com
    DocumentRoot /var/www/html/docs

    <Directory /var/www/html/docs>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/docs-error.log
    CustomLog ${APACHE_LOG_DIR}/docs-access.log combined
</VirtualHost>
```

Aktiver:

```bash
sudo a2ensite docs.conf
sudo systemctl reload apache2
```

---

## Overvåke deployments

### Se status i GitHub

1. Gå til **Actions** tab i ditt repository
2. Se alle kjøringer av "Deploy Documentation"
3. Klikk på en kjøring for detaljert logg

### Feilsøking

#### Deployment feiler med "Permission denied"

**Problem:** SSH-nøkkelen er ikke konfigurert riktig.

**Løsning:**

1. Verifiser at den offentlige nøkkelen er i `~/.ssh/authorized_keys` på serveren
2. Sjekk at filrettigheter er korrekte:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

#### Filer finnes ikke på serveren etter deployment

**Problem:** `DEPLOY_PATH` peker til feil mappe.

**Løsning:**

1. Logg inn på serveren og sjekk at mappen eksisterer
2. Verifiser at brukeren har skrivetilgang:
   ```bash
   ls -la /var/www/html/
   ```

#### Build feiler med "Module not found"

**Problem:** Manglende avhengighet i `requirements-docs.txt`.

**Løsning:**

1. Sjekk at alle MkDocs-plugins er listet i `requirements-docs.txt`
2. Test lokalt med:
   ```bash
   pip install -r requirements-docs.txt
   mkdocs build
   ```

---

## Manuell kjøring

Du kan kjøre workflowen manuelt:

1. Gå til **Actions** tab
2. Velg "Deploy Documentation"
3. Klikk på **Run workflow**
4. Velg branch (vanligvis `main`)
5. Klikk **Run workflow**

Dette er nyttig for:

- Teste deployment etter secret-endringer
- Re-deploye uten å måtte pushe nye endringer
- Feilsøking

---

## Sikkerhet

### Best practices

✅ **GJØR:**

- Bruk dedikert deploy-bruker med begrenset tilgang
- Begrens SSH-nøkkelens tilgang til kun nødvendige mapper
- Roter SSH-nøkler regelmessig
- Bruk SSH-port forwarding eller firewall-regler for ekstra sikkerhet

❌ **IKKE GJØR:**

- Bruk root-bruker for deployment
- Del SSH-nøkler mellom prosjekter
- Commit private nøkler til Git
- Gi deploy-brukeren sudo-tilgang

### Begrense SSH-tilgang

Du kan begrense hva deploy-nøkkelen kan gjøre ved å legge til restriksjoner i `authorized_keys`:

```bash
# I ~/.ssh/authorized_keys på serveren
command="rsync --server -vlogDtprze.iLsfxCIvu --delete . /var/www/html/docs",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAAC3Nza... github-actions-deploy
```

Dette tillater kun rsync til den spesifikke mappen.

---

## Ytterligere ressurser

- [GitHub Actions dokumentasjon](https://docs.github.com/en/actions)
- [MkDocs dokumentasjon](https://www.mkdocs.org/)
- [rsync-deployments action](https://github.com/Burnett01/rsync-deployments)
- [GitHub Secrets dokumentasjon](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
