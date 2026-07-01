---
name: article-extractor
description: Use when extracting clean article text, metadata, or structured content from web pages. Better than WebFetch for long-form content. Uses trafilatura (preferred) or BeautifulSoup fallback.
---

# Article Extractor

Extract clean text and metadata from web pages. More reliable than WebFetch for long-form articles, blog posts, and documentation.

## Method 1: trafilatura (preferred, install if missing)

```bash
pip3 install trafilatura
```

```python
import trafilatura

url = "https://example.com/article"
downloaded = trafilatura.fetch_url(url)
text = trafilatura.extract(downloaded, include_comments=False, include_tables=True, output_format='txt')
print(text)

# With metadata
result = trafilatura.extract(downloaded, include_comments=False, include_tables=True, output_format='json', with_metadata=True)
import json
data = json.loads(result)
print(f"Title: {data.get('title')}")
print(f"Author: {data.get('author')}")
print(f"Date: {data.get('date')}")
print(f"Text: {data.get('text')[:500]}")
```

### Batch extraction
```python
import trafilatura
urls = ["https://example.com/a", "https://example.com/b"]
for url in urls:
    downloaded = trafilatura.fetch_url(url)
    text = trafilatura.extract(downloaded)
    if text:
        print(f"--- {url} ---")
        print(text[:200])
```

## Method 2: BeautifulSoup fallback (already installed)

```python
import requests
from bs4 import BeautifulSoup

r = requests.get(url, headers={"User-Agent": "Mozilla/5.0"}, timeout=10)
soup = BeautifulSoup(r.text, 'lxml')

# Remove nav, footer, scripts
for tag in soup(['script', 'style', 'nav', 'footer', 'header', 'aside']):
    tag.decompose()

# Get article body (try common selectors)
article = soup.find('article') or soup.find('main') or soup.find(class_='content') or soup.body
text = article.get_text(separator='\n', strip=True)
title = soup.find('title').text if soup.find('title') else ''
```

## When to use this vs WebFetch
- **Article extractor**: long articles, documentation pages, blog posts where you need full clean text
- **WebFetch**: quick info extraction, pages you need AI to summarize, pages behind auth that have MCP tools
