#!/bin/bash

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

# Sources
source_variables() {
    local variables_url="https://raw.githubusercontent.com/Purple-EyeZ/Auto_CLI_Linux/main/variables.sh"
    local temp_file="$DEST_DIR/tmp/variables.sh"

    wget -q -O "$temp_file" "$variables_url"
    if [ $? -eq 0 ]; then
        source "$temp_file"
        echo -e "${GREEN}Variables have been loaded successfully.${NC}"
    else
        echo -e "${RED}Error while downloading variables, please screenshot the error"
        echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
        exit 1
    fi
}

# Check if OpenJDK 17 is installed
check_openjdk() {
    if java -version 2>&1 | grep -q "17"; then
        echo "OpenJDK 17 is already installed."
    else
        echo -e "${BLUE}OpenJDK 17 is not installed. Installation in progress...${NC}"
        pkg update
        pkg install -y openjdk-17-jdk
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}OpenJDK 17 successfully installed.${NC}"
        else
            echo -e "${RED}Error during OpenJDK 17 installation, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
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
        pkg update
        pkg install -y wget
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}wget successfully installed.${NC}"
        else
            echo -e "${RED}Error during wget installation, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
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
        wget -q --show-progress -O "$dest_dir/$dest_filename" "$url"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Successful download : $dest_filename${NC}"
        else
            echo -e "${RED}Error while downloading : $dest_filename, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
    fi
}

# APK Download
download_apk() {
    local file_url="$1"
    local file_name="$2"
    local download_dir="$3"

    mkdir -p "$download_dir"

    if [ -f "$download_dir/$file_name" ]; then
        echo -e "${GREEN}$file_name already exists in $download_dir. No need to download it again.${NC}"
        return 0
    fi

    echo -e "${BLUE}Download file from${MAGENTA} $file_url ${BLUE}to $download_dir/$file_name...${NC}"

    wget -q --show-progress -O "$download_dir/$file_name" "$file_url"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}$file_name has been successfully downloaded to $download_dir${NC}"
    else
        echo -e "${RED}Error downloading file from $file_url${NC}"
        if [ -f "$download_dir/$(basename "$file_url")" ]; then
            echo -e "${RED}Partial download detected. Removing incomplete file.${NC}"
            rm "$download_dir/$(basename "$file_url")"
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

# Destination directory
DEST_DIR="/storage/emulated/0/Download/Auto_CLI_Termux"

if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
fi

APK_DIR="$DEST_DIR/APK"
if [ ! -d "$APK_DIR" ]; then
    mkdir -p "$APK_DIR"
fi

# Create folders if they don't exist
for dir in "Patched_Apps" "APK/Universal APK" "tmp"; do
    if [ ! -d "$DEST_DIR/$dir" ]; then
        mkdir -p "$DEST_DIR/$dir"
    fi
done

# Check and install dependencies if necessary
check_openjdk
check_wget
source_variables

