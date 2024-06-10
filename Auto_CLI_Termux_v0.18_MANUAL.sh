#!/bin/bash

# Define CLI variables
REVANCED_CLI="revanced-cli-4.6.0-all.jar"
REVANCED_PATCHES="revanced-patches-4.9.0.jar"
REVANCED_INTEGRATIONS="revanced-integrations-1.10.0.apk"

# DL Links
DL_LINK_CLI="https://github.com/ReVanced/revanced-cli/releases/download/v4.6.0/revanced-cli-4.6.0-all.jar"
DL_LINK_PATCHES="https://github.com/ReVanced/revanced-patches/releases/download/v4.9.0/revanced-patches-4.9.0.jar"
DL_LINK_INTEGRATIONS="https://github.com/ReVanced/revanced-integrations/releases/download/v1.10.0/revanced-integrations-1.10.0.apk"

# APK Versions
YOUTUBE_VERSION="19.16.39"
YOUTUBE_MUSIC_VERSION="7.03.52"
TIKTOK_VERSION="32.5.3"
REDDIT_VERSION="2024.17.0"

# Define APK filenames
YOUTUBE_NEW_FILENAME="Youtube_${YOUTUBE_VERSION}.apk"
YOUTUBE_MUSIC_NEW_FILENAME="Youtube_Music_${YOUTUBE_MUSIC_VERSION}.apk"
TIKTOK_NEW_FILENAME="TikTok_${TIKTOK_VERSION}.apk"
REDDIT_NEW_FILENAME="Reddit_${REDDIT_VERSION}.apk"
UNIVERSAL_APK="Universal_x.x.x.apk"

# Check processor architecture
ARCH=$(uname -m)

if [[ "$ARCH" == "armv7l" || "$ARCH" == "armv7" || "$ARCH" == "armv7a" ]]; then
    echo "The CLI does not support ARMv7 devices, please use another device."
    exit 1
fi

# Check if OpenJDK 17 is installed
check_openjdk() {
    if java -version 2>&1 | grep -q "17"; then
        echo "OpenJDK 17 is already installed."
    else
        echo "OpenJDK 17 is not installed. Installation in progress..."
        pkg update
        pkg install -y openjdk-17-jdk
        if [ $? -eq 0 ]; then
            echo "OpenJDK 17 successfully installed."
        else
            echo "Error during OpenJDK 17 installation."
            exit 1
        fi
    fi
}

# Check if wget is installed
check_wget() {
    if command -v wget &> /dev/null; then
        echo "wget is already installed."
    else
        echo "wget is not installed. Installation in progress..."
        pkg update
        pkg install -y wget
        if [ $? -eq 0 ]; then
            echo "wget successfully installed."
        else
            echo "Error during wget installation."
            exit 1
        fi
    fi
}

# Download
download_direct() {
    local url=$1
    local dest_filename=$2
    local dest_dir=$3

    # Check if the file already exists
    if [ -f "$dest_dir/$dest_filename" ]; then
        echo "The $dest_filename file is already present."
    else
        wget -O "$dest_dir/$dest_filename" "$url"

        if [ $? -eq 0 ]; then
            echo "Successful download : $dest_filename"
        else
            echo "Error while downloading : $dest_filename"
            exit 1
        fi
    fi
}

# Check that the user has correctly placed the .APK file
check_apk() {
    local apk_dir="$1"
    local apk_name="$2"

    read -p "Have you correctly placed the $apk_name APK in the $apk_dir folder? (Y/N) " answer

    if [[ "$answer" != [Yy] ]]; then
        echo "Please place the APK $apk_name in $apk_dir before continuing."
        read -p "Press a key to continue once you've placed the APK in the correct folder."
    fi
}

