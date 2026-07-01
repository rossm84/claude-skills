---
name: lean-ctx
description: Use when conversations are getting long and you need to manage context efficiently. Techniques for compressing context, caching intermediate results, and keeping the working set small during complex multi-file tasks.
---

# Lean Context Management

Techniques for staying effective in long conversations or complex multi-file tasks without exhausting context.

## Principles

1. **Don't re-read what you already know.** After reading a file once, work from your understanding. Only re-read if you need exact line numbers or content has changed.
2. **Summarise before you forget.** When a subagent or long exploration returns results, extract the key facts into a short summary before continuing.
3. **Use disk as external memory.** Write intermediate results to `/tmp/` files rather than keeping them in conversation context.
4. **Scope your reads.** Use `offset` and `limit` on Read. Use `grep` before Read to find the right section.
5. **Delegate to subagents.** Subagents get their own context window. Use them for exploration that would bloat the main conversation.

## Patterns

### Targeted file reading
```
# Bad: read entire 2000-line file
Read(file_path="/path/to/big-file.py")

# Good: find the function first, then read just that section
grep -n "def my_function" /path/to/big-file.py
Read(file_path="/path/to/big-file.py", offset=142, limit=30)
```

### Intermediate results to disk
```python
# When processing large data, write results to /tmp/ instead of printing
import json
results = heavy_computation()
with open('/tmp/analysis-results.json', 'w') as f:
    json.dump(results, f)
print(f"Wrote {len(results)} results to /tmp/analysis-results.json")
# Then read selectively later
```

### Subagent delegation
Use `Agent` with `subagent_type="Explore"` for codebase searches that might return large results. The subagent's full exploration stays in its own context; only the summary comes back.

### Compression checkpoints
After completing a logical phase of work, summarise what you learned in one paragraph. This becomes the "checkpoint" that survives context compression.

### Batch operations
When editing multiple files, group the changes and make all independent edits in one message (parallel tool calls) rather than one-by-one.

## Anti-patterns

| Anti-pattern | Fix |
|---|---|
| Reading the same file repeatedly | Read once, note the key info |
| Printing entire API responses | Extract the fields you need with jq/python |
| Long grep output in conversation | Pipe to `wc -l` first, then narrow the search |
| Re-deriving facts already established | State the fact, don't re-prove it |
| Narrating every step | Act, then report the result |

## When context is truly running low
- Prioritise completing the current task over exploring new ones
- Write remaining work items to a file (`/tmp/remaining-tasks.md`) so the next conversation can pick up
- Commit any in-progress changes to a branch
