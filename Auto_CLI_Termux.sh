#!/bin/bash

#version 0.38

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${GREEN}"
echo "           ====================================="
echo "                  >>  Auto CLI Termux  <<"
echo "           ====================================="
echo -e "${NC}"
echo "     The script will download and install if necessary:"
echo "                      - Open JDK 17"
echo "             - The files required for the CLI"
echo "          - Dependencies needed to run the script"
echo
echo "    Also, all .apk files come from [apkmirror.com], they"
echo "  are downloaded by myself and uploaded to [pixeldrain.com]"
echo "       so that the script can download them (because"
echo "   it's impossible to do this simply via [apkmirror.com])."
echo -e "${CYAN}"
echo "             Do you want to continue? (Y/n)"
echo -e "${NC}"

read -p " Choose an option and press [ENTER] [Y/n]: " choice

case "$choice" in
    [Yy]*|"")
        echo "Continuing with the script..."
        ;;
    [Nn]*)
        echo "Exiting the script. Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid option. Exiting the script."
        exit 1
        ;;
esac

# Check and request storage authorizations
echo "y" | termux-setup-storage

check_storage_permissions() {

    while ! ls -l "/storage/emulated/0/Download" >/dev/null 2>&1; do
        echo -e "${BLUE}Waiting for user to grant storage permissions...${NC}"
        sleep 1
    done
    echo -e "${GREEN}Storage permissions granted. Continuing...${NC}"
}

# Check hash tools
check_hash_tools() {
    for tool in md5sum sha1sum sha256sum; do
        if ! command -v $tool &> /dev/null; then
            echo "$tool could not be found. Installing..."
            pkg install -y coreutils
            break
        fi
    done
}

# checks file's hash
verify_hash() {
    local file_path="$1"
    local expected_hash="$2"
    local hash_type="$3"

    if [ ! -f "$file_path" ]; then
        return 1
    fi

    local computed_hash
    case "$hash_type" in
        md5)
            computed_hash=$(md5sum "$file_path" | awk '{ print $1 }')
            ;;
        sha1)
            computed_hash=$(sha1sum "$file_path" | awk '{ print $1 }')
            ;;
        sha256)
            computed_hash=$(sha256sum "$file_path" | awk '{ print $1 }')
            ;;
        *)
            return 1
            ;;
    esac

    if [ "$computed_hash" != "$expected_hash" ]; then
        return 1
    else
        return 0
    fi
}

# Sources
source_variables() {
    local variables_url="https://raw.githubusercontent.com/Purple-EyeZ/Auto_CLI_Linux/main/variables.sh"
    local temp_file="$DEST_DIR/Sources/variables.sh"

    wget -q -O "$temp_file" "$variables_url"
    if [ $? -eq 0 ]; then
        source "$temp_file"
        echo -e "${GREEN}Variables have been loaded successfully.${NC}"
    else
        echo -e "${RED}Error while downloading variables. Be sure to grant Termux access to storage and re-run the script.${NC}"
        exit 1
    fi
}

# Check if OpenJDK 17 is installed
check_openjdk() {
    if java -version 2>&1 | grep -q "17"; then
        echo "OpenJDK 17 is already installed."
    else
        echo -e "${BLUE}OpenJDK 17 is not installed. Installation in progress...${NC}"
        export DEBIAN_FRONTEND=noninteractive
        pkg install -y openjdk-17
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}OpenJDK 17 successfully installed.${NC}"
        else
            echo -e "${RED}Error during OpenJDK 17 installation, please re-run the script${NC}"
            exit 1
        fi
    fi
}

# Check if wget is installed
check_wget() {
  if command -v wget &> /dev/null; then
    echo "wget is already installed."
  else
    echo -e "${BLUE}wget is not installed. Installation in progress...${NC}"
    export DEBIAN_FRONTEND=noninteractive
    pkg update -y && pkg upgrade -y
    pkg install -y wget
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}wget successfully installed.${NC}"
    else
      echo -e "${RED}Error during wget installation, please re-run the script${NC}"
      exit 1
    fi
  fi
}

