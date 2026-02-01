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
status: Published
department_id: "<ZOHO_DEPARTMENT_ID>"
category_id: "<ZOHO_CATEGORY_ID>"
section_id: "<ZOHO_SECTION_ID>"
language: pl
content_type: html
---
<p>HTML content here.</p>
```

Notes:
- Use HTML content (no markdown conversion is done).
- If you already know an article ID, add `id: "<ARTICLE_ID>"` to update it directly.

## Scripts
- `scripts/zoho-desk-info.sh` lists departments, categories and sections.
- `scripts/sync-articles.sh` creates/updates articles from `articles/`.

## Workflow
- `.github/workflows/sync-articles.yml` runs on push to `main` or manually.

## Local usage
```bash
export ZOHO_ACCESS_TOKEN="..."
export ZOHO_ORG_ID="20111859397"
./scripts/sync-articles.sh
```
