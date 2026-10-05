# Git Workflows: Fork vs. Branch

## Oversikt

Det finnes to hovedstrategier for å bidra til Git-prosjekter: **Fork & Pull Request** (vanlig i open source) og **Branch & Pull Request** (vanlig i organisasjoner). Denne guiden forklarer begge.

---

## 🍴 Fork & Pull Request Workflow

**Når brukes dette:**

- Open source-prosjekter
- Når du ikke har skrivetilgang til hovedrepoet
- Eksterne bidragsytere
- Offentlige prosjekter på GitHub

### Steg-for-steg

#### 1. Fork repoet

På GitHub:

1. Gå til prosjektets repository
2. Klikk **Fork** (øverst til høyre)
3. Velg din bruker/organisasjon
4. Vent mens GitHub lager en kopi

Du har nå en kopi under `https://github.com/dinbruker/prosjektnavn`

#### 2. Clone din fork lokalt

```bash
# Clone din fork (ikke original!)
git clone https://github.com/dinbruker/prosjektnavn.git
cd prosjektnavn

# Sjekk remote
git remote -v
# output:
# origin  https://github.com/dinbruker/prosjektnavn.git (fetch)
# origin  https://github.com/dinbruker/prosjektnavn.git (push)
```

#### 3. Legg til upstream remote

Dette lar deg holde din fork oppdatert med original-repoet:

```bash
# Legg til original repo som "upstream"
git remote add upstream https://github.com/original-owner/prosjektnavn.git

# Verifiser
git remote -v
# output:
# origin    https://github.com/dinbruker/prosjektnavn.git (fetch)
# origin    https://github.com/dinbruker/prosjektnavn.git (push)
# upstream  https://github.com/original-owner/prosjektnavn.git (fetch)
# upstream  https://github.com/original-owner/prosjektnavn.git (push)
```

#### 4. Hold din fork oppdatert

Før du starter nytt arbeid, synkroniser med upstream:

```bash
# Hent siste endringer fra upstream
git fetch upstream

# Bytt til main branch
git checkout main

# Merge upstream endringer
git merge upstream/main

# Push til din fork
git push origin main
```

**💡 Tips:** Gjør dette regelmessig for å unngå merge-konflikter!

#### 5. Opprett feature branch

```bash
# Opprett ny branch fra oppdatert main
git checkout -b feature/min-nye-funksjon

# Verifiser at du er på riktig branch
git branch
# output:
# * feature/min-nye-funksjon
#   main
```

#### 6. Gjør endringer og commit

```bash
# Gjør endringer i koden
vim file.py

# Stage og commit
git add file.py
git commit -m "feat: legg til ny funksjon"

# Bruk conventional commits!
# feat: ny funksjonalitet
# fix: bugfix
# docs: dokumentasjonsendringer
```

#### 7. Push til din fork

```bash
# Push branch til din fork
git push origin feature/min-nye-funksjon
```

#### 8. Opprett Pull Request

På GitHub:

1. Gå til **din fork** (`https://github.com/dinbruker/prosjektnavn`)
2. Klikk **Compare & pull request** (gul banner)
3. Sjekk at retningen er riktig:
    - **base repository**: `original-owner/prosjektnavn` base: `main`
    - **head repository**: `dinbruker/prosjektnavn` compare: `feature/min-nye-funksjon`
4. Fyll ut PR-beskrivelse:

```markdown
## Hva gjør denne PR-en?

Legger til ny funksjon for å...

## Hvordan teste?

1. Kjør `python test.py`
2. Verifiser at...

## Checklist

- [x] Tester bestått
- [x] Dokumentasjon oppdatert
- [x] Conventional commits brukt
```

5. Klikk **Create pull request**

#### 9. Håndter review-kommentarer

```bash
# Gjør endringer basert på feedback
vim file.py

# Commit endringene
git add file.py
git commit -m "fix: adresser review-kommentarer"

# Push til samme branch
git push origin feature/min-nye-funksjon
# PR-en oppdateres automatisk!
```

#### 10. Oppdater PR hvis main har endret seg

Hvis upstream/main har fått nye commits mens du ventet på review:

