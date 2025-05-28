# Docker Build System

Dieses Repository verwendet ein neues Build-System, das es ermöglicht, verschiedene PHP-Versionen über Build-Arguments zu steuern.

## Verfügbare Images

### PHP Images
- `copex/php:7.4`
- `copex/php:8.0`
- `copex/php:8.1`
- `copex/php:8.2`
- `copex/php:8.3`
- `copex/php:8.4`

### nginx-php-fpm Images
- `copex/nginx-php-fpm:7.4`
- `copex/nginx-php-fpm:8.0`
- `copex/nginx-php-fpm:8.1`
- `copex/nginx-php-fpm:8.2`
- `copex/nginx-php-fpm:8.3`
- `copex/nginx-php-fpm:8.4`

## Build-System

### Automatisches Build-Script

Das neue `build-all.sh` Script ermöglicht es, alle oder spezifische Images zu bauen:

```bash
# Alle Images bauen
./build-all.sh

# Alle Images bauen und pushen
./build-all.sh --push

# Nur PHP Images bauen
./build-all.sh --php-only

# Nur nginx-php-fpm Images bauen
./build-all.sh --nginx-only

# Nur eine spezifische PHP-Version bauen
./build-all.sh --version 8.2

# Kombinationen möglich
./build-all.sh --php-only --version 8.3 --push
```

### Manuelle Builds

Sie können auch manuell einzelne Images bauen:

```bash
# PHP Image für Version 8.2
docker build --build-arg PHP_VERSION=8.2 -t copex/php:8.2 php/

# nginx-php-fpm Image für Version 8.3
docker build --build-arg PHP_VERSION=8.3 -t copex/nginx-php-fpm:8.3 nginx-php-fpm/
```

## GitHub Actions

Das Repository enthält einen GitHub Actions Workflow (`.github/workflows/docker-build.yml`), der automatisch alle Images baut wenn Änderungen an den relevanten Dateien vorgenommen werden.

### Workflow Features:
- **Automatische Builds** bei Push/PR auf main/master/develop
- **Matrix-Builds** für alle PHP-Versionen und Image-Typen
- **Multi-Platform** Support (linux/amd64, linux/arm64)
- **Caching** für schnellere Builds
- **Manuelle Triggers** mit konfigurierbaren Optionen

### Manuelle Workflow-Ausführung:
1. Gehen Sie zu "Actions" in GitHub
2. Wählen Sie "Build and Push Docker Images"
3. Klicken Sie "Run workflow"
4. Konfigurieren Sie die gewünschten Optionen:
   - PHP Version (optional)
   - Image Type (php, nginx-php-fpm, oder all)
   - Push Images (true/false)

## Umstellung von der alten Struktur

### Was wurde geändert:
1. **Gelöscht**: Alle versionsspezifischen PHP-Ordner (`php/7.4/`, `php/8.0/`, etc.)
2. **Modifiziert**: `php/Dockerfile` verwendet jetzt Build-Args
3. **Modifiziert**: `nginx-php-fpm/Dockerfile` verwendet jetzt Build-Args
4. **Neu**: `build-all.sh` für automatisierte Builds
5. **Neu**: GitHub Actions Workflow
6. **Deprecated**: Das alte `build.sh` Script zeigt jetzt eine Warnung

### Migration für bestehende Builds:

**Alt:**
```bash
./build.sh php/8.2
```

**Neu:**
```bash
./build-all.sh --version 8.2 --php-only
```

## Konfiguration

### Docker Hub Secrets (für GitHub Actions):
Stellen Sie sicher, dass folgende Secrets in GitHub konfiguriert sind:
- `DOCKER_USERNAME`: Ihr Docker Hub Benutzername
- `DOCKER_PASSWORD`: Ihr Docker Hub Access Token

### Environment Variables:
- `PHP_VERSION`: Die zu verwendende PHP-Version (Standard: 8.1)

## Troubleshooting

### Häufige Probleme:

1. **Build-Fehler bei spezifischen PHP-Versionen:**
   - Überprüfen Sie, ob alle erforderlichen PHP-Pakete für die Version verfügbar sind
   - Einige Pakete haben unterschiedliche Namen zwischen PHP-Versionen

2. **GitHub Actions Fehler:**
   - Überprüfen Sie die Docker Hub Credentials
   - Stellen Sie sicher, dass die Secrets korrekt konfiguriert sind

3. **Multi-Platform Build Probleme:**
   - Einige Pakete sind möglicherweise nicht für alle Architekturen verfügbar
   - Entfernen Sie `linux/arm64` aus der Platform-Liste falls nötig

## Support

Bei Problemen oder Fragen zum Build-System, erstellen Sie bitte ein Issue im Repository.
