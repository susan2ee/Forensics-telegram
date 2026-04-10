# Telegram message extractor for memory dump analysis.
# This script scans raw dump data, reconstructs TL objects,
# and exports parsed Telegram messages as JSON.

# Read TL-encoded bytes and return them as a hex string.
# This keeps binary data safe for JSON output and forensic analysis.
def read_tl_bytes(data, offset):

  
# Read a TL string while handling Telegram's length and 4-byte alignment rules.
def read_tl_string(data, offset):

# Read a TL Vector.
# Primitive elements are decoded directly, and complex elements are parsed recursively.
def read_tl_vector(data, offset, elem_type=None):

# Build a stable key for deduplication by removing volatile fields
# such as offsets or temporary metadata.
def _canonicalize_for_dedupe(obj):

# Read TL flags only when the schema uses them,
# so optional fields can be parsed without losing alignment.
def _read_flags_if_needed(fields, cursor, data, group="flags"):

# Recursively decode a TL object based on the schema.
# If no type is given, the constructor ID is read directly from the dump.
def parse_tl_object(data, offset, type_name=None):

# Scan the memory dump for Telegram message constructors,
# parse matching objects, remove duplicates, and collect the results.
def extract_from_dump(path):

# Skip duplicated messages that may appear multiple times in memory.
# Convert Unix timestamps into a readable datetime format for easier inspection.