# Download and check hash
download_and_verify() {
    local file_url="$1"
    local file_name="$2"
    local download_dir="$3"
    local expected_hash="$4"
    local hash_type="$5"
    local max_attempts=4
    local attempt=1

    mkdir -p "$download_dir"

    while [ $attempt -le $max_attempts ]; do
        if [ -f "$download_dir/$file_name" ]; then
            if verify_hash "$download_dir/$file_name" "$expected_hash" "$hash_type"; then
                echo -e "${GREEN}$file_name already exists in $download_dir and the hash is correct.${NC}"
                return 0
            else
                echo -e "${RED}Error: The hash of $file_name does not match the expected hash. Deleting file and retrying.${NC}"
                rm -f "$download_dir/$file_name"
            fi
        fi

        echo -e "${BLUE}Downloading file from${MAGENTA} $file_url ${BLUE}to $download_dir/$file_name...${NC}"
        wget -q --show-progress -O "$download_dir/$file_name" "$file_url"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}$file_name has been successfully downloaded to $download_dir${NC}"
            if verify_hash "$download_dir/$file_name" "$expected_hash" "$hash_type"; then
                return 0
            else
                echo -e "${RED}Error: The downloaded file's hash does not match the expected hash. Deleting file and retrying download.${NC}"
                rm -f "$download_dir/$file_name"
            fi
        else
            echo -e "${RED}Error downloading file from $file_url. Retrying... (${attempt}/${max_attempts})${NC}"
            rm -f "$download_dir/$file_name"
        fi

        attempt=$((attempt + 1))
    done

    echo -e "${RED}Error: Failed to download the file after ${max_attempts} attempts. Please check your internet connection. Try changing your DNS or try a VPN to another country.${NC}"
    return 1
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

# Complete Wipe
complete_wipe() {
    local dest_dir=$1

    echo -e "${BLUE}Cleaning up everything in the $dest_dir folder...${NC}"

    rm -rf "${dest_dir:?}/"*

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}The $dest_dir folder has been completely cleaned.${NC}"
    else
        echo -e "${RED}Error cleaning $dest_dir folder.${NC}"
        exit 1
    fi
}

# Clean CLI files
clean_destination_dir() {
    local dest_dir=$1

    echo -e "${BLUE}Cleaning up the $dest_dir folder...${NC}"

    # Check if the directory exists
    if [ -d "$dest_dir" ]; then
        find "$dest_dir" -mindepth 1 -maxdepth 1 ! -name "Patched_Apps" ! -name "APK" -exec rm -rf {} \;

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}The $dest_dir folder has been successfully cleaned.${NC}"
        else
            echo -e "${RED}Error cleaning $dest_dir folder.${NC}"
            exit 1
        fi
    else
        echo "The $dest_dir folder does not exist. Skipping cleanup."
    fi
}

