# Docker Vedlikehold for DevContainers

## Oversikt

Når du jobber med DevContainers, bygger Docker opp images, volumes, containere og nettverk over tid. Dette kan ta opp mye diskplass. Denne guiden viser hvordan du holder Docker-installasjonen ryddig og effektiv.

## Sjekke diskbruk

### Vis total diskbruk

```bash
docker system df
```

Output viser:
- **Images**: Hvor mye plass Docker-images bruker
- **Containers**: Plass brukt av containere
- **Local Volumes**: Plass brukt av volumes
- **Build Cache**: Plass brukt av build cache

### Detaljert oversikt

```bash
docker system df -v
```

Viser detaljert liste over alle images, containere, volumes og build cache.

---

## Images

Docker images er basis-filsystemet som containere kjører fra. DevContainers bygger ofte egne images.

### Liste alle images

```bash
# Vis alle images
docker images

# Vis med størrelser
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Vis dangling images (ubrukte layers)
docker images -f "dangling=true"
```

### Slette images

```bash
# Slett ett spesifikt image
docker rmi image-navn:tag

# Slett image med ID
docker rmi abc123def456

# Slett flere images
docker rmi image1 image2 image3

# Tving sletting (hvis i bruk)
docker rmi -f image-navn:tag

# Slett alle dangling images
docker image prune

# Slett alle ubrukte images
docker image prune -a

# Slett uten bekreftelse
docker image prune -a -f
```

### Finne og slette gamle DevContainer images

```bash
# Finn DevContainer images (ofte har vsc- prefix)
docker images | grep vsc-

# Slett alle DevContainer images som ikke er i bruk
docker images | grep vsc- | awk '{print $3}' | xargs docker rmi
```

---

## Containere

Containere er kjørende eller stoppede instanser av images.

### Liste containere

```bash
# Vis kjørende containere
docker ps

# Vis alle containere (inkludert stoppede)
docker ps -a

# Vis kun container-IDer
docker ps -aq

# Vis med størrelser
docker ps -a -s
```

### Stoppe containere

```bash
# Stopp en container
docker stop container-navn

# Stopp flere containere
docker stop container1 container2

# Stopp alle kjørende containere
docker stop $(docker ps -q)
```

### Slette containere

```bash
# Slett en stoppet container
docker rm container-navn

# Slett flere containere
docker rm container1 container2

# Slett alle stoppede containere
docker container prune

# Slett uten bekreftelse
docker container prune -f

# Slett alle containere (kjørende og stoppede)
docker rm -f $(docker ps -aq)
```

### Finne og slette gamle DevContainer-containere

```bash
# Finn DevContainer-containere
docker ps -a | grep vsc-

# Slett alle stoppede DevContainer-containere
docker ps -a | grep vsc- | awk '{print $1}' | xargs docker rm
```

---

## Volumes

Volumes brukes til å lagre data persistent utenfor containeren.

### Liste volumes

```bash
# Vis alle volumes
docker volume ls

# Vis dangling volumes (ikke i bruk)
docker volume ls -f "dangling=true"

# Vis med detaljer
docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"
```

### Inspisere volume

```bash
# Se detaljer om et volume
docker volume inspect volume-navn

# Se hvilket container som bruker et volume
docker ps -a --filter volume=volume-navn
```

### Slette volumes

```bash
# Slett et spesifikt volume
docker volume rm volume-navn

# Slett flere volumes
docker volume rm volume1 volume2

# Slett alle ubrukte volumes
docker volume prune

# Slett uten bekreftelse
docker volume prune -f
```

**Advarsel:** Vær forsiktig med å slette volumes! De kan inneholde viktige data som databaser eller konfigurasjoner.

---

## Nettverk

Docker lager nettverk for å koble containere sammen.

### Liste nettverk

```bash
# Vis alle nettverk
docker network ls

# Vis med detaljer
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
```

### Slette nettverk

```bash
# Slett et spesifikt nettverk
docker network rm nettverk-navn

# Slett alle ubrukte nettverk
docker network prune

# Slett uten bekreftelse
docker network prune -f
```

---

## Build Cache

Build cache fra `docker build` kan ta mye plass over tid.

### Sjekk build cache størrelse

```bash
docker system df
```

Se på "Build Cache" linjen.

### Slette build cache

```bash
# Slett all build cache
docker builder prune

# Slett alt inkludert cache i bruk
docker builder prune -a

# Slett uten bekreftelse
docker builder prune -a -f
```

---

## Komplett opprydding

### Rydd opp i alt

```bash
# Fjern alle stoppede containere, ubrukte nettverk, dangling images og build cache
docker system prune

# Inkluder alle ubrukte images (ikke bare dangling)
docker system prune -a

# Inkluder volumes også
docker system prune -a --volumes

# Uten bekreftelse
docker system prune -a --volumes -f
```

**Advarsel:** Dette kan slette data! Sørg for at du ikke trenger noen av ressursene før du kjører dette.

### Trygg opprydding for DevContainers

Hvis du aktivt bruker DevContainers, kan denne tilnærmingen være tryggere:

```bash
# 1. Slett kun stoppede containere
docker container prune -f

# 2. Slett dangling images
docker image prune -f

# 3. Slett ubrukt build cache
docker builder prune -f

# 4. (Valgfritt) Slett ubrukte volumes hvis du er sikker
docker volume prune -f
```

---

## Vedlikeholdsrutiner

### Daglig/Ukentlig

```bash
# Lett opprydding - fjern stoppede containere og dangling images
docker container prune -f
docker image prune -f
```

### Månedlig

```bash
# Mer aggressiv opprydding
docker system prune -a -f

# Sjekk diskbruk etterpå
docker system df
```

### Før viktige oppgaver

Hvis du trenger mest mulig diskplass:

