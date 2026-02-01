# Jazarok Support (Zoho Desk Help Center)

Repo for managing Help Center articles in `pomoc.jazarok.pl` via Zoho Desk API.

## Requirements
- Zoho Desk org ID: `20111859397`
- OAuth refresh token (Zoho Desk scope)
- Client ID + client secret

## GitHub Secrets
Add these secrets in the repo settings:
- `ZOHO_CLIENT_ID`
- `ZOHO_CLIENT_SECRET`
- `ZOHO_REFRESH_TOKEN`

The workflow sets `ZOHO_ORG_ID` to `20111859397`.

## Article format
Articles live in `articles/` and use simple frontmatter:

```text
---
title: Sample Article
status: Draft
department_id: "<DEPARTMENT_ID>"
category_id: "<CATEGORY_ID>"
root_category_id: "<ROOT_CATEGORY_ID>"
language: pl
content_type: html
ignore: true
---
<p>HTML content here.</p>
```

Notes:
- Use HTML content (no markdown conversion is done).
- Use `ignore: true` to skip a draft file.
- If you already know an article ID, add `id: "<ARTICLE_ID>"` to update it directly.

## Known IDs (current)
- department Pomoc: `226590000000007061`
- department RODO i Prywatnosc: `226590000000361029`
- department Reklamacje: `226590000000372029`
- categoryId: `226590000000356054`
- rootCategoryId: `226590000000356035`

## Scripts
- `scripts/zoho-desk-info.sh` lists departments.
- `scripts/sync-articles.sh` creates/updates articles from `articles/`.

## Workflow
- `.github/workflows/sync-articles.yml` runs on push to `main` or manually.

## Local usage
```bash
export ZOHO_ACCESS_TOKEN="..."
export ZOHO_ORG_ID="20111859397"
./scripts/sync-articles.sh
```
