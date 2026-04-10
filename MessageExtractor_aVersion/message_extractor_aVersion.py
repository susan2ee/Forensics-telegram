# Telegram message extractor for memory dump analysis.
# Scans raw dump data and exports parsed Telegram messages as JSON.

...

# Parse TL-encoded bytes safely for JSON and forensic output.
def read_tl_bytes(data, offset):
    ...

...

# Recursively decode Telegram TL objects using the schema definition.
def parse_tl_object(data, offset, type_name=None):
    ...

...

# Scan the memory dump for Telegram message structures and collect parsed results.
def extract_from_dump(path):
    ...