```bash
# Hent siste fra upstream
git fetch upstream

# Bytt til din feature branch
git checkout feature/min-nye-funksjon

# Rebase på upstream/main
git rebase upstream/main

# Hvis konflikter:
# 1. Løs konflikter i filene
# 2. git add <resolved-files>
# 3. git rebase --continue

# Force push (siden history har endret seg)
git push origin feature/min-nye-funksjon --force-with-lease
```

**⚠️ Advarsel:** Bruk `--force-with-lease` (ikke `--force`) for sikkerhet!

#### 11. Etter merge

```bash
# Bytt til main
git checkout main

# Slett lokal feature branch
git branch -d feature/min-nye-funksjon

# Slett remote branch på din fork
git push origin --delete feature/min-nye-funksjon

# Oppdater din fork
git fetch upstream
git merge upstream/main
git push origin main
```

---

## 🌿 Branch & Pull Request Workflow

**Når brukes dette:**

- Interne team i organisasjoner
- Når du har skrivetilgang til repoet
- Private prosjekter
- Mindre team

### Steg-for-steg

#### 1. Clone repoet

```bash
# Clone repoet direkte
git clone https://github.com/organisasjon/prosjektnavn.git
cd prosjektnavn

# Sjekk remote
git remote -v
# output:
# origin  https://github.com/organisasjon/prosjektnavn.git (fetch)
# origin  https://github.com/organisasjon/prosjektnavn.git (push)
```

#### 2. Oppdater main branch

```bash
# Sørg for at du har siste versjon
git checkout main
git pull origin main
```

#### 3. Opprett feature branch

```bash
# Opprett ny branch fra main
git checkout -b feature/min-nye-funksjon

# Alternativt, med tracking:
git checkout -b feature/min-nye-funksjon origin/main
```

#### 4. Gjør endringer og commit

```bash
# Gjør endringer
vim file.py

# Stage og commit
git add file.py
git commit -m "feat: legg til ny funksjon"

# Flere commits om nødvendig
git add other-file.py
git commit -m "docs: oppdater dokumentasjon"
```

#### 5. Push til remote

```bash
# Push branch til origin
git push origin feature/min-nye-funksjon

# Første gang kan du sette upstream:
git push -u origin feature/min-nye-funksjon
# Deretter er bare 'git push' nok
```

#### 6. Opprett Pull Request

På GitHub:

