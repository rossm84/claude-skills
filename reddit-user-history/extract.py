#!/usr/bin/env python3
"""Extract a Reddit user's full post and comment history via Arctic Shift API."""

import json
import csv
import sys
import time
import urllib.request
from datetime import datetime, timezone

API_BASE = "https://arctic-shift.photon-reddit.com/api"
LIMIT = 100


def fetch_all(endpoint, author):
    items = []
    before = None
    while True:
        url = f"{API_BASE}/{endpoint}/search?author={author}&limit={LIMIT}&sort=desc"
        if before:
            url += f"&before={before}"
        req = urllib.request.Request(url, headers={"User-Agent": "RedditHistoryExtractor/1.0"})
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read())
        batch = data.get("data", [])
        if not batch:
            break
        items.extend(batch)
        before = batch[-1].get("created_utc")
        if len(batch) < LIMIT:
            break
        time.sleep(0.3)
    return items


def main():
    if len(sys.argv) < 2:
        print("Usage: extract.py USERNAME [output.csv]")
        sys.exit(1)

    username = sys.argv[1]
    output = sys.argv[2] if len(sys.argv) > 2 else f"/tmp/reddit_{username}_history.csv"

    print(f"Fetching posts for u/{username}...")
    posts = fetch_all("posts", username)
    print(f"  {len(posts)} posts")

    print(f"Fetching comments for u/{username}...")
    comments = fetch_all("comments", username)
    print(f"  {len(comments)} comments")

    rows = []
    for p in posts:
        dt = datetime.fromtimestamp(p["created_utc"], tz=timezone.utc).strftime("%Y-%m-%d %H:%M")
        title = p.get("title", "")
        selftext = p.get("selftext", "")
        content = title
        if selftext and selftext != "[removed]":
            content = f"{title} | {selftext}"
        link = f"https://www.reddit.com{p.get('permalink', '')}"
        rows.append([dt, "Post", p.get("subreddit", ""), content, link])

    for c in comments:
        dt = datetime.fromtimestamp(c["created_utc"], tz=timezone.utc).strftime("%Y-%m-%d %H:%M")
        body = c.get("body", "").replace("\n", " | ")
        link = f"https://www.reddit.com{c.get('permalink', '')}"
        rows.append([dt, "Comment", c.get("subreddit", ""), body, link])

    rows.sort(key=lambda r: r[0], reverse=True)

    with open(output, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Date", "Type", "Subreddit", "Content", "Link"])
        writer.writerows(rows)

    print(f"\nTotal: {len(rows)} items written to {output}")
    print(f"  Posts: {len(posts)}")
    print(f"  Comments: {len(comments)}")


if __name__ == "__main__":
    main()
