# 🛡️ Hytale Server (Linux) - "All-in-One" Setup

✅ **Status:** Erfolgreich getestet und verifiziert auf **Ubuntu 25.04 (Plucky Puffin)**.

Dieses Repository enthält ein vollautomatisiertes Skript (`start.sh`) zum Aufsetzen, Verwalten und Starten eines Hytale-Servers unter Linux.

Es kümmert sich um Updates, Backups, die Ordnerstruktur und den automatischen Neustart bei Abstürzen.

## ✨ Features des Start-Skripts

* **Auto-Installation:** Installiert automatisch **Java 25** (Eclipse Temurin) und notwendige Tools (`zip`, `unzip`), falls diese fehlen.
* **Auto-Update:** Prüft bei jedem Start, ob ein Update für den Server oder den Downloader verfügbar ist.
* **Saubere Struktur:** Hält das Hauptverzeichnis ordentlich, indem alle Serverdaten automatisch in den Unterordner `Server/` sortiert werden.
* **Backup-System:** Erstellt vor jedem Start ein ZIP-Backup des `universe`-Ordners (Welten & Spielerdaten) und löscht alte Backups (älter als 7 Tage).
* **Crash-Schutz:** Startet den Server automatisch neu, falls er abstürzt.
* **Log-Rotation:** Löscht alte Log-Dateien, um Speicherplatz zu sparen.

---

## 🚀 Installation & Start

### 1. Vorbereitung
Lege das Skript `start.sh` in deinen gewünschten Ordner (z. B. `~/hytale`).

### 2. Berechtigungen setzen
Mache das Skript ausführbar:

`chmod +x start.sh`

### 3. Server starten
Starte den Server einfach mit:

`./start.sh`

*Das Skript lädt nun automatisch den `hytale-downloader`, installiert Java (falls nötig) und lädt die Spieldateien in den Ordner `Server/` herunter.*

---

## 🔐 Erste Einrichtung (WICHTIG!)

Beim allerersten Start (oder nach einer Neuinstallation) musst du den Server verknüpfen.

1.  Starte das Skript. Es wird dich warnen, dass die Authentifizierung fehlt.
2.  Warte, bis der Server vollständig geladen ist.
3.  Gib in der Konsole folgenden Befehl ein:
    
    `/auth login device`
    
4.  Öffne den angezeigten Link im Browser (PC/Handy) und gib den Code ein.
5.  **DAMIT ES GESPEICHERT BLEIBT:** Gib danach ein:
    
    `/auth persistence Encrypted`
    
    *(Wähle ein Passwort. Merke es dir gut, der Server fragt eventuell beim Neustart danach!)*

---

## 📂 Ordnerstruktur

Das Skript sorgt automatisch für Ordnung. Dein Verzeichnis sieht so aus:


```text
~/hytale/
├── start.sh                        # Das Steuer-Skript (HIER STARTEN)
├── README.md                       # Diese Datei
├── hytale-downloader-linux-amd64   # Das Download-Tool
├── backups/                        # Hier landen die ZIP-Backups
└── Server/                         # <-- HIER IST DER EIGENTLICHE SERVER
    ├── HytaleServer.jar
    ├── Assets.zip
    ├── universe/                   # Deine Welt & Spielerdaten
    ├── logs/                       # Log-Dateien
    ├── credentials.json            # Dein Login-Token
    └── ...
```


---

## ⏰ Automatischer Neustart (Cronjob)

Um den Server jeden Morgen automatisch neu zu starten (für Backups und RAM-Bereinigung), richte einen Cronjob ein.

1.  Öffne den Editor: `crontab -e`
2.  Füge folgende Zeile am Ende ein (Beispiel für 04:00 Uhr morgens):

`0 4 * * * pkill -f HytaleServer.jar`

**Wie das funktioniert:**
Der Befehl "tötet" den Java-Prozess um 4 Uhr. Die \`while true\`-Schleife im \`start.sh\`-Skript bemerkt das, erstellt ein frisches Backup und startet den Server sofort wieder neu.

---

## 🛠️ Troubleshooting

| Problem | Lösung |
| :--- | :--- |
| **Server startet immer neu (Loop)?** | Drücke `STRG + C`. Das bricht zuerst Java ab, beim zweiten Drücken das Skript. |
| **Update wird nicht angezeigt?** | Lösche die Versionsdatei, um ein Update zu erzwingen: `rm Server/.version` |
| **Auth Failed / Token weg?** | Lösche die Zugangsdaten und starte neu: `rm Server/credentials.json` |
| **Keine Verbindung?** | Prüfe die Firewall (UDP Port 5520): `sudo ufw allow 5520/udp` |
EOF