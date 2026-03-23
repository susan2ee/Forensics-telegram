# Telegram Memory Forensics CLI Tool

Extract and parse Telegram Web messages from Windows memory dumps using Volatility 3.

---

## Setup

Place this tool inside your `volatility3/` directory:

```
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

## Requirements

- Python 3.9+
- Volatility 3
- Windows memory dump (e.g. `memory.raw`, `memory.dump`)

---

## Usage

```bash
python run_telegram_extractor_tool.py <your_memory_dump.raw>
```

---

## Output

- Filtered dumps: `telegram_ultimate_output/filtered_*.dmp`
- Parsed Telegram messages printed to console
