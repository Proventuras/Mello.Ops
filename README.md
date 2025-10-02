# ⌨️ Mello.Ops

Welcome to **Mello.Ops** - the all-in-one, supercharged AutoHotkey toolkit for Windows power users, keyboard tinkerers, and productivity wizards!  

Unleash a world of hotkeys, text replacements, automations, and clever tricks, all wrapped up in a friendly, customizable package.

---

## 🚀 Features

- ⚡️ One-click setup for Windows
- 🪄 Powerful global hotkeys and automations (AutoHotkey v2)
- 🎛️ Easy tray menu for quick access
- 🔊 Fun sound effects and notifications
- 🧩 Modular library - add your own scripts!

Check out the [full list of hotkeys and](docs/README.md#hotkeys) and [features](docs/README.md#features) to see what Mello.Ops can do for you!

- 📜 [Documentation](docs/README.md) for all the nitty-gritty details

---

## 🛠️ Quick Install (The Magic Way)

**No downloads, no fuss!**  
Just open PowerShell and run this single command. It doesn't even have to open it as an Administrative prompt. All will be going into your profile's local Appdata/Mello.Ops directory:

```powershell
iex "& { $(irm 'https://raw.githubusercontent.com/Proventuras/Mello.Ops/refs/heads/main/Start-Mello.Ops.ps1') }"
```

This will:

- Download the latest Mello.Ops release from GitHub  
- Set up AutoHotkey (portable, no admin install needed)
- Create a Start Menu shortcut
- Launch Mello.Ops for you!

> [!NOTE]  
> The script will automatically install it into your profile's %LOCALAPPDATA%\Mello.Ops directory.

---

## 🧑‍💻 Manual Install

Prefer the classic way? No problem!

1. **Download the repo:**

   ```powershell
   Invoke-WebRequest 'https://github.com/Proventuras/Mello.Ops/archive/refs/heads/main.zip' -OutFile .\Mello.Ops.zip
   Expand-Archive .\Mello.Ops.zip -DestinationFolder $env:APPDATA -Force
   Remove-Item .\Mello.Ops.zip
   cd $env:APPDATA\Mello.Ops-main
   ```

2. **Run the script:**

   Double-click [Mello.Ops.ahk](http://_vscodecontentref_/0) or run it with AutoHotkey v2.

---

## 🏁 Run at Startup

Want Mello.Ops to launch every time you log in?  
Just right-click the tray icon and select **"Run at Startup"**. Easy!

---

## 🗂️ Project Structure

```plaintext
📂 Mello.Ops/
 ├─ 📂 docs/                      # Documentation (in progress)
 ├─ 📂 lib/                       # Modular AHK libraries
 ├─ 📂 media/                     # Icons & sounds
 ├─ 📄 Mello.Ops.ahk              # Main script
 ├─ 📄 Start-Mello.Ops.ps1        # PowerShell installer and launcher
 └─ 📄 README.md
---

## 🤝 Contributing

Pull requests, ideas, and fun new hotkeys are always welcome!  
Open an [issue](https://github.com/Proventuras/Mello.Ops/issues) or submit a PR.

---

## 💬 Questions? Suggestions?

Ask away in the [issues](https://github.com/Proventuras/Mello.Ops/issues) or start a discussion.  
We love making Windows more fun and productive!

---

**Mello.Ops - Chill, flow, repeat.**