# Rename an .apk file in a specified folder
rename_apk() {
    local apk_dir="$1"
    local new_name="$2"

    apk_file=$(find "$apk_dir" -type f -name "*.apk" | head -n 1)

    if [ -n "$apk_file" ]; then
        mv "$apk_file" "$apk_dir/$new_name"
        echo "The .apk file in $apk_dir has been renamed to $new_name."
    else
        echo "No .apk files found in '$apk_dir' folder."
    fi
}

# Clean CLI files and APK folder
clean_destination_dir() {
    local dest_dir=$1

    echo "Cleaning up the $dest_dir folder..."
    find "$dest_dir" -mindepth 1 -maxdepth 1 ! -name "Patched_Apps" -exec rm -rf {} \;

    if [ $? -eq 0 ]; then
        echo "The $dest_dir folder has been successfully cleaned."
    else
        echo "Error cleaning $dest_dir folder."
        exit 1
    fi
}

# Destination directory
DEST_DIR="$HOME/Downloads/Auto_CLI_Termux"

if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
fi

APK_DIR="$DEST_DIR/APK"
if [ ! -d "$APK_DIR" ]; then
    mkdir -p "$APK_DIR"
fi

# Create folders if they don't exist
for dir in "Patched_Apps" "Patched_Apps/Youtube Patched" "Patched_Apps/Youtube Music Patched" "Patched_Apps/TikTok Patched" "Patched_Apps/Universal Patched" "APK/Youtube APK" "APK/Youtube Music APK" "APK/TikTok APK" "APK/Universal APK" "Patched_Apps/Reddit Patched" "APK/Reddit APK"; do
    if [ ! -d "$DEST_DIR/$dir" ]; then
        mkdir -p "$DEST_DIR/$dir"
    fi
done

# Checks and installs dependencies if necessary
check_openjdk
check_wget

# Download files for CLI
download_direct "$DL_LINK_CLI" "$REVANCED_CLI" "$DEST_DIR"
download_direct "$DL_LINK_PATCHES" "$REVANCED_PATCHES" "$DEST_DIR"
download_direct "$DL_LINK_INTEGRATIONS" "$REVANCED_INTEGRATIONS" "$DEST_DIR"

# Ask the user what action they want to perform
echo "What do you want to do?"
echo "1. - Patch YouTube ($YOUTUBE_VERSION) (Stock Logo)"
echo "2. - Patch YouTube ($YOUTUBE_VERSION) (ReVanced Logo)"
echo "3. - Patch YouTube Music ($YOUTUBE_MUSIC_VERSION)"
echo "4. - Patch TikTok ($TIKTOK_VERSION)"
echo "5. - Patch Reddit ($REDDIT_VERSION)"
echo "U. - (Universal) Patch an application not listed here, with default patches and default options"
echo "C. - Clean CLI files and APK folder and close script"
echo "E. - Exit script"
read -p "Choose an option [1/2/3/4/5/U/C/E]: " choice

