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

\### 3. Server starten

```bash

./start.sh

Das Skript lädt nun automatisch den Hytale-downloader, installiert Java (falls nötig) und lädt die Spieldateien herunter.

\## Erste Einrichtung (Authentifizierung)

Beim allerersten Start (oder wenn du den Server neu installierst), musst du den Server mit deinem Hytale-Account verknüpfen.

    Starte das Skript. Es wird dich warnen, dass die Authentifizierung fehlt.

    Warte, bis der Server vollständig geladen ist.

    Gib in der Konsole folgenden Befehl ein:

    /auth login device

    Öffne den angezeigten Link im Browser (PC/Handy) und gib den Code ein.

    WICHTIG: Damit der Login gespeichert bleibt, gib danach ein:

    /auth persistence Encrypted

    (Du musst ein Passwort vergeben. Merke dir dieses, der Server fragt evtl. beim Neustart danach!)

\## 📂 Ordnerstruktur

Nach dem ersten Start sieht dein Verzeichnis so aus:
Plaintext

~/hytale/
├── start.sh                        # Das Steuer-Skript
├── README.md                       # Diese Datei
├── hytale-downloader-linux-amd64   # Das Download-Tool
├── backups/                        # Hier landen die ZIP-Backups
└── Server/                         # <-- HIER IST DEIN SERVER
    ├── HytaleServer.jar
    ├── Assets.zip
    ├── universe/                   # Deine Welt & Spielerdaten
    ├── logs/                       # Log-Dateien
    ├── credentials.json            # Dein Login-Token
    └── ...

\## ⏰ Automatischer Neustart (Cronjob)

Um den Server jeden Morgen automatisch neu zu starten (für Backups und RAM-Bereinigung), richte einen Cronjob ein.

    Öffne den Editor: crontab -e

    Füge folgende Zeile am Ende ein (Beispiel für 04:00 Uhr morgens):

Bash

0 4 * * * pkill -f HytaleServer.jar

Wie das funktioniert: Der Befehl "tötet" den Java-Prozess um 4 Uhr. Die while true-Schleife im start.sh-Skript bemerkt das, erstellt ein frisches Backup und startet den Server sofort wieder neu.
\## 🛠️ Troubleshooting
Der Server startet immer wieder neu (Loop)?

Drücke im Terminal STRG + C. Das bricht zuerst den Java-Prozess und beim zweiten Drücken das Skript ab.
"Update verfügbar" Meldung erscheint nicht?

Das Skript prüft die Version anhand der Datei Server/.version. Wenn du ein Update erzwingen willst, lösche diese Datei einfach:
Bash

rm Server/.version

Authentication Failed / Token Lost?

Wenn der Server dich nicht mehr reinlässt, lösche die Credentials und melde dich neu an:
Bash

rm Server/credentials.json
# Danach Server neu starten und Schritt "Erste Einrichtung" wiederholen

Firewall (Spieler können nicht joinen)

Stelle sicher, dass der UDP-Port freigegeben ist:
Bash

sudo ufw allow 5520/udp


***

**Soll ich dir noch zeigen, wie du das `README.md` direkt auf deinem Server erstel