# Download files for CLI
download_direct "$DL_LINK_CLI" "$REVANCED_CLI" "$DEST_DIR"
download_direct "$DL_LINK_PATCHES" "$REVANCED_PATCHES" "$DEST_DIR"
download_direct "$DL_LINK_INTEGRATIONS" "$REVANCED_INTEGRATIONS" "$DEST_DIR"

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
        download_apk "$DL_LINK_YOUTUBE" "$YOUTUBE_NEW_FILENAME" "$APK_DIR/Youtube APK"

        if [ ! -f "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The file $YOUTUBE_NEW_FILENAME is not present in $APK_DIR/Youtube APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        # Patch the app
        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Youtube Patched/Stock_Patched_${YOUTUBE_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}The YouTube application has been successfully patched in $DEST_DIR/Patched_Apps/Youtube Patched."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Youtube application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    2)
        # Youtube Custom branding
        download_apk "$DL_LINK_YOUTUBE" "$YOUTUBE_NEW_FILENAME" "$APK_DIR/Youtube APK"

        if [ ! -f "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The file $YOUTUBE_NEW_FILENAME is not present in $APK_DIR/Youtube APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -i 'Custom branding' -o "./Patched_Apps/Youtube Patched/Logo_Patched_${YOUTUBE_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube APK/$YOUTUBE_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}The YouTube application with ReVanced Logo has been successfully patched in $DEST_DIR/Patched_Apps/Youtube Patched."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Youtube application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    3)
        # Youtube_Music_ARMv8
        download_apk "$DL_LINK_YOUTUBE_MUSIC" "$YOUTUBE_MUSIC_NEW_FILENAME" "$APK_DIR/Youtube Music APK (ARMv8a)"

        if [ ! -f "$APK_DIR/Youtube Music APK (ARMv8a)/$YOUTUBE_MUSIC_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The file $YOUTUBE_MUSIC_NEW_FILENAME is not present in $APK_DIR/Youtube Music APK (ARMv8a). Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Youtube Music Patched/Patched_${YOUTUBE_MUSIC_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube Music APK (ARMv8a)/$YOUTUBE_MUSIC_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}The Youtube Music application has been successfully patched in $DEST_DIR/Patched_Apps/Youtube Music Patched."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Youtube Music application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    4)
        # Youtube_Music_ARMv7
        download_apk "$DL_LINK_YOUTUBE_MUSIC_V7" "$YOUTUBE_MUSIC_NEW_FILENAME_V7" "$APK_DIR/Youtube Music APK (ARMv7a)"

        if [ ! -f "$APK_DIR/Youtube Music APK (ARMv7a)/$YOUTUBE_MUSIC_NEW_FILENAME_V7" ]; then
            echo -e "${RED}Error: The file $YOUTUBE_MUSIC_NEW_FILENAME_V7 is not present in $APK_DIR/Youtube Music APK (ARMv7a). Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Youtube Music Patched/Patched_${YOUTUBE_MUSIC_NEW_FILENAME_V7}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Youtube Music APK (ARMv7a)/$YOUTUBE_MUSIC_NEW_FILENAME_V7"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}The Youtube Music application has been successfully patched in $DEST_DIR/Patched_Apps/Youtube Music Patched."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Youtube Music application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    5)
        # TikTok (Shitty App)
        download_apk "$DL_LINK_TIKTOK" "$TIKTOK_NEW_FILENAME" "$APK_DIR/TikTok APK"

        if [ ! -f "$APK_DIR/TikTok APK/$TIKTOK_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The file $TIKTOK_NEW_FILENAME is not present in $APK_DIR/TikTok APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -i 'SIM spoof' -o "./Patched_Apps/TikTok Patched/Patched_${TIKTOK_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/TikTok APK/$TIKTOK_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}The TikTok application has been successfully patched in $DEST_DIR/Patched_Apps/TikTok Patched."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the TikTok application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    6)
        # Reddit
        download_apk "$DL_LINK_REDDIT" "$REDDIT_NEW_FILENAME" "$APK_DIR/Reddit APK"

        if [ ! -f "$APK_DIR/Reddit APK/$REDDIT_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The $REDDIT_NEW_FILENAME file is not present in $APK_DIR/Reddit APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Reddit Patched/Patched_${REDDIT_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Reddit APK/$REDDIT_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}The Reddit application has been successfully patched in $DEST_DIR/Patched_Apps/Reddit Patched."
            echo -e "  Open the patched apk in your file explorer and install it.${NC}"
        else
            echo -e "${RED}Error while patching the Reddit application, please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi
        ;;
    7)
        # Twitter (Another shitty app)
        download_apk "$DL_LINK_TWITTER" "$TWITTER_NEW_FILENAME" "$APK_DIR/Twitter APK"

        if [ ! -f "$APK_DIR/Twitter APK/$TWITTER_NEW_FILENAME" ]; then
            echo -e "${RED}Error: The $TWITTER_NEW_FILENAME file is not present in $APK_DIR/Twitter APK. Please screenshot the error"
            echo -e "and ping me (@Arthur777) in the #Support channel of the ReVanced Discord or open an issue on GitHub${NC}"
            exit 1
        fi

        cd "$DEST_DIR"
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Twitter Patched/Patched_${TWITTER_NEW_FILENAME}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Twitter APK/$TWITTER_NEW_FILENAME"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}The Twitter application has been successfully patched in $DEST_DIR/Patched_Apps/Twitter Patched."
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
        java -jar "$REVANCED_CLI" patch -b "$REVANCED_PATCHES" -p -o "./Patched_Apps/Universal Patched/Patched_${UNIVERSAL_APK}" -m "$REVANCED_INTEGRATIONS" "$APK_DIR/Universal APK/$UNIVERSAL_APK"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}The (Universal) application has been successfully patched in $DEST_DIR/Patched_Apps/Universal Patched."
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
