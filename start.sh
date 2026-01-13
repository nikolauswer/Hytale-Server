#!/bin/bash

# --- KONFIGURATION ---
SERVER_DIR="Server"
DOWNLOADER_BIN="./hytale-downloader-linux-amd64"
DOWNLOADER_URL="https://downloader.hytale.com/hytale-downloader.zip"
GAME_ZIP="game.zip"

# Erstelle Server-Ordner, falls nicht vorhanden
mkdir -p "$SERVER_DIR"

# --- 1. SYSTEM & JAVA CHECK ---
echo "--- [1/6] System-Check ---"
if ! command -v java &> /dev/null || [[ $(java -version 2>&1 | head -n 1) != *"25"* ]]; then
    echo "Java 25 fehlt. Installiere..."
    sudo apt update && sudo apt install -y wget apt-transport-https gnupg zip unzip
    sudo wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /usr/share/keyrings/adoptium.gpg
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb noble main" | sudo tee /etc/apt/sources.list.d/adoptium.list
    sudo apt update && sudo apt install -y temurin-25-jdk
fi

# --- 2. DOWNLOADER TOOL CHECK ---
echo "--- [2/6] Prüfe Downloader-Tool ---"
if [ ! -f "$DOWNLOADER_BIN" ]; then
    wget -O tool.zip $DOWNLOADER_URL
    unzip -j tool.zip "hytale-downloader-linux-amd64" -d .
    chmod +x $DOWNLOADER_BIN
    rm tool.zip
fi

# Tool-Update Check (15s Timeout)
TOOL_UPDATE_MSG=$($DOWNLOADER_BIN -check-update)
if [[ "$TOOL_UPDATE_MSG" == *"available"* ]]; then
    echo "Update für Downloader gefunden!"
    read -t 15 -p "Downloader aktualisieren? (j/n): " TOOL_CHOICE
    if [[ "$TOOL_CHOICE" == "j" || "$TOOL_CHOICE" == "J" ]]; then
        wget -O tool.zip $DOWNLOADER_URL
        unzip -jo tool.zip "hytale-downloader-linux-amd64" -d .
        chmod +x $DOWNLOADER_BIN
        rm tool.zip
    fi
fi

# --- 3. GAME-UPDATE & DATEI-STRUKTUR ---
echo "--- [3/6] Prüfe Hytale Server Version ---"

REMOTE_VERSION=$($DOWNLOADER_BIN -print-version)
if [ -f "$SERVER_DIR/.version" ]; then
    LOCAL_VERSION=$(cat "$SERVER_DIR/.version")
else
    LOCAL_VERSION="Keine (Neuinstallation)"
fi

NEEDS_UPDATE=false
if [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    echo "Update verfügbar ($LOCAL_VERSION -> $REMOTE_VERSION)"
    # Bei Neuinstallation sofort laden, sonst fragen (15s Timeout)
    if [ "$LOCAL_VERSION" == "Keine (Neuinstallation)" ]; then
        GAME_CHOICE="j"
    else
        read -t 15 -p "Server jetzt updaten? (j/n): " GAME_CHOICE
    fi

    if [[ "$GAME_CHOICE" == "j" || "$GAME_CHOICE" == "J" ]]; then
        # Backup vor Update
        if [ -d "$SERVER_DIR/universe" ]; then
            zip -r "backup_pre_update.zip" "$SERVER_DIR/universe" -q
        fi

        $DOWNLOADER_BIN -download-path $GAME_ZIP
        
        if [ -f "$GAME_ZIP" ]; then
            echo "Entpacke & Sortiere in '$SERVER_DIR'..."
            unzip -o $GAME_ZIP
            
            # AUFRÄUMEN: Alles muss in den Server-Ordner
            # 1. HytaleServer.jar ist meist schon in Server/ durch die Zip
            # 2. Assets.zip liegt oft im Root -> Verschieben!
            if [ -f "Assets.zip" ]; then
                mv Assets.zip "$SERVER_DIR/"
            fi
            
            rm $GAME_ZIP
            echo "$REMOTE_VERSION" > "$SERVER_DIR/.version"
            echo "Installation erfolgreich!"
        fi
    fi
fi

# --- 4. BACKUP (UNIVERSE) ---
echo "--- [4/6] Routine-Backup ---"
BACKUP_DIR="./backups"
if [ -d "$SERVER_DIR/universe" ]; then
    mkdir -p $BACKUP_DIR
    # Wir zippen direkt aus dem Server-Ordner heraus
    zip -r "${BACKUP_DIR}/backup_universe_$(date +%F_%H-%M).zip" "$SERVER_DIR/universe" -q
    find $BACKUP_DIR -name "*.zip" -mtime +7 -delete
fi

# --- 5. AUTH CHECK (Im Server-Ordner suchen) ---
if [ ! -f "$SERVER_DIR/credentials.json" ] && [ ! -f "$SERVER_DIR/credentials.enc" ]; then
    clear
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "ERSTEINRICHTUNG NÖTIG!"
    echo "1. Warte bis der Server läuft."
    echo "2. Tippe: /auth login device"
    echo "3. Tippe: /auth persistence Encrypted"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    sleep 10
fi

# --- 6. SERVER START ---
echo "--- [6/6] Starte Server in Ordner '$SERVER_DIR' ---"


# WICHTIG: Wir wechseln in den Ordner, damit Logs/Configs dort landen
cd "$SERVER_DIR" || exit

while true; do
    # Pfade sind jetzt lokal, da wir im Ordner sind
    java -jar HytaleServer.jar --assets Assets.zip
    
    EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Server manuell gestoppt."
        break
    else
        echo "Neustart in 5s..."
        sleep 5
    fi
done

# Zurück zum Hauptverzeichnis, falls das Skript weiterläuft
cd ..