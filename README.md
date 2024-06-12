# Auto_CLI_Termux

### Get started

To use the **manual** version (You must download and place the .apk files manually in the corresponding folder):

- Open [Termux](https://termux.dev/en/)
- Execute this command:

    ```
    bash <(curl -s https://raw.githubusercontent.com/Purple-EyeZ/Auto_CLI_Termux/main/Manual/Auto_CLI_Termux_MANUAL.sh)
    ```
    
    >ℹ️ *Note: you may need to install “curl” first, using the following command:*
    `pkg update && pkg install -y curl`
---
### Usage

Once launched, the script will download and install all the prerequisites for using CLI, the CLI files and required folders will be created in “/Internal Storage/Download/Auto_CLI_Termux”.

Once all this is done, the script asks you what action you want to perform:

 - (1-5) To patch a specific application, you'll find links to download .apk files with the correct version here:
 1. Patch [YouTube](https://www.apkmirror.com/apk/google-inc/youtube/youtube-19-16-39-release/youtube-19-16-39-android-apk-download/) (Stock Logo)
 2. Patch [YouTube](https://www.apkmirror.com/apk/google-inc/youtube/youtube-19-16-39-release/youtube-19-16-39-android-apk-download/) (Custom Branding)
 3. Patch YouTube Music ([armv8a](https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-7-03-52-release/youtube-music-7-03-52-android-apk-download/)) ([armv7a](https://www.apkmirror.com/apk/google-inc/youtube-music/youtube-music-7-03-52-release/youtube-music-7-03-52-2-android-apk-download/))
 4. Patch [TikTok](https://www.apkmirror.com/apk/tiktok-pte-ltd/tik-tok-including-musical-ly/tik-tok-including-musical-ly-32-5-3-release/tiktok-32-5-3-4-android-apk-download/)
 5. Patch [Reddit](https://www.apkmirror.com/apk/redditinc/reddit/reddit-2024-17-0-release/reddit-2024-17-0-2-android-apk-download/)
 
 >*⚠️ .apk files should be placed in the folder corresponding to the application in "/Download/Auto_CLI_Termux/APK/AppName" ==(PLACE ONLY ONE .APK IN EACH FOLDER)==*

- U) Patch an application that isn't in the list above, with default patches and default options (The app must of course be supported by ReVanced patches, you can see which apps are supported [here](https://revanced.app/patches))
- C) Clean CLI files and .apk folders and close script (You'll keep the /Patched_Apps folder)
- E) Simply close the script

Once the application has been patched, you can find it in the “/Download/Auto_CLI_Termux/Patched_Apps/*Patched_AppName*” folder. (Open the patched .apk and install it)

> ⚠️ (Also, the script assumes that you have put the apk with the correct version in the /APK/*AppName* folders, so your apk will be renamed with this version number, regardless of its actual version.)

---
### Direct use of CLI

You can also just use this script to install the CLI and its prerequisites quickly and use the CLI manually:

- Run the script and use the “E” choice to close it.
- Simply use the following command in your terminal to move to the right place: `cd /storage/emulated/0/Download/Auto_CLI_Termux`
- Learn how to use the CLI with its [documentation](https://github.com/ReVanced/revanced-cli/tree/main/docs)

---

### Note
There's no “Custom” mode at the moment, and no way to manage patch options or keystores. I may add more features later (or not)
