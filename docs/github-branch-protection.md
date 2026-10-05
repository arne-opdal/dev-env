# GitHub Branch Protection og Release Automation

## Problem

Når du har branch protection rules på `main` som krever pull requests, kan GitHub Actions ikke automatisk pushe endringer (som VERSION-fil oppdateringer). Du vil se denne feilen:

```
remote: error: GH013: Repository rule violations found for refs/heads/main.
remote: - Changes must be made through a pull request.
```

## Løsninger

### Løsning 1: Personal Access Token (PAT) - Anbefalt

Dette gir workflow'en tilgang til å pushe til beskyttede branches.

#### Steg 1: Opprett Personal Access Token

1. Gå til GitHub Settings:
    - Klikk på profilbildet ditt → Settings
    - Developer settings → Personal access tokens → Tokens (classic)
    - Eller gå direkte til: https://github.com/settings/tokens

2. Klikk **Generate new token** → **Generate new token (classic)**

3. Konfigurer token:

    - **Note**: `Release Automation` (eller annet beskrivende navn)
    - **Expiration**: 90 days, 1 year, eller No expiration
    - **Scopes**: Velg `repo` (gir full tilgang til repositories)

4. Klikk **Generate token**

5. **Kopier token** (du ser den bare én gang!)

#### Steg 2: Legg til som Repository Secret

1. Gå til repository secrets:

    - https://github.com/aopdal/dev-setup/settings/secrets/actions

2. Klikk **New repository secret**

3. Konfigurer secret:

    - **Name**: `PAT_TOKEN`
    - **Secret**: Lim inn token fra steg 1
    - Klikk **Add secret**

#### Steg 3: Workflow er allerede oppdatert

Workflow'en bruker nå `PAT_TOKEN`:

```yaml
- name: Checkout repository
  uses: actions/checkout@v4
  with:
    token: ${{ secrets.PAT_TOKEN }}
```

#### Steg 4: Test

Push en endring og se at workflow'en fungerer:

```bash
git commit -m "feat: test automatisk release"
git push origin main
```

### Løsning 2: Tillat GitHub Actions å bypasse protection

Dette er enklere, men mindre sikkert.

#### Via Repository Rules

1. Gå til repository rules:

    - https://github.com/aopdal/dev-setup/settings/rules

2. Finn eller opprett regel for `main` branch

3. Aktiver: **"Allow specified actors to bypass required pull requests"**

4. Legg til: `github-actions[bot]` som tillatt actor

#### Via Branch Protection Settings (legacy)

1. Gå til branch settings:

    - https://github.com/aopdal/dev-setup/settings/branches

2. Finn rule for `main` branch, klikk **Edit**

3. Under "Require a pull request before merging":

    - Aktiver "Do not allow bypassing the above settings"
    - Under "Allow specified actors to bypass pull request requirements"
    - Legg til `github-actions[bot]`

### Løsning 3: Fine-grained Personal Access Token

Mest sikker, anbefalt for organisasjoner.

1. Opprett fine-grained token:

    - GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens
    - Klikk **Generate new token**

2. Konfigurer:

    - **Token name**: `dev-setup-release`
    - **Expiration**: Velg periode
    - **Repository access**: Only select repositories → `aopdal/dev-setup`
    - **Repository permissions**:
        - Contents: Read and write
        - Metadata: Read-only (automatic)

3. Klikk **Generate token** og kopier

4. Legg til som secret (samme som Løsning 1, Steg 2)

## Sammenligning

| Løsning | Sikkerhet | Kompleksitet | Bruk når |
|---------|-----------|--------------|----------|
| PAT (classic) | Middels | Lav | Personlige repos, enkel setup |
| Bypass protection | Lav | Svært lav | Testing, ikke-kritiske repos |
| Fine-grained PAT | Høy | Middels | Team repos, produksjon |

## Sikkerhetspraksis

### ✅ GJØR:

- **Bruk fine-grained PAT** for produksjon
- **Sett expiration** på tokens (roter regelmessig)
- **Minimal permissions** - kun det som trengs
- **Revoke tokens** du ikke bruker lenger
- **Dokumenter** hvilke tokens som brukes hvor

### ❌ IKKE GJØR:

- **Del tokens** i kode eller chat
- **Bruk tokens med for bredt scope** (f.eks. alle repos)
- **La tokens leve evig** uten grunn
- **Commit tokens** til Git
- **Gi flere permissions** enn nødvendig

## Rotere token

Når token utløper eller må roteres:

1. Opprett ny token (samme steg som over)
2. Oppdater repository secret:
    - Gå til secrets: https://github.com/aopdal/dev-setup/settings/secrets/actions
    - Klikk på `PAT_TOKEN`
    - Klikk **Update secret**
    - Lim inn ny token
3. Revoke gammel token i GitHub settings

## Feilsøking

### Problem: Workflow feiler fortsatt etter å ha lagt til PAT

**Sjekk:**

- Er secret-navnet riktig? Må være `PAT_TOKEN`
- Har token `repo` scope?
- Er token utløpt?
- Bruker workflow'en riktig secret? `${{ secrets.PAT_TOKEN }}`

### Problem: "Resource not accessible by integration"

Token mangler nødvendige permissions.

**Løsning:** Opprett ny token med `repo` scope (classic) eller `Contents: Write` (fine-grained)

### Problem: Token utløpt

**Løsning:** Opprett ny token og oppdater secret (se "Rotere token" over)

## Alternative løsninger

### GitHub App

For større organisasjoner kan en GitHub App være bedre:

```yaml
- name: Generate token
  id: generate_token
  uses: tibdex/github-app-token@v1
  with:
    app_id: ${{ secrets.APP_ID }}
    private_key: ${{ secrets.APP_PRIVATE_KEY }}

- name: Checkout
  uses: actions/checkout@v4
  with:
    token: ${{ steps.generate_token.outputs.token }}
```

Fordeler:

- Mer granulær kontroll
- Bedre audit logging
- Kan begrenses til spesifikke repos
- Automatisk token rotation

## Ytterligere ressurser

- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Fine-grained PAT](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-fine-grained-personal-access-token)
- [Branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Apps](https://docs.github.com/en/apps/creating-github-apps/about-creating-github-apps/about-creating-github-apps)
