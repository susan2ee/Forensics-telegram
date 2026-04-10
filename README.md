# Telegram Memory Forensics CLI Tool

A CLI tool for extracting and parsing Telegram Web artifacts from Windows memory dumps using Volatility 3.

(This repository demonstrates a simplified version of my research project.
- The full implementation includes advanced detection logic and dataset-specific tuning.
- Due to ongoing research submission, only a minimal reproducible version is shared here.
- The project focuses on automated analysis of memory artifacts and detection of suspicious patterns.)
- 
---

## Requirements

- Python 3.9+
- Volatility 3
- Windows memory dump file (.raw, .dmp, .dump, etc.)

---


## 1. Clone Volatility 3

Clone the official Volatility 3 repository:

```bash
git clone https://github.com/volatilityfoundation/volatility3.git
cd volatility3
```

---
## 2. Place MemoryFilter Into the Volatility 3 Directory

Copy the files into the correct locations inside the Volatility 3 project.

### Target structure

```text
MessageExtractor_aVersion/
├── message_extractor_aVersion.py
└── tl_schema_parser_aVersion.py
MessageExtractor_kVersion/
├── message_extractor_kVersion.py
└── tl_schema_parser_kVersion.py
volatility3/
├── run_telegram_extractor_tool.py
├── telegram_filter.py
├── telegram_memory_extractor.py
└── volatility3/
    └── plugins/
        └── windows/
            └── check_telegram.py
```

---

## 3. Copy Commands

Run these commands from the root of this repository:

```bash
cp run_telegram_extractor_tool.py ../volatility3/
cp MemoryFilter/telegram_filter.py ../volatility3/
cp MemoryFilter/telegram_memory_extractor.py ../volatility3/
cp MemoryFilter/check_telegram.py ../volatility3/volatility3/plugins/windows/
```

---

## 4. Usage

Run the tool from inside the cloned `volatility3/` directory:

```bash
python run_telegram_extractor_tool.py <memory_dump.raw>
```

---

## Output

The tool produces:

- Filtered Telegram-related dump:
  - `telegram_ultimate_output/*.dmp`
- Parsed Telegram messages:
    - `telegram_ultimate_output/*.json`