# Moving files (Use of a Termux internal directory as an output directory to improve performance)
move_files() {
    local source_dir="$1"
    local destination_dir="$2"

    if [ ! -d "$source_dir" ]; then
        echo "The source directory $source_dir does not exist."
        return 1
    fi

    mkdir -p "$destination_dir"

    if ls "$source_dir"/*.apk 1> /dev/null 2>&1; then
        mv "$source_dir"/*.apk "$destination_dir"
        echo "Files successfully moved"
    else
        echo "No .apk files found in $source_dir"
    fi
}

# Destination directory (/storage/emulated/0/Download/Auto_CLI_Termux) ($HOME/storage/downloads/Auto_CLI_Termux) ($HOME/Auto_CLI_Termux)
DEST_DIR="$HOME/storage/downloads/Auto_CLI_Termux"

if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
fi

APK_DIR="$DEST_DIR/APK"
if [ ! -d "$APK_DIR" ]; then
    mkdir -p "$APK_DIR"
fi

# Use of an internal Termux directory to improve performance
OUTPUT_DIR="$HOME/Auto_CLI_Termux/Patched_Apps"
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir -p "$OUTPUT_DIR"
fi

# Create folders if they don't exist
for dir in "Patched_Apps" "APK/Universal APK" "Sources"; do
    if [ ! -d "$DEST_DIR/$dir" ]; then
        mkdir -p "$DEST_DIR/$dir"
    fi
done

# Check and install dependencies if necessary
check_storage_permissions
check_wget
check_openjdk
check_hash_tools
sleep 2
source_variables

# Download files for CLI
download_and_verify "https://github.com/ReVanced/revanced-manager/raw/main/android/app/src/main/jniLibs/arm64-v8a/libaapt2.so" "libaapt2.so" "$HOME/Auto_CLI_Termux" "5b3b135a019d122d8ac9841388ac9628" "md5"

download_and_verify "$DL_LINK_CLI" "$REVANCED_CLI" "$DEST_DIR" "$HASH_CLI" "md5"

download_and_verify "$DL_LINK_PATCHES" "$REVANCED_PATCHES" "$DEST_DIR" "$HASH_PATCHES" "md5"

download_and_verify "$DL_LINK_INTEGRATIONS" "$REVANCED_INTEGRATIONS" "$DEST_DIR" "$HASH_INTEGRATIONS" "md5"

chmod +x $HOME/Auto_CLI_Termux/libaapt2.so

# Ask the user what action they want to perform
echo
echo
echo -e "${CYAN}> What do you want to do?${NC}"
echo -e "    ${CYAN}1.${NC} Patch YouTube ${YELLOW}(Stock Logo)${NC} ${MAGENTA}($YOUTUBE_VERSION)${NC}"
echo -e "    ${CYAN}2.${NC} Patch YouTube ${YELLOW}(ReVanced Logo)${NC} ${MAGENTA}($YOUTUBE_VERSION)${NC}"
echo -e "    ${CYAN}3.${NC} Patch YouTube Music ${YELLOW}(ARMv8a)${NC} ${MAGENTA}($YOUTUBE_MUSIC_VERSION)${NC}"
echo -e "    ${CYAN}4.${NC} Patch YouTube Music ${YELLOW}(ARMv7a)${NC} ${MAGENTA}($YOUTUBE_MUSIC_VERSION)${NC}"
echo -e "    ${CYAN}5.${NC} Patch TikTok ${MAGENTA}($TIKTOK_VERSION)${NC}"
echo -e "    ${CYAN}6.${NC} Patch Reddit ${MAGENTA}($REDDIT_VERSION)${NC}"
echo -e "    ${CYAN}7.${NC} Patch Twitter ${YELLOW}(Android 8+)${NC} ${MAGENTA}($TWITTER_VERSION)${NC}"
echo
echo -e "${BLUE}C. Clean CLI files and close script${NC}"
echo -e "${RED}E. Exit script${NC}"
echo
read -p " Choose an option and press [ENTER] [1/2/3/4/5/6/7/C/E]: " choice

case $choice in
    1)
        # Youtube Stock logo
        download_and_verify "$DL_LINK_YOUTUBE" "$YOUTUBE_NEW_FILENAME" "$APK_DIR/Youtube APK" "$HASH_YOUTUBE" "md5"

        if [ ! -f "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The file $YOUTUBE_NEW_FILENAME is not present in $APK_DIR/Youtube APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        # Patch the app
        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "$OUTPUT_DIR/Youtube Patched/Stock_Patched_${YOUTUBE_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME" --custom-aapt2-binary "$HOME/Auto_CLI_Termux/libaapt2.so"

        if [ $? -eq 0 ]; then
            move_files "$OUTPUT_DIR/Youtube Patched" "$HOME/storage/downloads/Auto_CLI_Termux/Patched_Apps"
            echo -e "${GREEN}The YouTube application has been successfully patched in ./Internal Storage/Download/Auto_CLI_Termux/Patched_Apps."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Youtube application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    2)
        # Youtube Custom branding
        download_and_verify "$DL_LINK_YOUTUBE" "$YOUTUBE_NEW_FILENAME" "$APK_DIR/Youtube APK" "$HASH_YOUTUBE" "md5"

        if [ ! -f "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The file $YOUTUBE_NEW_FILENAME is not present in $APK_DIR/Youtube APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -i 'Custom branding' -o "$OUTPUT_DIR/Youtube Patched/Logo_Patched_${YOUTUBE_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME" --custom-aapt2-binary "$HOME/Auto_CLI_Termux/libaapt2.so"

        if [ $? -eq 0 ]; then
            move_files "$OUTPUT_DIR/Youtube Patched" "$HOME/storage/downloads/Auto_CLI_Termux/Patched_Apps"
            echo -e "${GREEN}The YouTube application with ReVanced Logo has been successfully patched in ./Internal Storage/Download/Auto_CLI_Termux/Patched_Apps."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Youtube application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    3)
        # Youtube_Music_ARMv8
        download_and_verify "$DL_LINK_YOUTUBE_MUSIC" "$YOUTUBE_MUSIC_NEW_FILENAME" "$APK_DIR/Youtube Music APK (ARMv8a)" "$HASH_YOUTUBE_MUSIC" "md5"

        if [ ! -f "$APK_DIR/Youtube Music APK (ARMv8a)/$YOUTUBE_MUSIC_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The file $YOUTUBE_MUSIC_NEW_FILENAME is not present in $APK_DIR/Youtube Music APK (ARMv8a). Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "$OUTPUT_DIR/Youtube Music Patched/Patched_${YOUTUBE_MUSIC_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube Music APK (ARMv8a)/$YOUTUBE_MUSIC_NEW_FILENAME" --custom-aapt2-binary "$HOME/Auto_CLI_Termux/libaapt2.so"

        if [ $? -eq 0 ]; then
            move_files "$OUTPUT_DIR/Youtube Music Patched" "$HOME/storage/downloads/Auto_CLI_Termux/Patched_Apps"
            echo -e "${GREEN}The Youtube Music application has been successfully patched in ./Internal Storage/Download/Auto_CLI_Termux/Patched_Apps."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Youtube Music application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    4)
        # Youtube_Music_ARMv7
        download_and_verify "$DL_LINK_YOUTUBE_MUSIC_V7" "$YOUTUBE_MUSIC_NEW_FILENAME_V7" "$APK_DIR/Youtube Music APK (ARMv7a)" "$HASH_YOUTUBE_MUSIC_V7" "md5"

        if [ ! -f "$APK_DIR/Youtube Music APK (ARMv7a)/$YOUTUBE_MUSIC_NEW_FILENAME_V7" ]; then
            echo -e "${RED}Error: The file $YOUTUBE_MUSIC_NEW_FILENAME_V7 is not present in $APK_DIR/Youtube Music APK (ARMv7a). Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "$OUTPUT_DIR/Youtube Music Patched/Patched_${YOUTUBE_MUSIC_NEW_FILENAME_V7}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube Music APK (ARMv7a)/$YOUTUBE_MUSIC_NEW_FILENAME_V7" --custom-aapt2-binary "$HOME/Auto_CLI_Termux/libaapt2.so"

        if [ $? -eq 0 ]; then
            move_files "$OUTPUT_DIR/Youtube Music Patched" "$HOME/storage/downloads/Auto_CLI_Termux/Patched_Apps"
            echo -e "${GREEN}The Youtube Music application has been successfully patched in ./Internal Storage/Download/Auto_CLI_Termux/Patched_Apps."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Youtube Music application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    5)
        # TikTok (Shitty App)
        download_and_verify "$DL_LINK_TIKTOK" "$TIKTOK_NEW_FILENAME" "$APK_DIR/TikTok APK" "$HASH_TIKTOK" "md5"

        if [ ! -f "$APK_DIR/TikTok APK/$TIKTOK_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The file $TIKTOK_NEW_FILENAME is not present in $APK_DIR/TikTok APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -i 'SIM spoof' -o "$OUTPUT_DIR/TikTok Patched/Patched_${TIKTOK_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/TikTok APK/$TIKTOK_NEW_FILENAME" --custom-aapt2-binary "$HOME/Auto_CLI_Termux/libaapt2.so"

        if [ $? -eq 0 ]; then
            move_files "$OUTPUT_DIR/TikTok Patched" "$HOME/storage/downloads/Auto_CLI_Termux/Patched_Apps"
            echo -e "${GREEN}The TikTok application has been successfully patched in ./Internal Storage/Download/Auto_CLI_Termux/Patched_Apps."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the TikTok application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    6)
        # Reddit
        download_and_verify "$DL_LINK_REDDIT" "$REDDIT_NEW_FILENAME" "$APK_DIR/Reddit APK" "$HASH_REDDIT" "md5"

        if [ ! -f "$APK_DIR/Reddit APK/$REDDIT_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The $REDDIT_NEW_FILENAME file is not present in $APK_DIR/Reddit APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "$OUTPUT_DIR/Reddit Patched/Patched_${REDDIT_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Reddit APK/$REDDIT_NEW_FILENAME" --custom-aapt2-binary "$HOME/Auto_CLI_Termux/libaapt2.so"

        if [ $? -eq 0 ]; then
            move_files "$OUTPUT_DIR/Reddit Patched" "$HOME/storage/downloads/Auto_CLI_Termux/Patched_Apps"
            echo -e "${GREEN}The Reddit application has been successfully patched in ./Internal Storage/Download/Auto_CLI_Termux/Patched_Apps."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Reddit application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    7)
        # Twitter (Another shitty app)
        download_and_verify "$DL_LINK_TWITTER" "$TWITTER_NEW_FILENAME" "$APK_DIR/Twitter APK" "$HASH_TWITTER" "md5"

        if [ ! -f "$APK_DIR/Twitter APK/$TWITTER_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The $TWITTER_NEW_FILENAME file is not present in $APK_DIR/Twitter APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "$OUTPUT_DIR/Twitter Patched/Patched_${TWITTER_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Twitter APK/$TWITTER_NEW_FILENAME" --custom-aapt2-binary "$HOME/Auto_CLI_Termux/libaapt2.so"

        if [ $? -eq 0 ]; then
            move_files "$OUTPUT_DIR/Twitter Patched" "$HOME/storage/downloads/Auto_CLI_Termux/Patched_Apps"
            echo -e "${GREEN}The Twitter application has been successfully patched in ./Internal Storage/Download/Auto_CLI_Termux/Patched_Apps."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Twitter application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    [Uu])
        # Universal APK
        check_apk "$DEST_DIR/APK/Universal APK" "$UNIVERSAL_APK"
        rename_apk "$APK_DIR/Universal APK" "$UNIVERSAL_APK"

        if [ ! -f "$APK_DIR/Universal APK/$UNIVERSAL_APK" ]; then
            echo -e "${RED}Error: The $UNIVERSAL_APK file is not present in $APK_DIR/Universal APK."
            echo -e "You probably did something wrong, I don't support this function.${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "$OUTPUT_DIR/Universal Patched/Patched_${UNIVERSAL_APK}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Universal APK/$UNIVERSAL_APK" --custom-aapt2-binary "$HOME/Auto_CLI_Termux/libaapt2.so"

        if [ $? -eq 0 ]; then
            move_files "$OUTPUT_DIR/Universal Patched" "$HOME/storage/downloads/Auto_CLI_Termux/Patched_Apps"
            echo -e "${GREEN}The (Universal) application has been successfully patched in ./Internal Storage/Download/Auto_CLI_Termux/Patched_Apps."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the (Universal) application."
            echo -e "You probably did something wrong, I don't support this function.${NC}"
            exit 1
        fi
        ;;
    [Cc])
        # Clean Files
        clean_destination_dir "$DEST_DIR"
        echo -e "${GREEN}Script finished.${NC}"
        exit 0
        ;;
    [Ww])
        # Wipe
        complete_wipe "$DEST_DIR"
        echo -e "${GREEN}Script finished.${NC}"
        exit 0
        ;;
    [Ee])
        # Exit
        echo -e "${GREEN}Script finished.${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option.${NC}"
        exit 1
        ;;
esac
