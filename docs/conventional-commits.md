# Conventional Commits og Versjonshåndtering

## Oversikt

Dette prosjektet bruker [Conventional Commits](https://www.conventionalcommits.org/) for strukturerte commit-meldinger og semantisk versjonering. Versjonen oppdateres manuelt i `VERSION`-filen.

## Hva er Conventional Commits?

Conventional Commits er en konvensjon for å skrive commit-meldinger som er maskinlesbare og menneskeforståelige. Dette gjør det mulig å automatisk generere changelogs og håndtere semantisk versjonering.

## Commit-melding format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Typer (type)

| Type | Beskrivelse | Versjonsbump |
|------|-------------|--------------|
| `feat` | Ny funksjonalitet | MINOR (0.x.0) |
| `fix` | Bugfix | PATCH (0.0.x) |
| `docs` | Kun dokumentasjonsendringer | Ingen |
| `style` | Formatering, manglende semikolon, etc. | Ingen |
| `refactor` | Kodeendring som verken fikser bug eller legger til funksjon | Ingen |
| `perf` | Ytelsesforbedrende endring | PATCH |
| `test` | Legge til manglende tester | Ingen |
| `build` | Endringer i build-system eller dependencies | Ingen |
| `ci` | Endringer i CI-konfigurasjon | Ingen |
| `chore` | Andre endringer som ikke påvirker kildekode | Ingen |
| `revert` | Tilbakestiller en tidligere commit | Kontekstuelt |

### Breaking Changes

For å indikere breaking changes:

```
feat!: ny API som endrer eksisterende funksjonalitet

BREAKING CHANGE: API endepunkter er nå versjonert
```

Dette gir en MAJOR versjonsbump (x.0.0).

## Eksempler

### Enkel feature

```bash
git commit -m "feat: legg til zensical dokumentasjon"
```

### Feature med scope

```bash
git commit -m "feat(ansible): legg til vault password support"
```

### Bugfix

```bash
git commit -m "fix: rett opp ssh-agent forwarding i devcontainer"
```

### Breaking change

```bash
git commit -m "feat!: endre devcontainer base image til python 3.12

BREAKING CHANGE: Python 3.10 er ikke lenger støttet"
```

### Dokumentasjon

```bash
git commit -m "docs: legg til guide for pre-commit hooks"
```

### Med body og footer

```bash
git commit -m "fix(docker): løs problem med volume permissions

Endret mount-opsjoner for å tillate skrivetilgang
til .ssh katalog.

Fixes #42"
```

## Versjonshåndtering

### VERSION-fil

Prosjektet har en `VERSION`-fil i root som inneholder gjeldende versjon:

```
0.1.0
```

### Semantisk versjonering

Vi følger [Semantic Versioning](https://semver.org/) (SemVer):

**Format:** `MAJOR.MINOR.PATCH`

- **MAJOR**: Inkompatible API-endringer (breaking changes)
- **MINOR**: Ny funksjonalitet (bakoverkompatibel)
- **PATCH**: Bugfixes (bakoverkompatible)

### Oppdatere versjon

Når du skal lage en ny release:

1. **Oppdater VERSION-filen:**

```bash
echo "0.2.0" > VERSION
git add VERSION
git commit -m "chore: bump version to 0.2.0"
```

2. **Opprett og push tag:**

```bash
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin main
git push origin v0.2.0
```

### Velge neste versjon

Commit-typene siden forrige tag forteller hvilket versjonsnummer som skal økes:

- **BREAKING CHANGE** eller `type!:` → MAJOR (1.0.0 → 2.0.0)
- **feat:** → MINOR (1.0.0 → 1.1.0)
- **fix:** → PATCH (1.0.0 → 1.0.1)
- Andre typer (docs, chore, etc.) → ingen ny versjon nødvendig

Se hvilke commits som er kommet siden forrige tag:

```bash
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

Finnes det ingen tag ennå, bruk `git log --oneline`.

### Eksempel

```bash
$ git log v0.1.0..HEAD --oneline
a1b2c3d fix: rett opp ssh-agent forwarding
d4e5f6a feat: legg til zensical support
0a1b2c3 docs: oppdater guide

# feat: er den "største" endringen → MINOR bump
# 0.1.0 → 0.2.0
```

### Changelog-kategorier

Commit-typene gjør det enkelt å skrive en kategorisert changelog for hver versjon:

```markdown
## 0.2.0

### Breaking Changes
- feat!: endre til Python 3.12

### Features
- feat: legg til zensical support
- feat(docker): forbedre volume mounting

### Bug Fixes
- fix: ssh-agent forwarding issue
- fix(ansible): vault password handling

### Other Changes
- chore: oppdater dependencies
- docs: legg til guide
```

Dette kan senere automatiseres i en CI/CD-pipeline på Git-serveren.

## Pre-commit Hook for Conventional Commits

Pre-commit sjekker automatisk at commit-meldinger følger Conventional Commits-formatet.

### Hva sjekkes?

- ✅ Type er gyldig (`feat`, `fix`, `docs`, etc.)
- ✅ Format er korrekt (`type: description`)
- ✅ Description starter med liten bokstav
- ✅ Ingen punktum på slutten av description

### Eksempel på validering

```bash
# ✅ Gyldig
$ git commit -m "feat: legg til ny funksjon"

# ❌ Ugyldig - mangler type
$ git commit -m "legg til ny funksjon"
[FAIL] Commit message should be in format 'type: description'

# ❌ Ugyldig - ugyldig type
$ git commit -m "feature: legg til ny funksjon"
[FAIL] Type 'feature' is not allowed

# ❌ Ugyldig - description starter med stor bokstav
$ git commit -m "feat: Legg til ny funksjon"
[FAIL] Description should start with lowercase
```

## Workflow for endringer

### Normal endring (ingen release)

```bash
# 1. Gjør endringer
vim docs/new-guide.md

# 2. Stage endringer
git add docs/new-guide.md

# 3. Commit med Conventional Commits format
git commit -m "docs: legg til guide for xyz"

# Pre-commit kjører automatisk og validerer meldingen

# 4. Push
git push origin main

# Ingen ny versjon siden det er kun docs
```

### Endring som gir ny versjon

```bash
# 1. Implementer ny funksjonalitet
vim playbooks/new-playbook.yml

# 2. Stage og commit
git add playbooks/new-playbook.yml
git commit -m "feat: legg til deployment playbook"

# 3. Push til main
git push origin main

# 4. feat: betyr MINOR bump (0.1.0 → 0.2.0)
echo "0.2.0" > VERSION
git add VERSION
git commit -m "chore: bump version to 0.2.0"
git tag -a v0.2.0 -m "Release v0.2.0"
git push origin main
git push origin v0.2.0
```

## Beste praksis

### ✅ GJØR:

- **Bruk imperative mood** - "add" ikke "added"
- **Hold description kort** - Under 72 tegn
- **Bruk body for detaljer** - Forklar hvorfor, ikke hva
- **Referrer issues** - `Fixes #123` i footer
- **Én logisk endring per commit** - Lettere å forstå
- **Test før commit** - Kjør `pre-commit run --all-files`
- **Push til main for release** - Workflow håndterer versjonering

### ❌ IKKE GJØR:

- **Vage meldinger** - "fikset ting", "oppdateringer"
- **Flere endringer i én commit** - Vanskelig å reverter
- **Skip pre-commit** - Med mindre absolutt nødvendig
- **Manuelt oppdater VERSION** - La workflow gjøre det
- **Opprett tags manuelt** - La workflow gjøre det

## Eksempel på release-historikk

```
v1.0.0 - Major Release
  feat!: migrert til Python 3.12
  feat: lagt til Zensical dokumentasjon
  feat: implementert pre-commit hooks
  docs: komplett dokumentasjon

v0.2.0 - Minor Release
  feat(ansible): vault password support
  feat(docker): volume mounting improvements
  fix: ssh-agent forwarding issue
  docs: git basics guide

v0.1.1 - Patch Release
  fix: markdownlint konfigurasjon
  fix: devcontainer post-create script

v0.1.0 - Initial Release
  feat: initial devcontainer setup
  docs: development environment guide
```

## Feilsøking

### Problem: Pre-commit avviser commit-melding

```bash
$ git commit -m "added new feature"
[FAIL] Commit message should be in format 'type: description'
```

**Løsning:** Bruk riktig format:

```bash
git commit -m "feat: add new feature"
```

### Problem: VERSION og tag matcher ikke

```bash
❌ Error: VERSION file (0.1.0) does not match tag (0.2.0)
```

**Løsning:** Oppdater VERSION-filen før du lager tag:

```bash
echo "0.2.0" > VERSION
git add VERSION
git commit -m "chore: bump version to 0.2.0"
git tag -a v0.2.0 -m "Release v0.2.0"
```

### Problem: Vil endre commit-melding etter pre-commit

```bash
# Endre siste commit-melding
git commit --amend -m "feat: korrekt melding"
```

## Hurtigreferanse

| Kommando | Beskrivelse |
|----------|-------------|
| `git commit -m "feat: description"` | Feature commit (MINOR bump) |
| `git commit -m "fix: description"` | Bugfix commit (PATCH bump) |
| `git commit -m "feat!: description"` | Breaking change (MAJOR bump) |
| `git commit -m "docs: description"` | Dokumentasjon (ingen release) |
| `git tag -a v0.2.0 -m "Release v0.2.0"` | Lag tag for ny versjon |
| `cat VERSION` | Se gjeldende versjon |
| `git tag` | Se alle tags/releases |
| `pre-commit run --all-files` | Test commits lokalt |

## Ytterligere ressurser

- [Conventional Commits spesifikasjon](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
