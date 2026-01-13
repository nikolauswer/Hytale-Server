\# 🛡️ Hytale Server (Linux) - "All-in-One" Setup



Dieses Repository enthält ein vollautomatisiertes Skript (`start.sh`) zum Aufsetzen, Verwalten und Starten eines Hytale-Servers unter Linux.



Es kümmert sich um Updates, Backups, die Ordnerstruktur und den automatischen Neustart bei Abstürzen.



\## ✨ Features des Start-Skripts



\* \*\*Auto-Installation:\*\* Installiert automatisch \*\*Java 25\*\* (Eclipse Temurin) und notwendige Tools (`zip`, `unzip`), falls diese fehlen.

\* \*\*Auto-Update:\*\* Prüft bei jedem Start, ob ein Update für den Server oder den Downloader verfügbar ist.

\* \*\*Struktur:\*\* Hält das Hauptverzeichnis sauber, indem alle Serverdaten automatisch in den Ordner `Server/` sortiert werden.

\* \*\*Backup-System:\*\* Erstellt vor jedem Start ein ZIP-Backup des `universe`-Ordners (Welten \& Spielerdaten) und löscht Backups, die älter als 7 Tage sind.

\* \*\*Crash-Schutz:\*\* Startet den Server automatisch neu, falls er abstürzt.

\* \*\*Log-Rotation:\*\* Löscht alte Log-Dateien, um Speicherplatz zu sparen.



---



\## 🚀 Installation \& Start



\### 1. Vorbereitung

Lege das Skript `start.sh` in deinen gewünschten Ordner (z. B. `~/hytale`).



\### 2. Berechtigungen setzen

Mache das Skript ausführbar:

```bash

chmod +x start.sh

