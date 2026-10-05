# GærneArnes nettverksskole

Dette er en liten samling av ting som kan være nyttig.

For å sette opp utviklingsmiljøet på din Windows 11 maskin så følg oppsettet i
[dev-environment](dev-environment.md).

For å lære om Ansible Vault og LastPass-integrasjonen, se
[ansible-vault-guide](ansible-vault-guide.md).

For grunnleggende Git-kommandoer og arbeidsflyter, se
[git-basics](git-basics.md).

For å lære om Fork vs. Branch workflows og Pull Requests, se
[git-workflows](git-workflows.md).

For å lære om automatisk deployment av dokumentasjon med GitHub Actions, se
[github-actions-deploy](github-actions-deploy.md).

For vedlikehold og opprydding av Docker, se
[docker-vedlikehold](docker-vedlikehold.md).

For å lære om pre-commit hooks for kodekvalitet, se
[pre-commit-guide](pre-commit-guide.md).

For å lære om Conventional Commits og versjonshåndtering, se
[conventional-commits](conventional-commits.md).

For å fikse GitHub branch protection med automatisk release, se
[github-branch-protection](github-branch-protection.md).

Dette oppsettet laget for å forenkle deling av kode mest mulig. Og ikke minst at
kjøremiljøet skal være enkelt å holde konsistent fra PC til PC.

## Fordeler ved bruk av DevContainer

DevContainers gir deg et konsistent og isolert utviklingsmiljø med flere viktige fordeler:

### Konsistens på tvers av maskiner
- Alle utviklere jobber i nøyaktig samme miljø, uavhengig av operativsystem
- Eliminerer "det funker på min maskin"-problemer
- Identisk oppsett mellom Windows, Mac og Linux

### Enkel onboarding
- Nye teammedlemmer er klare til å kode på minutter
- Ingen tidkrevende manuell installasjon av verktøy og avhengigheter
- Komplett miljø definert i kodefiler som kan versjonshåndteres

### Isolasjon og sikkerhet
- Prosjektavhengigheter holdes separert fra vertsmaskinen
- Ingen konflikt mellom ulike versjoner av Python, Node.js eller andre verktøy
- Trygt å teste nye pakker uten å påvirke systemet ditt

### Reproduserbarhet
- Miljøet er definert som kode (Infrastructure as Code)
- Lett å gjenskape eksakt samme oppsett når som helst
- Perfekt for testing og feilsøking

### Fleksibilitet
- Raskt å bytte mellom ulike prosjekter med forskjellige krav
- Støtte for tilpasninger per prosjekt
- Kan lett integreres med CI/CD-pipelines

## Alternativ: Python Virtual Environment (venv)

Dersom det ikke er mulig å bruke Docker eller DevContainers, er Python's innebygde `venv` et godt alternativ for å isolere prosjektavhengigheter.

### Hva er venv?
`venv` er et innebygd Python-verktøy som skaper et isolert miljø for Python-pakker. Dette gjør at hvert prosjekt kan ha sine egne avhengigheter uten å påvirke andre prosjekter eller systemets Python-installasjon.

### Oppsett av venv

**Opprett et virtuelt miljø:**

```bash
python -m venv .venv
```

**Aktiver miljøet:**

```bash
# Windows
.venv\Scripts\activate

# Linux/Mac
source .venv/bin/activate
```

**Installer pakker:**

```bash
pip install mkdocs
# eller fra en requirements.txt fil
pip install -r requirements.txt
```

**Deaktiver miljøet når du er ferdig:**

```bash
deactivate
```

### Fordeler med venv

- **Enkelt oppsett**: Ingen ekstra programvare utover Python kreves
- **Lett å bruke**: Enkel å aktivere og deaktivere
- **Isolasjon av pakker**: Hver prosjekt har sine egne avhengigheter
- **Portabelt**: Fungerer på Windows, Mac og Linux
- **Lav overhead**: Ingen containerisering, bruker maskinen direkte

### Ulemper sammenlignet med DevContainer

- **Ikke fullstendig isolasjon**: Systemverktøy og operativsystem påvirker fremdeles miljøet
- **Krever manuell oppsett**: Må installere Python og andre verktøy selv
- **Mindre konsistent**: Kan fortsatt få forskjeller mellom maskiner
- **Bare for Python**: Andre språk og verktøy må håndteres separat

### Når bør du bruke venv?

- Når Docker ikke er tilgjengelig eller tillatt
- For enkle Python-prosjekter
- Når du jobber alene og ikke trenger full konsistens
- For rask prototyping og testing
