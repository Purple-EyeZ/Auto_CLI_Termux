# Auto_CLI_Termux

### 🚀 Get started

To use the **Auto CLI for Termux**:

1) Open [Termux](https://termux.dev/en/)
2) Execute this command:

    ```
    bash <(curl -s https://raw.githubusercontent.com/Purple-EyeZ/Auto_CLI_Termux/main/Manual/Auto_CLI_Termux_MANUAL.sh)
    ```
    
    >ℹ️ *Note: you may need to install “curl” first, using the following command:*
    `pkg update && pkg install -y curl`

3) Wait until everything's installed and follow the on-screen instructions, that's all.

---
### 🛠️ Usage

Once launched, the script will download and install all the prerequisites for using CLI, the CLI files and required folders will be created in “/Internal Storage/Download/Auto_CLI_Termux”.

Once all this is done, the script asks you what action you want to perform:
- (1-7): Select the app you want to patch, everything is automated
- Once patched, the destination path appears on the screen. Send the patched apk to your phone and install it.

---
### 👨‍💻 Direct use of CLI

You can also just use this script to install the CLI and its prerequisites quickly and use the CLI manually:

- Run the script and use the “E” choice to close it.
- Simply use the following command in your terminal to move to the right place: `cd /storage/emulated/0/Download/Auto_CLI_Termux`
- Learn how to use the CLI with its [documentation](https://github.com/ReVanced/revanced-cli/tree/main/docs)

---

### Note
There's no “Custom” mode at the moment, and no way to manage patch options or keystores. I may add more features later (or not)
