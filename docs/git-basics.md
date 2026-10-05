# Git Grunnleggende

## Oversikt

Git er et distribuert versjonskontrollsystem som lar deg spore endringer i kode og samarbeide med andre utviklere. Denne guiden dekker de mest brukte Git-kommandoene for daglig bruk.

## Grunnleggende konsepter

### De tre områdene i Git

1. **Working Directory** - Der du jobber med filene dine
2. **Staging Area (Index)** - Der du forbereder endringer for commit
3. **Repository** - Der Git lagrer alle commits permanent

### Arbeidsflyt

```
Working Directory → Staging Area → Repository → Remote
    (edit)         →    (add)     →  (commit)  → (push)
```

---

## Første gang oppsett

### Konfigurer identiteten din

```bash
# Sett navn og e-post (brukes i alle commits)
git config --global user.name "Ditt Navn"
git config --global user.email "din.epost@example.com"

# Sjekk konfigurasjonen
git config --list
```

### Sett standard editor

```bash
# Bruk nano (enklest)
git config --global core.editor nano

# Eller vim
git config --global core.editor vim

# Eller VS Code
git config --global core.editor "code --wait"
```

---

## Opprette og klone repositories

### Opprett nytt repository

```bash
# Gå til prosjektmappen din
cd /path/to/your/project

# Initialiser Git
git init

# Legg til en fjern-repository (remote)
git remote add origin https://github.com/brukernavn/repo-navn.git
```

### Klon eksisterende repository

```bash
# Klon via HTTPS
git clone https://github.com/brukernavn/repo-navn.git

# Klon via SSH (anbefalt)
git clone git@github.com:brukernavn/repo-navn.git

# Klon til spesifikk mappe
git clone https://github.com/brukernavn/repo-navn.git min-mappe
```

---

## Sjekke status

### Se endringer

```bash
# Vis status på alle filer
git status

# Kort versjon
git status -s

# Vis hvilke endringer som er gjort
git diff

# Vis endringer som er staged
git diff --staged
```

---

## Legge til og committe endringer

### Legge til filer i staging area

```bash
# Legg til en spesifikk fil
git add filnavn.txt

# Legg til flere filer
git add fil1.txt fil2.txt

# Legg til alle endrede filer
git add .

# Legg til alle filer med en bestemt filtype
git add *.py

# Legg til alle filer i en mappe
git add docs/
```

### Fjerne filer fra staging area

```bash
# Fjern fil fra staging (beholder endringer)
git reset filnavn.txt

# Fjern alle filer fra staging
git reset
```

### Committe endringer

```bash
# Commit med melding
git commit -m "Beskrivelse av endringene"

# Commit alle endrede filer (hopper over 'git add')
git commit -am "Beskrivelse av endringene"

# Åpne editor for lengre commit-melding
git commit
```

### Gode commit-meldinger

```bash
# Dårlig eksempel
git commit -m "fikset ting"

# Godt eksempel
git commit -m "Fikset feil i brukerautentisering"

# Enda bedre - med detaljert beskrivelse
git commit -m "Fikset feil i brukerautentisering

- Rettet validering av e-postformat
- Lagt til feilhåndtering for utløpte tokens
- Oppdatert tester for login-funksjonen"
```

---

## Synkronisere med remote

### Pushe endringer

```bash
# Push til default remote (origin) og branch
git push

# Push første gang (setter upstream)
git push -u origin main

# Push til spesifikk branch
git push origin feature-branch

# Push alle branches
git push --all
```

### Hente endringer

```bash
# Hent endringer uten å merge
git fetch

# Hent og merge endringer
git pull

# Pull fra spesifikk branch
git pull origin main

# Pull med rebase i stedet for merge
git pull --rebase
```

---

## Branches (grener)

### Jobbe med branches

```bash
# Vis alle branches
git branch

# Vis alle branches inkludert remote
git branch -a

# Opprett ny branch
git branch feature-ny-funksjon

# Bytt til en annen branch
git checkout feature-ny-funksjon

# Opprett og bytt til ny branch i én kommando
git checkout -b feature-ny-funksjon

# Alternativ ny syntaks (Git 2.23+)
git switch feature-ny-funksjon
git switch -c feature-ny-funksjon
```

### Merge branches

```bash
# Bytt til branch du vil merge inn i (vanligvis main)
git checkout main

# Merge en branch
git merge feature-ny-funksjon

# Merge med commit-melding
git merge feature-ny-funksjon -m "Merget ny funksjon"
```

### Slette branches

```bash
# Slett lokal branch (bare hvis den er merged)
git branch -d feature-ny-funksjon

# Tving sletting av branch
git branch -D feature-ny-funksjon

# Slett remote branch
git push origin --delete feature-ny-funksjon
```

