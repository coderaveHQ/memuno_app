# Legal Site

This folder contains localized legal documents and static-site tooling for GitHub Pages.

## Structure

- `content/en-US/*.md` and `content/de-DE/*.md`: canonical legal document content.
- `config/development.json`, `config/staging.json`, `config/production.json`: environment-specific legal/contact metadata.
- `templates/`: HTML page and redirect templates.
- `scripts/build_legal_site.sh`: builds static HTML into `legal/dist`.
- `scripts/check_legal_links.sh`: validates internal legal links in `legal/dist`.

## Canonical documents

- `privacy-policy`
- `terms-of-use`
- `community-guidelines`
- `account-deletion`
- `support`
- `impressum`

## Auxiliary operational pages (non-nav)

- `account-deletion-request`
- `account-deletion-confirm`

These pages are generated per locale for the verified external deletion workflow and are not part of the canonical legal document list.

## Locales

Canonical locales are `en-US` and `de-DE`.

Alias routes are generated for `en` -> `en-US` and `de` -> `de-DE` as redirects.

## Build

From repository root:

```bash
legal/scripts/build_legal_site.sh
legal/scripts/check_legal_links.sh
```

Build output:

- Development tree (local only): `legal/dist/development/legal/<locale>/<doc>/index.html`
- Production tree: `legal/dist/legal/<locale>/<doc>/index.html`
- Staging tree: `legal/dist/staging/legal/<locale>/<doc>/index.html`

Required config keys per environment file:

- `site_url`
- `supabase_url`
- `supabase_publishable_key`

## GitHub Pages URL map

Replace `<org-or-user>` with your GitHub org/user.

Development (local only, not deployed by CI):

- `http://<YOUR-LAN-IP>:8080/development/legal/en-US/privacy-policy/`
- `http://<YOUR-LAN-IP>:8080/development/legal/en-US/terms-of-use/`
- `http://<YOUR-LAN-IP>:8080/development/legal/en-US/community-guidelines/`
- `http://<YOUR-LAN-IP>:8080/development/legal/en-US/account-deletion/`
- `http://<YOUR-LAN-IP>:8080/development/legal/en-US/account-deletion-request/`
- `http://<YOUR-LAN-IP>:8080/development/legal/en-US/account-deletion-confirm/`
- `http://<YOUR-LAN-IP>:8080/development/legal/en-US/support/`
- `http://<YOUR-LAN-IP>:8080/development/legal/en-US/impressum/`
- Same paths for `de-DE`, plus aliases under `en` and `de`.

Production:

- `https://<org-or-user>.github.io/memuno_app/legal/en-US/privacy-policy/`
- `https://<org-or-user>.github.io/memuno_app/legal/en-US/terms-of-use/`
- `https://<org-or-user>.github.io/memuno_app/legal/en-US/community-guidelines/`
- `https://<org-or-user>.github.io/memuno_app/legal/en-US/account-deletion/`
- `https://<org-or-user>.github.io/memuno_app/legal/en-US/account-deletion-request/`
- `https://<org-or-user>.github.io/memuno_app/legal/en-US/account-deletion-confirm/`
- `https://<org-or-user>.github.io/memuno_app/legal/en-US/support/`
- `https://<org-or-user>.github.io/memuno_app/legal/en-US/impressum/`
- Same paths for `de-DE`, plus aliases under `en` and `de`.

Staging:

- `https://<org-or-user>.github.io/memuno_app/staging/legal/en-US/privacy-policy/`
- `https://<org-or-user>.github.io/memuno_app/staging/legal/en-US/terms-of-use/`
- `https://<org-or-user>.github.io/memuno_app/staging/legal/en-US/community-guidelines/`
- `https://<org-or-user>.github.io/memuno_app/staging/legal/en-US/account-deletion/`
- `https://<org-or-user>.github.io/memuno_app/staging/legal/en-US/account-deletion-request/`
- `https://<org-or-user>.github.io/memuno_app/staging/legal/en-US/account-deletion-confirm/`
- `https://<org-or-user>.github.io/memuno_app/staging/legal/en-US/support/`
- `https://<org-or-user>.github.io/memuno_app/staging/legal/en-US/impressum/`
- Same paths for `de-DE`, plus aliases under `en` and `de`.

## Notes

- Keep legal metadata current in all config files before release.
- Configure repository Pages to serve from `gh-pages` branch.
- The workflow deploys production and staging paths into the same branch using separate destination directories.