case $choice in
    1)
        # Youtube Stock logo
        check_apk "$DEST_DIR/APK/Youtube APK" "$YOUTUBE_NEW_FILENAME"
        # Rename APK before patching
        rename_apk "$APK_DIR/Youtube APK" "$YOUTUBE_NEW_FILENAME"

        if [ ! -f "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME" ]; then
            echo "Error: The file $YOUTUBE_NEW_FILENAME is not present in $APK_DIR/Youtube APK."
            exit 1
        fi

        # Patch the app
        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Youtube Patched/Stock_Patched_${YOUTUBE_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo "The YouTube application has been successfully patched in $DEST_DIR/Patched_Apps/Youtube Patched."
        else
            echo "Error while patching the Youtube application."
            exit 1
        fi
        ;;
    2)
        # Youtube Custom branding
        check_apk "$DEST_DIR/APK/Youtube APK" "$YOUTUBE_NEW_FILENAME"
        rename_apk "$APK_DIR/Youtube APK" "$YOUTUBE_NEW_FILENAME"

        if [ ! -f "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME" ]; then
            echo "Error: The file $YOUTUBE_NEW_FILENAME is not present in $APK_DIR/Youtube APK."
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -i 'Custom branding' -o "./Patched_Apps/Youtube Patched/Logo_Patched_${YOUTUBE_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo "The YouTube application with ReVanced Logo has been successfully patched in $DEST_DIR/Patched_Apps/Youtube Patched."
        else
            echo "Error while patching the Youtube application."
            exit 1
        fi
        ;;
    3)
        #Youtube_Music
        check_apk "$DEST_DIR/APK/Youtube Music APK" "$YOUTUBE_MUSIC_NEW_FILENAME"
        rename_apk "$APK_DIR/Youtube Music APK" "$YOUTUBE_MUSIC_NEW_FILENAME"

        if [ ! -f "$APK_DIR/Youtube Music APK/$YOUTUBE_MUSIC_NEW_FILENAME" ]; then
            echo "Error: The file $YOUTUBE_MUSIC_NEW_FILENAME is not present in $APK_DIR/Youtube Music APK."
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Youtube Music Patched/Patched_${YOUTUBE_MUSIC_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube Music APK/$YOUTUBE_MUSIC_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo "The Youtube Music application has been successfully patched in $DEST_DIR/Patched_Apps/Youtube Music Patched."
        else
            echo "Error while patching the Youtube Music application."
            exit 1
        fi
        ;;
    4)
        # TikTok
        check_apk "$DEST_DIR/APK/TikTok APK" "$TIKTOK_NEW_FILENAME"
        rename_apk "$APK_DIR/TikTok APK" "$TIKTOK_NEW_FILENAME"

        if [ ! -f "$APK_DIR/TikTok APK/$TIKTOK_NEW_FILENAME" ]; then
            echo "Error: The file $TIKTOK_NEW_FILENAME is not present in $APK_DIR/TikTok APK."
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/TikTok Patched/Patched_${TIKTOK_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/TikTok APK/$TIKTOK_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo "The TikTok application has been successfully patched in $DEST_DIR/Patched_Apps/TikTok Patched."
        else
            echo "Error while patching the TikTok application."
            exit 1
        fi
        ;;
    5)
        # Reddit
        check_apk "$DEST_DIR/APK/Reddit APK" "$REDDIT_NEW_FILENAME"
        rename_apk "$APK_DIR/Reddit APK" "$REDDIT_NEW_FILENAME"

        if [ ! -f "$APK_DIR/Reddit APK/$REDDIT_NEW_FILENAME" ]; then
            echo "Error: The $REDDIT_NEW_FILENAME file is not present in $APK_DIR/Reddit APK."
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Reddit Patched/Patched_${REDDIT_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Reddit APK/$REDDIT_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo "The Reddit application has been successfully patched in $DEST_DIR/Patched_Apps/Reddit Patched."
        else
            echo "Error while patching the Reddit application."
            exit 1
        fi
        ;;
    [Uu])
        # Universal APK
        check_apk "$DEST_DIR/APK/Universal APK" "$UNIVERSAL_APK"
        rename_apk "$APK_DIR/Universal APK" "$UNIVERSAL_APK"

        if [ ! -f "$APK_DIR/Universal APK/$UNIVERSAL_APK" ]; then
            echo "Error: The $UNIVERSAL_APK file is not present in $APK_DIR/Universal APK."
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Universal Patched/Patched_${UNIVERSAL_APK}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Universal APK/$UNIVERSAL_APK"

        if [ $? -eq 0 ]; then
            echo "The (Universal) application has been successfully patched in $DEST_DIR/Patched_Apps/Universal Patched."
        else
            echo "Error while patching the (Universal) application."
            exit 1
        fi
        ;;
    [Cc])
        # Clean Files
        clean_destination_dir "$DEST_DIR"
        echo "Script finished."
        exit 0
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
    [Ee])
        # Exit
        echo "Script finished."
        exit 0
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac
