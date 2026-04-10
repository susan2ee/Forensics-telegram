# Telegram Memory Filtering Tool

A Volatility3-based tool to extract Telegram-related memory artifacts from a memory dump.

## Requirements
- Python 3.8+
- Volatility3 (https://github.com/volatilityfoundation/volatility3)
> This tool assumes that Volatility3 has already been properly installed and cloned.  

---

## Step-by-Step Instructions 

### Step 1: Download Required Files  
Download the following files and place them in the appropriate directories:

1. `telegram_filter.py`
2. `telegram_memory_extractor.py`  
→ Place both in the `volatility3` root folder.  
3. `check_telegram.py`  
→ Place this in the plugins directory:  

---

### Step 2: Navigate to Volatility3 Directory  
---

### Step 3: Prepare the Memory Dump 
Ensure that your memory image (e.g., `0602_a_final.raw`) is accessible.  

### Step 4: Run the Tool  
Use the following command to run the extraction script:

```bash
python telegram_memory_extractor.py "memory dump file"
```
This will execute the plugin and extract Telegram-related memory contents.  
---

## Notes

- Ensure your memory dump is from a Windows system.  
- Plugin `check_telegram.py` must be placed in the correct plugin directory (`plugins/windows`).  
---

## File Structure 

```text
volatility3/
├── telegram_filter.py
├── telegram_memory_extractor.py
└── plugins/
    └── windows/
        └── check_telegram.py
```