```bash
# Full opprydding (OBS: Slett volumes separat hvis nødvendig)
docker system prune -a -f
docker builder prune -a -f

# Sjekk resultatet
docker system df
```

---

## DevContainer-spesifikke tips

### Rebuilde DevContainer

Når du gjør endringer i DevContainer-konfigurasjonen:

```bash
# I VS Code: Command Palette (Ctrl+Shift+P)
# > Dev Containers: Rebuild Container

# Eller: Rebuild Without Cache for ren bygg
# > Dev Containers: Rebuild Container Without Cache
```

Dette sikrer at nye endringer blir tatt i bruk og gamle layers fjernes.

### Finne DevContainer-ressurser

DevContainers prefikser ofte med `vsc-`:

```bash
# Images
docker images | grep vsc-

# Containere
docker ps -a | grep vsc-

# Volumes
docker volume ls | grep vsc-
```

### Slette alle DevContainer-ressurser

**Advarsel:** Dette sletter ALT relatert til DevContainers!

```bash
# Stopp alle DevContainer-containere
docker ps | grep vsc- | awk '{print $1}' | xargs -r docker stop

# Slett containere
docker ps -a | grep vsc- | awk '{print $1}' | xargs -r docker rm

# Slett images
docker images | grep vsc- | awk '{print $3}' | xargs -r docker rmi

# Slett volumes (vær forsiktig!)
docker volume ls | grep vsc- | awk '{print $2}' | xargs -r docker volume rm
```

---

## Automatisert vedlikehold

### Cron-job for automatisk opprydding

Legg til i crontab for ukentlig opprydding:

```bash
# Rediger crontab
crontab -e

# Legg til (kjører hver søndag kl 02:00)
0 2 * * 0 /usr/bin/docker system prune -f >> /var/log/docker-prune.log 2>&1
```

### Bash-script for vedlikehold

Opprett et script `docker-cleanup.sh`:

```bash
#!/bin/bash

echo "🧹 Docker opprydding startet: $(date)"
echo ""

# Vis diskbruk før
echo "📊 Diskbruk FØR opprydding:"
docker system df
echo ""

# Fjern stoppede containere
echo "🗑️  Fjerner stoppede containere..."
docker container prune -f

# Fjern dangling images
echo "🗑️  Fjerner dangling images..."
docker image prune -f

# Fjern ubrukt build cache
echo "🗑️  Fjerner ubrukt build cache..."
docker builder prune -f

# Fjern ubrukte nettverk
echo "🗑️  Fjerner ubrukte nettverk..."
docker network prune -f

echo ""
echo "📊 Diskbruk ETTER opprydding:"
docker system df
echo ""

echo "✅ Docker opprydding fullført: $(date)"
```

Gjør scriptet kjørbart og kjør det:

```bash
chmod +x docker-cleanup.sh
./docker-cleanup.sh
```

---

## Feilsøking

### Problem: "No space left on device"

Docker har brukt opp all diskplass.

**Løsning:**

```bash
# Akutt: Slett alt unntatt det som kjører
docker system prune -a -f

# Sjekk diskbruk
df -h
docker system df
```

### Problem: Kan ikke slette image "image is being used"

Et image er i bruk av en container.

**Løsning:**

```bash
# Finn hvilken container som bruker imaget
docker ps -a --filter ancestor=image-navn

# Slett containeren først
docker rm -f container-id

# Så slett imaget
docker rmi image-navn
```

### Problem: Volume i bruk

**Løsning:**

```bash
# Finn hvilken container som bruker volumet
docker ps -a --filter volume=volume-navn

# Stopp og slett containeren
docker rm -f container-id

# Slett volumet
docker volume rm volume-navn
```

### Problem: BuildKit cache tar for mye plass

**Løsning:**

```bash
# Slett all BuildKit cache
docker builder prune -a -f

# Eller begrens cache-størrelse i daemon.json
# /etc/docker/daemon.json:
# {
#   "builder": {
#     "gc": {
#       "enabled": true,
#       "defaultKeepStorage": "20GB"
#     }
#   }
# }
```

---

## Best Practices

### ✅ GJØR:

- **Kjør regelmessig opprydding** - Ukentlig eller månedlig
- **Bruk `docker system prune` jevnlig** - Hold systemet ryddig
- **Rebuild DevContainers** - Når du gjør større endringer
- **Sjekk diskbruk** - Kjør `docker system df` regelmessig
- **Dokumenter viktige volumes** - Så du ikke sletter dem ved uhell

### ❌ IKKE GJØR:

- **Slett volumes uten å sjekke** - De kan inneholde viktig data
- **Ignorer diskbruk** - Docker kan fylle opp disken raskt
- **Hold gamle images** - Slett de du ikke bruker
- **Glem build cache** - Den vokser over tid

---

## Hurtigreferanse

| Kommando | Beskrivelse |
|----------|-------------|
| `docker system df` | Vis diskbruk |
| `docker images` | List alle images |
| `docker ps -a` | List alle containere |
| `docker volume ls` | List alle volumes |
| `docker system prune` | Rydd opp stoppede containere og dangling images |
| `docker system prune -a` | Rydd opp alt ubrukt |
| `docker system prune -a --volumes` | Rydd opp alt inkl. volumes |
| `docker container prune -f` | Slett alle stoppede containere |
| `docker image prune -a -f` | Slett alle ubrukte images |
| `docker volume prune -f` | Slett alle ubrukte volumes |
| `docker builder prune -a -f` | Slett all build cache |

---

## Ytterligere ressurser

- [Docker dokumentasjon - Prune](https://docs.docker.com/config/pruning/)
- [Docker system commands](https://docs.docker.com/engine/reference/commandline/system/)
- [Best practices for cleaning up Docker](https://docs.docker.com/config/daemon/)