---

## Historikk og logging

### Se commit-historikk

```bash
# Vis commit-historikk
git log

# Kompakt visning
git log --oneline

# Vis siste 5 commits
git log -5

# Vis endringer i hver commit
git log -p

# Vis grafisk representasjon
git log --oneline --graph --all

# Søk i commits
git log --grep="passord"

# Se commits av spesifikk person
git log --author="Arne"
```

### Se endringer i en fil

```bash
# Vis historikk for en fil
git log filnavn.txt

# Vis endringer i en fil
git log -p filnavn.txt

# Se hvem som endret hver linje
git blame filnavn.txt
```

---

## Angre endringer

### Angre lokale endringer

```bash
# Forkast endringer i en fil (ikke staged)
git checkout -- filnavn.txt

# Alternativ syntaks (Git 2.23+)
git restore filnavn.txt

# Forkast alle lokale endringer
git restore .

# Fjern fil fra staging (beholder endringer)
git restore --staged filnavn.txt
```

### Endre siste commit

```bash
# Endre siste commit-melding
git commit --amend -m "Ny commit-melding"

# Legg til flere endringer i siste commit
git add glemt-fil.txt
git commit --amend --no-edit

# Endre siste commit interaktivt
git commit --amend
```

### Angre commits

```bash
# Angre siste commit (beholder endringer)
git reset --soft HEAD~1

# Angre siste commit (endringer går til working directory)
git reset HEAD~1

# Angre siste commit (forkaster alt)
git reset --hard HEAD~1

# Angre til spesifikk commit
git reset --hard abc1234

# Opprett ny commit som reverserer en tidligere commit
git revert abc1234
```

---

## Stashing (mellomlagring)

Stash lar deg mellomlagre endringer uten å committe dem.

```bash
# Lagre alle endringer
git stash

# Lagre med beskrivende melding
git stash save "Arbeid pågår på login-funksjon"

# Vis alle stashes
git stash list

# Bruk siste stash
git stash apply

# Bruk og fjern siste stash
git stash pop

# Bruk spesifikk stash
git stash apply stash@{1}

# Slett en stash
git stash drop stash@{0}

# Slett alle stashes
git stash clear

# Stash inkludert untracked filer
git stash -u
```

---

## .gitignore

### Ignorere filer

Opprett en `.gitignore`-fil i rot av prosjektet:

```bash
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/

# Ansible
*.retry
.vault_pass

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Miljøvariabler
.env
```

### Fjerne allerede tracked filer

```bash
# Fjern fil fra Git men behold lokalt
git rm --cached filnavn.txt

# Fjern mappe fra Git men behold lokalt
git rm --cached -r mappe/

# Oppdater etter å ha endret .gitignore
git rm -r --cached .
git add .
git commit -m "Oppdatert .gitignore"
```

---

## Remote repositories

### Håndtere remotes

```bash
# Vis remotes
git remote -v

# Legg til remote
git remote add origin https://github.com/brukernavn/repo.git

# Endre remote URL
git remote set-url origin git@github.com:brukernavn/repo.git

# Fjern remote
git remote remove origin

# Gi nytt navn til remote
git remote rename origin upstream
```

---

## Tags

Tags brukes til å markere spesifikke punkter i historikken (f.eks. versjoner).

```bash
# Opprett lightweight tag
git tag v1.0.0

# Opprett annotated tag (anbefalt)
git tag -a v1.0.0 -m "Versjon 1.0.0 - Første release"

# Vis alle tags
git tag

# Vis tag-detaljer
git show v1.0.0

# Push tags til remote
git push origin v1.0.0

# Push alle tags
git push --tags

# Slett lokal tag
git tag -d v1.0.0

# Slett remote tag
git push origin --delete v1.0.0

# Checkout en spesifikk tag
git checkout v1.0.0
```

---

## Merge konflikter

### Løse konflikter

Når to branches har endret samme linjer i en fil:

```bash
# Prøv å merge
git merge feature-branch

# Git vil si det er konflikter
# CONFLICT (content): Merge conflict in filnavn.txt

# Se hvilke filer som har konflikter
git status

# Åpne filen og se konfliktene:
# <<<<<<< HEAD
# Din versjon
# =======
# Andres versjon
# >>>>>>> feature-branch

# Rediger filen manuelt og fjern konfliktmarkørene
# Velg hvilken versjon du vil beholde eller kombiner dem

# Marker konflikten som løst
git add filnavn.txt

# Fullfør merge
git commit -m "Løst merge-konflikt i filnavn.txt"
```

### Avbryte merge

