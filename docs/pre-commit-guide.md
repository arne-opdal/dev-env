# Pre-commit Hooks

## Oversikt

Dette prosjektet bruker [pre-commit](https://pre-commit.com/) for å automatisk sjekke kodekvalitet før commits. Pre-commit kjører automatisk linters og formatters for Markdown og Ansible-filer.

## Hva er pre-commit?

Pre-commit er et rammeverk for å administrere og vedlikeholde multi-language pre-commit hooks. Det kjører spesifiserte verktøy automatisk før hver git commit, og stopper committen hvis det finnes feil.

Pre-commit kjører lokalt på maskinen og konfigurasjonen er den samme uavhengig om man bruker GitHub, GitLab eller BitBucket som git server. Om pre-commit skal integreres i "pipeline" på serversiden må det gjøres på den spesifike måten platformen løser det.

## Installerte hooks

### 1. Generelle fil-sjekker

- **Trailing whitespace** - Fjerner mellomrom på slutten av linjer
- **End of file fixer** - Sikrer at filer slutter med newline
- **YAML syntax** - Validerer YAML-syntaks
- **Large files** - Advarer om store filer (>1MB)
- **Merge conflicts** - Sjekker for merge conflict markers
- **Mixed line endings** - Fikser blandede linjeskift

### 2. Markdown linting (markdownlint)
Sjekker og fikser Markdown-formatering:

- Konsistent formatering
- Riktig overskriftsstruktur
- Lenkevalidering
- Kodeblokk-formatering

**Disabled regler:**

- `MD013`: Line length (kan være for streng for dokumentasjon)
- `MD033`: Inline HTML (nyttig i dokumentasjon)
- `MD041`: First line heading (ikke alltid nødvendig)

### 3. Ansible linting (ansible-lint)

Sjekker Ansible playbooks og roller:

- Best practices
- Syntaksfeil
- Deprecated features
- Sikkerhetsproblemer
- YAML-formatering

**Profil:** `production` - Strenge regler for produksjonsklar kode

## Bruk

### Automatisk kjøring

Pre-commit kjøres automatisk når du gjør en commit:

```bash
git add .
git commit -m "Din commit-melding"
```

Hvis det finnes feil:

- Pre-commit vil prøve å fikse det som kan fikses automatisk
- Feil som må fikses manuelt vil bli rapportert
- Committen avbrytes til alle feil er fikset

### Manuell kjøring

Kjør på alle filer:

```bash
pre-commit run --all-files
```

Kjør på spesifikke filer:

```bash
pre-commit run --files docs/index.md playbooks/debug/*.yml
```

Kjør en spesifikk hook:

```bash
# Kun markdownlint
pre-commit run markdownlint --all-files

# Kun ansible-lint
pre-commit run ansible-lint --all-files
```

### Hopp over pre-commit

Hvis du må committe uten å kjøre hooks (ikke anbefalt):

```bash
git commit -m "Melding" --no-verify
```

## Oppdatering av hooks

Pre-commit oppdaterer ikke automatisk hook-versjonene. For å oppdatere:

```bash
# Oppdater til nyeste versjoner
pre-commit autoupdate

# Sjekk hva som endret seg
git diff .pre-commit-config.yaml
```

## Konfigurasjonsfiler

### .pre-commit-config.yaml

Hovedkonfigurasjon for pre-commit hooks:

```yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      # ...
```

### .markdownlint.yaml

Konfigurasjon for Markdown linting:

```yaml
default: true
MD013: false  # Disable line length
MD033: false  # Allow inline HTML
```

### .ansible-lint

Konfigurasjon for Ansible linting:

```yaml
profile: production
exclude_paths:
  - .github/
  - docs/
skip_list:
  # Add rules to skip here
```

## Tilpasse regler

### Skru av en Markdown-regel

Rediger `.markdownlint.yaml`:

```yaml
# Skru av MD024 (duplicate heading)
MD024: false
```

### Skru av en Ansible-regel

Rediger `.ansible-lint`:

```yaml
skip_list:
  - yaml[line-length]
  - name[casing]
```

### Legge til nye hooks

Rediger `.pre-commit-config.yaml` og legg til nye repos:

```yaml
repos:
  # ...eksisterende repos

  # Nytt repo
  - repo: https://github.com/username/repo
    rev: v1.0.0
    hooks:
      - id: hook-id
```

Kjør deretter:

```bash
pre-commit install
```

## Eksempler på bruk

### Scenario 1: Commit med automatiske fikser

```bash
$ git add docs/new-guide.md
$ git commit -m "Add new guide"

Trim trailing whitespace....................................Passed
Fix end of files.............................................Failed
- hook id: end-of-file-fixer
- exit code: 1
- files were modified by this hook

Fixing docs/new-guide.md

Lint Markdown files..........................................Passed
```

Filene ble fikset automatisk. Kjør commit på nytt:

```bash
$ git add docs/new-guide.md
$ git commit -m "Add new guide"

Trim trailing whitespace....................................Passed
Fix end of files.............................................Passed
Lint Markdown files..........................................Passed

[main abc1234] Add new guide
 1 file changed, 50 insertions(+)
```

### Scenario 2: Ansible lint feil

```bash
$ git add playbooks/deploy.yml
$ git commit -m "Add deploy playbook"

Lint Ansible files...........................................Failed
- hook id: ansible-lint
- exit code: 2

playbooks/deploy.yml:12: [yaml[indentation]] Wrong indentation: expected 2 but found 4
playbooks/deploy.yml:15: [name[missing]] All tasks should be named
```

Fiks feilene manuelt:

```bash
# Rediger playbooks/deploy.yml
# Fiks indentering og legg til task names

$ git add playbooks/deploy.yml
$ git commit -m "Add deploy playbook"

Lint Ansible files...........................................Passed

[main def5678] Add deploy playbook
 1 file changed, 30 insertions(+)
```

### Scenario 3: Sjekke alle filer før push

```bash
# Kjør alle hooks på alle filer
$ pre-commit run --all-files

Trim trailing whitespace....................................Passed
Fix end of files.............................................Passed
Check YAML syntax............................................Passed
Check for large files........................................Passed
Check for merge conflicts....................................Passed
Fix mixed line endings.......................................Passed
Lint Markdown files..........................................Passed
Lint Ansible files...........................................Passed
```

## Feilsøking

### Problem: Pre-commit ikke installert

```bash
$ git commit -m "Test"
# Ingenting skjer - pre-commit kjører ikke
```

**Løsning:**

```bash
pre-commit install
```

### Problem: Hook feiler på filer du ikke endret

Pre-commit kan kjøre på alle filer hvis `--all-files` ble brukt tidligere.

**Løsning:**

```bash
# Kjør kun på staged filer
git reset
git add <dine-filer>
git commit -m "Melding"
```

### Problem: "command not found: pre-commit"

Pre-commit er ikke installert i miljøet.

**Løsning:**

```bash
# Installer pre-commit
pip install pre-commit

# Eller rebuild devcontainer
# VS Code: Command Palette > Dev Containers: Rebuild Container
```

### Problem: Markdownlint klager på alt

Markdown-filer følger ikke standard regler.

**Løsning:**

Rediger `.markdownlint.yaml` og skru av strenge regler:

```yaml
MD013: false  # Line length
MD024: false  # Duplicate headings
```

### Problem: Ansible-lint for streng

**Løsning:**

Rediger `.ansible-lint` og legg til regler i `skip_list`:

```yaml
skip_list:
  - yaml[line-length]
  - name[casing]
  - risky-file-permissions
```

## CI/CD Integrasjon

Pre-commit kan kjøres i CI/CD pipelines:

### GitHub Actions

```yaml
- name: Run pre-commit
  run: |
    pip install pre-commit
    pre-commit run --all-files
```

### GitLab CI

```yaml
pre-commit:
  stage: test
  script:
    - pip install pre-commit
    - pre-commit run --all-files
```

## Best Practices

### ✅ GJØR:

- **Kjør pre-commit før push** - `pre-commit run --all-files`
- **Oppdater hooks regelmessig** - `pre-commit autoupdate`
- **Fiks feil umiddelbart** - Ikke commit med `--no-verify`
- **Tilpass regler** - Skru av regler som ikke passer prosjektet
- **Test nye hooks** - Kjør `pre-commit run --all-files` etter endringer

### ❌ IKKE GJØR:

- **Bruk `--no-verify` rutinemessig** - Hopp kun over i nødssituasjoner
- **Ignorer advarsler** - De indikerer ofte reelle problemer
- **Commit store filer** - Pre-commit vil advare
- **Skip oppdateringer** - Gamle hooks kan mangle viktige fikser

## Hurtigreferanse

| Kommando | Beskrivelse |
|----------|-------------|
| `pre-commit install` | Installer hooks i repository |
| `pre-commit run --all-files` | Kjør alle hooks på alle filer |
| `pre-commit run <hook-id>` | Kjør spesifikk hook |
| `pre-commit autoupdate` | Oppdater hook-versjoner |
| `pre-commit uninstall` | Fjern hooks |
| `git commit --no-verify` | Commit uten å kjøre hooks |
| `pre-commit clean` | Fjern cached miljøer |
| `pre-commit run --files <fil>` | Kjør på spesifikke filer |

## Ytterligere ressurser

- [Pre-commit dokumentasjon](https://pre-commit.com/)
- [Markdownlint regler](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [Ansible-lint dokumentasjon](https://ansible.readthedocs.io/projects/lint/)
- [Supported hooks](https://pre-commit.com/hooks.html)