1. Gå til repository
2. Klikk **Compare & pull request**
3. Base: `main` ← Compare: `feature/min-nye-funksjon`
4. Fyll ut beskrivelse
5. Assign reviewers (teammedlemmer)
6. Legg til labels (bug, enhancement, etc.)
7. Link issues hvis relevant (#123)
8. Klikk **Create pull request**

#### 7. Håndter review og merge

```bash
# Hvis endringer trengs
vim file.py
git add file.py
git commit -m "fix: adresser review-feedback"
git push

# Hvis main har endret seg:
git checkout main
git pull origin main
git checkout feature/min-nye-funksjon
git merge main
# Løs eventuelle konflikter
git push
```

#### 8. Etter merge

```bash
# Bytt til main og oppdater
git checkout main
git pull origin main

# Slett lokal branch
git branch -d feature/min-nye-funksjon

# Slett remote branch (hvis ikke auto-slettet)
git push origin --delete feature/min-nye-funksjon
```

---

## 🆚 Fork vs. Branch: Sammenligning

| Aspekt | Fork Workflow | Branch Workflow |
|--------|---------------|-----------------|
| **Tilgang** | Ingen skrivetilgang nødvendig | Krever skrivetilgang |
| **Bruksområde** | Open source, eksterne bidrag | Team, organisasjoner |
| **Kompleksitet** | Mer kompleks (upstream sync) | Enklere |
| **Remote repos** | To (origin + upstream) | En (origin) |
| **Opprydding** | Krever sync av fork | Enklere branch-sletting |
| **Isolasjon** | Full isolasjon i egen fork | Delt namespace i branches |

---

## 🎯 Beste Praksis

### For begge workflows:

1. **Branch-naming conventions:**

```bash
feature/ny-funksjon      # Ny funksjonalitet
fix/bug-123              # Bugfix
docs/oppdater-readme     # Dokumentasjon
refactor/cleanup-code    # Refaktorering
test/add-unit-tests      # Testing
```

2. **Commit messages (Conventional Commits):**

```bash
feat: legg til ny funksjon
fix: rett bug i login
docs: oppdater README
style: formater kode
refactor: omorganiser struktur
test: legg til unit tests
chore: oppdater dependencies
```

3. **Hold PR-er små:**
    - En funksjon per PR
    - Lettere å reviewe
    - Raskere merge
    - Mindre merge-konflikter

4. **Skriv gode PR-beskrivelser:**

```markdown
## Problemet

Brukere kan ikke logge inn med e-post

## Løsningen

Legger til e-post validering i login-form

## Testing

1. Gå til /login
2. Skriv inn ugyldig e-post
3. Verifiser feilmelding

## Screenshots

(hvis relevant)

Fixes #123
```

5. **Kommuniser:**
    - Tag reviewers
    - Svar på kommentarer
    - Marker som "Ready for review" når klar
    - Be om hjelp hvis du står fast

---

## 🔄 Syncing Strategies

### Fork Workflow: Keep Fork Updated

```bash
# Metode 1: Merge (bevarer history)
git fetch upstream
git checkout main
git merge upstream/main
git push origin main

# Metode 2: Rebase (cleanere history)
git fetch upstream
git checkout main
git rebase upstream/main
git push origin main --force-with-lease
```

### Branch Workflow: Keep Branch Updated

```bash
# Metode 1: Merge
git checkout feature/min-branch
git merge main
git push

# Metode 2: Rebase (cleanere history)
git checkout feature/min-branch
git rebase main
git push --force-with-lease
```

**💡 Tips:** Rebase gir cleanere history, men bruk bare før PR er opprettet eller hvis du jobber alene på branchen!

---

## 🚨 Vanlige Problemer og Løsninger

### Problem: Din fork er bak upstream

```bash
# Løsning: Sync fork
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
```

### Problem: Merge-konflikter

```bash
# 1. Identifiser konfliktede filer
git status

# 2. Åpne filer og løs konflikter (fjern <<<<<<, ======, >>>>>> markers)
vim conflicted-file.py

# 3. Stage løste filer
git add conflicted-file.py

# 4. Fortsett merge/rebase
git merge --continue
# eller
git rebase --continue
```

### Problem: Feil commitet til main

```bash
# Opprett branch fra nåværende state
git checkout -b feature/should-have-been-branch

# Bytt til main og reset
git checkout main
git reset --hard origin/main
```

### Problem: Vil endre siste commit message

```bash
# Hvis ikke pushet ennå:
git commit --amend -m "ny bedre melding"

# Hvis allerede pushet (kun på din branch!):
git commit --amend -m "ny bedre melding"
git push --force-with-lease
```

### Problem: Vil squashe commits før merge

```bash
# Squash siste 3 commits
git rebase -i HEAD~3

# I editor, endre 'pick' til 'squash' for commits du vil kombinere
# Lagre og avslutt
# Rediger combined commit message
# Force push
git push --force-with-lease
```

---

## 📋 Checklist før Pull Request

- [ ] Branch er oppdatert med main/upstream
- [ ] Alle tester passerer
- [ ] Code følger prosjektets style guide
- [ ] Dokumentasjon er oppdatert
- [ ] Commit messages følger Conventional Commits
- [ ] PR-beskrivelse er utfylt
- [ ] Reviewers er assigned
- [ ] Related issues er linket
- [ ] Screenshots/GIFs lagt til (hvis UI-endringer)

---

## 🎓 Øvelse: Fork Workflow

Prøv dette på et test-repo:

1. Fork et public GitHub-repo (f.eks. aopdal/dev-setup)
2. Clone din fork
3. Legg til upstream remote
4. Opprett feature branch
5. Gjør en liten endring (f.eks. README typo)
6. Commit med conventional commit message
7. Push til din fork
8. Opprett PR
9. Etter merge: sync fork

---

## 📚 Videre Lesning

- [GitHub Fork Docs](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
- [Atlassian Git Workflows](https://www.atlassian.com/git/tutorials/comparing-workflows)
- [Conventional Commits](https://www.conventionalcommits.org/)
- `git-basics.md` - Grunnleggende Git-kommandoer
- `conventional-commits.md` - Commit message-format
- `pre-commit-guide.md` - Automatisk validering

---

**Sist oppdatert:** 25. november 2025