```bash
# Hvis du vil avbryte merge
git merge --abort
```

---

## Vanlige arbeidsflyter

### Feature Branch Workflow

```bash
# 1. Oppdater main
git checkout main
git pull

# 2. Opprett feature branch
git checkout -b feature-ny-funksjon

# 3. Gjør endringer og commit
git add .
git commit -m "Implementert ny funksjon"

# 4. Push til remote
git push -u origin feature-ny-funksjon

# 5. Opprett Pull Request på GitHub/GitLab
# (gjøres i web-grensesnittet)

# 6. Etter godkjenning og merge, oppdater main
git checkout main
git pull

# 7. Slett feature branch
git branch -d feature-ny-funksjon
git push origin --delete feature-ny-funksjon
```

### Oppdatere feature branch fra main

```bash
# Metode 1: Merge
git checkout feature-branch
git merge main

# Metode 2: Rebase (gir renere historikk)
git checkout feature-branch
git rebase main
```

---

## Nyttige tips

### Aliaser

Lag snarveier for ofte brukte kommandoer:

```bash
# Opprett aliaser
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.last 'log -1 HEAD'
git config --global alias.unstage 'reset HEAD --'

# Bruk aliasene
git st
git co main
git cm -m "Melding"
```

### Sjekke hva som har endret seg

```bash
# Før pull - se hva som kommer
git fetch
git log HEAD..origin/main

# Se forskjeller mellom branches
git diff main..feature-branch

# Se filer som har endret seg
git diff --name-only main..feature-branch
```

### Søke i kode

```bash
# Søk i alle filer
git grep "søkeord"

# Søk i spesifikk branch
git grep "søkeord" main

# Søk og vis linjenummer
git grep -n "søkeord"
```

---

## Feilsøking

### Vanlige problemer og løsninger

#### Problem: Glemt å bytte branch før endringer

```bash
# Stash endringene
git stash

# Bytt til riktig branch
git checkout riktig-branch

# Hent tilbake endringene
git stash pop
```

#### Problem: Pushet feil til remote

```bash
# Angre siste commit lokalt
git reset --hard HEAD~1

# Force push (OBS: Farlig hvis andre har pullet!)
git push -f origin branch-navn
```

#### Problem: Vil fjerne alle lokale endringer

```bash
# Forkast alle endringer
git reset --hard HEAD

# Fjern untracked filer
git clean -fd
```

#### Problem: Feil commit-melding

```bash
# Endre siste commit-melding (ikke pushet ennå)
git commit --amend -m "Riktig melding"

# Hvis allerede pushet
git commit --amend -m "Riktig melding"
git push -f origin branch-navn
```

---

## Best Practices

### ✅ GJØR:

- **Commit ofte** - Små, logiske commits er bedre enn store
- **Skriv gode commit-meldinger** - Forklar hva og hvorfor, ikke hvordan
- **Pull før push** - Unngå konflikter
- **Bruk branches** - Hold main/master stabil
- **Review før merge** - Bruk Pull Requests
- **Bruk .gitignore** - Ikke commit sensitiv data eller genererte filer

### ❌ IKKE GJØR:

- **Commit passord eller API-nøkler** - Bruk miljøvariabler
- **Commit store binærfiler** - Bruk Git LFS om nødvendig
- **Force push til delte branches** - Kan ødelegge for andre
- **Commit direkte til main** - Bruk feature branches
- **Glem å pull** - Hold deg oppdatert
- **Commit alt på én gang** - Del opp i logiske deler

---

## Hurtigreferanse

| Kommando | Beskrivelse |
|----------|-------------|
| `git init` | Initialiser nytt repository |
| `git clone URL` | Klon repository |
| `git status` | Vis status |
| `git add .` | Legg til alle endringer |
| `git commit -m "msg"` | Commit med melding |
| `git push` | Push til remote |
| `git pull` | Pull fra remote |
| `git branch` | Vis branches |
| `git checkout -b navn` | Opprett og bytt til branch |
| `git merge branch` | Merge branch |
| `git log` | Vis historikk |
| `git diff` | Vis endringer |
| `git stash` | Mellomlagre endringer |
| `git reset --hard HEAD` | Forkast alle endringer |

---

## Ytterligere ressurser

- [Offisiell Git-dokumentasjon](https://git-scm.com/doc)
- [Pro Git bok (gratis)](https://git-scm.com/book/en/v2)
- [GitHub Git Cheat Sheet](https://training.github.com/downloads/github-git-cheat-sheet/)
- [Visualizing Git](https://git-school.github.io/visualizing-git/)
- [Learn Git Branching (interaktiv)](https://learngitbranching.js.org/)
