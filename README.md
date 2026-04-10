# Telegram Memory Forensics CLI Tool

A CLI tool for extracting and parsing Telegram Web artifacts from Windows memory dumps using Volatility 3.

---

## 📌 Notice

This repository contains a simplified version of my research project.

Due to an ongoing paper submission, some parts of the full implementation are not included.

The code provided here focuses on:
- Automating experimental environments using Selenium
- Parsing Telegram Web memory artifacts across different versions
- Filtering Telegram-related processes using a Volatility plugin
- Running the full pipeline with a PowerShell script

---

## 📌 안내

현재 논문 심사 중인 연구 프로젝트이기 때문에, 일부 내용을 단순화하여 공개했습니다.
주요 내용은 다음과 같습니다:
- Selenium 기반 실험 환경 자동화 코드
- Telegram Web 버전별 메모리 아티팩트 파싱 코드
- Volatility 기반 Telegram Web 프로세스 필터링 플러그인
- 전체 과정을 한 번에 실행하는 PowerShell 스크립트

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

