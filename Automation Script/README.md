# Telegram Web Automation + VM Memory Dump (VirtualBox)

This repository contains Python scripts that automate **Telegram Web** (either `/a/` or `/k/`) via **Selenium Remote WebDriver** and can trigger **VirtualBox VM memory dumps** (`dumpvmcore`) at specific points in a scenario. It is intended for controlled/authorized testing and forensic-style data collection.

## What’s in here

- `main.py` — entrypoint; selects Telegram Web version and runs the scenario list.
- `automation_script_Chrome_A.py` — Telegram Web **A** automation + dump helpers.
- `automation_script_Chrome_K.py` — Telegram Web **K** automation + dump helpers.

## Requirements / prerequisites

- Python 3.11+
- Python package: `selenium`
  - Install: `pip install selenium`
- A running **Remote WebDriver** endpoint reachable from where you run `main.py`:
  - Chrome: `http://127.0.0.1:9515` (default in the scripts)
  - Firefox: `http://127.0.0.1:4444` (default in the scripts)
- If you use `dump_memory` actions:
  - Oracle VirtualBox installed
  - `VBoxManage` accessible at the path configured in the script (see `VBOXMANAGE_EXE`)
  - A VM name matching `VBOX_VM_NAME`

> Note: The scripts currently contain Windows-style default paths (e.g., `C:\...`). If you are running from WSL/Linux, update `VBOXMANAGE_EXE`, `DUMP_OUTPUT_DIR`, and profile paths accordingly.

## Usage

Run from the repository folder:

```bash
python main.py [--browser chrome|firefox] [--tg-version a|k] [--mode normal|private]
```

### Arguments

`main.py` supports:

- `--browser {chrome,firefox}`: Browser backend to use (default: `chrome`)
- `--tg-version {a,k}`: Telegram Web version to drive (default: `a`)
- `--mode {normal,private}`: Browser mode (default: `normal`)
  - `normal`: uses a persistent profile directory (Chrome) / default profile handling (Firefox)
  - `private`: uses incognito/private mode

Examples:

```bash
# Telegram Web A on Chrome with the configured profile
python main.py --browser chrome --tg-version a --mode normal

# Telegram Web K on Firefox in private mode
python main.py --browser firefox --tg-version k --mode private
```

## Scenarios (what the script actually does)

Scenarios are defined inline as a Python list named `SCENARIOS` in `main.py`. Each scenario is a `dict` describing:

- which chat context you want (`chat_kind`)
- what operation to perform (`action`)
- how to open the chat (`open_mode` + `title`) for chat actions

### `{run_tag}` templating

All scenario strings are processed so that occurrences of `{run_tag}` are replaced with a run identifier derived from the selected browser + tg version + mode, e.g. `chrome_an`, `firefox_kp`, etc.

### Supported `action` values

The automation scripts currently handle these actions:

- `dump_memory` (system action; does **not** open a chat)
- `send_now`
- `send_after`
- `read_wait`
- `delete_existing`
- `send_then_delete_after`
- `schedule_tomorrow`
- `schedule_after`
- `schedule_then_delete`
- `edit_existing`
- `leave_chat`

### Common fields

- `chat_kind` (optional for `dump_memory`): one of the chat “roles” used by the script logic, e.g.
  - `1on1_Chat`, `Group_Owner`, `Group_Member`, `Channel_Owner`, `Channel_Admin`, `Channel_Member`
  - If omitted, defaults to `SYSTEM`
- `action` (required): one of the supported actions above

### Fields by action

`dump_memory`

- Required: `action: "dump_memory"`
- Optional:
  - `dump_name` (string; supports `{run_tag}`)
  - `output_dir`, `vm_name`, `pause_first`, `resume_after`, `add_timestamp`
  - `sleep_after` (seconds; default: `2`)

Chat actions (everything except `dump_memory`)

- Required to open a chat:
  - `open_mode: "title"`
  - `title: "<chat title>"`
- Then per action:
  - `send_now`: `message`
  - `send_after`: `wait_for`, `message`
  - `read_wait`: `wait_for`
  - `delete_existing`: `target_text` (optional `wait_for`, `delete_for_other_side`)
  - `send_then_delete_after`: `wait_for`, `message` (optional `delete_for_other_side`)
  - `schedule_tomorrow`: `message` (optional `schedule_hour`, `schedule_minute`)
  - `schedule_after`: `wait_for`, `message` (optional `schedule_hour`, `schedule_minute`)
  - `schedule_then_delete`: `message` (optional `schedule_hour`, `schedule_minute`)
  - `edit_existing`: `target_text`, `edited_message` (optional `wait_for`)
  - `leave_chat`: (optional `wait_for`, optional `delete_for_other_side`)

## Configuration knobs (edit in the scripts)

In `automation_script_Chrome_A.py` and `automation_script_Chrome_K.py` you may need to adjust:

- `VBOX_VM_NAME`, `VBOXMANAGE_EXE`, `DUMP_OUTPUT_DIR`
- `CHROME_REMOTE_ENDPOINT`, `FIREFOX_REMOTE_ENDPOINT`
- `PROFILE_DIR`, `PROFILE_NAME`, `FIREFOX_PROFILE_DIR`

## Output

- VM memory dumps are written to `DUMP_OUTPUT_DIR` with a timestamped `.elf` filename by default.
- The script pauses at the end with `Press Enter to quit...` before closing the browser session.

## Troubleshooting

- If Selenium can’t connect: verify the Remote WebDriver endpoint (`CHROME_REMOTE_ENDPOINT` / `FIREFOX_REMOTE_ENDPOINT`) is running and reachable.
- If dumps fail: verify VirtualBox is installed, `VBOXMANAGE_EXE` is correct, and the VM name matches `VBOX_VM_NAME`.
