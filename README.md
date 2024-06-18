# Auto_CLI_Termux

### 🚀 Get started

To use the **Auto CLI for Termux**:

1) Open [Termux](https://termux.dev/en/) (Download directly from GitHub [here](https://github.com/termux/termux-app/releases/download/v0.118.0/termux-app_v0.118.0+github-debug_arm64-v8a.apk) [ARMv8 only])
2) Execute this command:

    ```
    bash <(curl -s https://raw.githubusercontent.com/Purple-EyeZ/Auto_CLI_Termux/main/Auto_CLI_Termux.sh)
    ```
    
    >ℹ️ *Note: you may need to install “curl” first, using the following command:*
    `pkg update && pkg install -y curl`

3) Wait until everything's installed and follow the on-screen instructions, that's all.
---
### 📸 Screenshots
<details>
  <summary>How it looks</summary>

![Screenshot](https://github.com/Purple-EyeZ/Auto_CLI_Termux/blob/main/Images/Screenshot_20240618_031441_Termux.jpg)
![Patch](https://github.com/Purple-EyeZ/Auto_CLI_Termux/blob/main/Images/Screenshot_20240618_030839_Termux.jpg)
</details>

---
### 🛠️ Usage

Once launched, the script will download and install all the prerequisites for using CLI, the CLI files and required folders will be created in “/Internal Storage/Download/Auto_CLI_Termux”.

Once all this is done, the script asks you what action you want to perform:
- (1-7): Select the app you want to patch, everything is automated
- Once patched, the destination path appears on the screen. Open the patched apk in your file explorer and install it.
>ℹ️ *Note: If you already have another version of the patched application, you'll need to uninstall it before installing the new one.*

---
### 👨‍💻 Direct use of CLI

You can also just use this script to install the CLI and its prerequisites quickly and use the CLI manually:

- Run the script and use the “E” choice to close it.
- Simply use the following command in your terminal to move to the right place: `cd /storage/emulated/0/Download/Auto_CLI_Termux`
- Learn how to use the CLI with its [documentation](https://github.com/ReVanced/revanced-cli/tree/main/docs)
>⚠️ Don't forget to add `--custom-aapt2-binary "$HOME/Auto_CLI_Termux/libaapt2.so"` to your patch command (otherwise the patch process will just fail).

---
### ❓ FAQ
<details>
  <summary>Click here to expand</summary>

1. **Termux asks me if I want to use the maintainer's configuration file or if I want to keep the file I already have. What should I do?**
![pkg](https://github.com/Purple-EyeZ/Auto_CLI_Termux/blob/main/Images/Packages_update.png)

The script executes these commands before installing the necessary packages -> `pkg update && pkg upgrade`, which is why Termux prompts you to make this choice

**You can accept anything it asks you to, just press "Y" and press "ENTER" each time.**  

---
2. **Something fails before the script asks "What do you want to do?"** 

Re-running the script should solve this kind of problem. 

Also, make sure you've granted Termux access to storage. 
Termux should prompt you to do this automatically, but if it doesn't, do it manually (Google how to if you don't know).

</details>

---

### Note
There's no “Custom” mode at the moment, and no way to manage patch options or keystores. I may add more features later (or not)
