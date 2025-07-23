## 📦 **Goal**

Mimic a native feel:

* User installs Cursor IDE once via a script.
* After that, whenever the user runs:

```bash
sudo apt update && sudo apt upgrade
```

Cursor IDE updater runs **automatically**.

* User doesn't have to manually check or run update scripts.
* Even though Cursor isn’t installed from an APT repo.

---

## 🛠 **Components**

We’ll create:

| # | What                                                     | Purpose                                                                                     |
| - | -------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| 1 | `install-cursor.sh`                                      | One-time installer script: installs Cursor IDE, updater script, desktop entry, and APT hook |
| 2 | `/usr/local/bin/update-cursor`                           | Updater script: checks for new Cursor IDE version & updates                                 |
| 3 | `/etc/apt/apt.conf.d/99-cursor-update`                   | APT hook: automatically runs updater script after each `apt upgrade`                        |
| 4 | Desktop entry (`/usr/share/applications/cursor.desktop`) | So Cursor shows in app menu                                                                 |

---

## 🧰 **Where things go**

| File                     | Location                                 | Why                                  |
| ------------------------ | ---------------------------------------- | ------------------------------------ |
| Cursor binary / AppImage | `/opt/cursor-ai/cursor`                  | Standard for third-party apps        |
| Updater script           | `/usr/local/bin/update-cursor`           | In `$PATH` so can run as command     |
| Desktop file             | `/usr/share/applications/cursor.desktop` | Integrates with launcher             |
| APT hook                 | `/etc/apt/apt.conf.d/99-cursor-update`   | Triggers updater after `apt upgrade` |

---

## 🧩 **Detailed flow**

### 🟩 Step 1: Installation

User runs:

```bash
chmod +x install-cursor.sh
sudo ./install-cursor.sh
```

What this script does:

* Checks if dependencies (wget, curl, jq) exist; install if missing.
* Creates `/opt/cursor-ai/` directory.
* Downloads latest Cursor AppImage / binary to `/opt/cursor-ai/cursor`.
* Makes it executable.
* Adds desktop entry so it appears in app menu.
* Installs updater script (`/usr/local/bin/update-cursor`).
* Adds APT hook (`/etc/apt/apt.conf.d/99-cursor-update`).

---

### 🟩 Step 2: Normal usage

User normally runs:

```bash
sudo apt update && sudo apt upgrade
```

APT hook ensures:

* After packages are upgraded, the system runs:

```bash
/usr/local/bin/update-cursor
```

---

### 🟩 Step 3: Update check

`update-cursor` script:

* Checks upstream (e.g., latest release from GitHub).
* Compares with current local version (can be stored in a file like `/opt/cursor-ai/version.txt`).
* If new version:

  * Downloads new AppImage / binary.
  * Replaces old one.
  * Updates `version.txt`.

User sees in terminal:

```
[Cursor Updater] Checking for new version...
[Cursor Updater] New version found: v0.2.3 → downloading...
[Cursor Updater] Update complete!
```

---

## ✅ **Key points**

* **Simple for user**: installs once, updates automatically.
* **Doesn't** appear in `apt list --upgradable` (needs real packaging for that).
* Updates happen every time system updates → close enough to "native" feel.
* Completely controlled by your scripts.

---

## 📚 **Extra details / notes**

| Item          | Detail                                                                       |
| ------------- | ---------------------------------------------------------------------------- |
| Version check | Store installed version in `/opt/cursor-ai/version.txt`; compare to upstream |
| Updater       | Can use `curl` or `wget`; maybe `jq` to parse GitHub API                     |
| Safety        | Backup old binary before replacing; rollback if download fails               |
| Permissions   | Scripts run as root, so they can write to `/opt`                             |
| Desktop entry | Points to `/opt/cursor-ai/cursor`                                            |
| Uninstall     | Provide script to remove everything cleanly                                  |

---

## 🧠 **User experience**

| Moment        | What user does                        | What happens                         |
| ------------- | ------------------------------------- | ------------------------------------ |
| First install | `sudo ./install-cursor.sh`            | Installs Cursor, sets up everything  |
| Daily updates | `sudo apt update && sudo apt upgrade` | System updates + Cursor auto-updates |
| Launch app    | Search “Cursor” in app menu           | Opens latest installed Cursor        |

---
