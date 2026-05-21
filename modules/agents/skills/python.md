---
name: python
description: Use when writing or running Python scripts. Provides guidance on using uv and inline dependency declaration.
user-invocable: false
---

# Python Scripts

Always use `uv` to run Python scripts. Never use `python` or `pip` directly.

Declare dependencies inline using PEP 723 script metadata:

```python
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "requests",
#     "rich",
# ]
# ///

import requests
from rich import print

print(requests.get("https://example.com").status_code)
```

Run with:

```
uv run script.py
```

`uv` will automatically resolve and cache the inline dependencies.
