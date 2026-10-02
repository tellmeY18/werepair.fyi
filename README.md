# werepair.fyi — runnable POC

Phoenix 1.8, Elixir 1.18, Ecto and SQLite. Server-rendered HEEx, normal HTML forms,
plain black-and-white CSS. No frontend build or database server needed.
`CLAUDE.md` is the product brief; this directory is the project root.

## Run

```sh
nix develop path:.
just setup
just serve
```

Open **http://localhost:4000**. `flake.lock` pins the Nix toolchain for macOS and Linux.
Alternatively run `nix develop path:. --command just setup` and
`nix develop path:. --command just serve`. With direnv, run `direnv allow`.
`path:.` also works before the flake is tracked in Git.

`just setup` installs Hex dependencies, migrates SQLite and seeds the demo.
`just seed` is repeatable: it leaves existing demo data and your changes alone.
Local data lives in `werepair_dev.db`; tests use a separate sandboxed database.
To deliberately reset all **development data**, stop the server and run
`mix ecto.reset` inside the shell.

## Demo accounts

All use password **`RepairDemo2026!`**. These are fictional people and contact details.

| Account | Email | Demo use |
|---|---|---|
| Asha Nair | `asha@example.test` | Requester, tracking, outcomes, reviews, journals |
| Ravi Menon | `ravi@example.test` | Technician, responses, confirmation, mentor |
| Meera Joseph | `meera@example.test` | Apprentice with four recorded hours |
| Demo Organiser | `admin@example.test` | Events, attendance, reports, cost ledger |

There are 20 technicians across Kochi neighbourhoods, 10 requests, two events,
five completed journal-ready repairs with two-sided reviews, an upcoming pending
apprenticeship, a completed apprenticeship, a moderation report and ledger entries.
Everyone has one account; listing repair skills is a profile preference, not a role switch.

## Ten-minute walkthrough

1. **Public discovery:** browse Technicians, search `Electronics` or `Kaloor`,
   open Ravi's profile and OSM map. Inspect the completed event and What it costs.
1. **Request a repair:** sign in as Asha. Post one item, optionally upload a
   PNG/JPEG (2 MB maximum). Commit to documenting it. All request content is public.
1. **Respond:** sign out, sign in as Ravi, open that request and leave a comment
   with an optional price. Request moves to **In talks**.
1. **Choose and document:** as Asha, choose Ravi's response. Add a **Requester
   tracking log** with work, parts, purchaser and price. Mark **Fixed**, **Partly**
   or **Not fixed** with a note. Reopen or cancel is also available before completion.
1. **Confirm and review:** as Ravi, confirm the outcome and optionally consent to
   wiki credit. As Asha, close the request and leave a review. Ravi reviews Asha;
   both reviews then become public and affect profiles.
1. **Journal:** as Asha, select **Publish journal to wiki**. Review the editable
   wikitext draft. This is the demo endpoint: **MediaWiki is not deployed**.
   When an external wiki exists, copy into its editor and save the resulting URL.
1. **Events:** open the upcoming Kochi fest. Ravi is already signed up as technician.
   As Asha, pre-register your item. As Ravi, accept Meera's pending apprenticeship,
   then mark attended with hours. See those hours on Meera's public profile.
   A new apprentice account can request another place through Join event.
1. **Organise:** as admin, create an event, record technician/requester attendance,
   then publish the event summary. Only mentors record their apprentices' hours.
1. **Moderate:** the admin desk has a seeded simulated spam report. Open its context
   and remove it. Reports also support requests, profiles and reviews; removing a
   profile suspends its account and invalidates subsequent authenticated requests.
1. **Transparency:** add an expense or donation through the admin desk and see
   the monthly totals update. Platform commission is always zero.

Use separate browser profiles to keep requester, technician and organiser sessions open.
The seeded sewing-machine request is already in progress if you want to skip ahead.

## Wiki and email boundaries

- No MediaWiki deployment, wiki credentials or remote writes are included.
  `WIKI_URL` defaults to `https://wiki.werepair.fyi`; override it when your wiki exists.
- `just wiki-export` creates `data/wiki-seed.xml`: 15 short starter pages plus five
  seeded repair journals, ready for a later MediaWiki import. These are labelled
  demo drafts, not a professionally reviewed repair manual.
- Journal export includes requester-authored logs, not comments, emails, phones or
  photos. Technician credit requires their explicit consent. Authors must review
  free text for private details before publishing under CC BY-SA 4.0.
- New responses generate local demo email, viewable at `/dev/mailbox` while the
  server is running. No email is sent externally. Email delivery/provider setup,
  reminders and account recovery automation are deferred.

## POC choices

- SQLite through `ecto_sqlite3`; no PostgreSQL or Turso connection.
- Contexts enforce ownership and admin/mentor permissions; signed sessions expire
  after seven days. Passwords use PBKDF2. Forms use CSRF protection; privileged
  fields cannot be set by registration/profile parameters.
- L1 means an account; L5 reflects recorded activity, not identity verification.
  Mentoring requires two completed repairs as technician. Phone/ID verification
  is deferred, so **all phone numbers remain private**.
- Directory ordering is transparently alphabetical with text search; OSM embeds
  show the Kochi area and individual neighbourhood pins. No distance ranking.
- Reviews appear only after both parties submit. No timed automatic release yet.
- One public image per request is stored in SQLite for this small demo. Nothing
  is automatically sent to Commons or YouTube.
- Recovery, deletion/export and appeals are manual via the organiser. OAuth,
  payments, chat, automatic archival, Malayalam translation and advanced discovery
  remain outside this demonstrable slice.
- `DEMO=false` hides demo labels/account hints; it does **not** remove seed data.
  Release seeding requires explicit `DEMO=true` and `ALLOW_DEMO_SEED=true`.
  Use a fresh database for real users.

## Checks and code map

```sh
just check                 # mix precommit: warnings-as-errors, format, tests
just test
```

`test/werepair_web/controllers/platform_flow_test.exs` exercises real routed form
requests, authorization, repair transitions, ratings, event apprenticeships,
moderation and privacy. `lib/werepair/` contains Accounts, Repairs, Events and
Community contexts; `lib/werepair_web/` contains controllers and HEEx components.
`priv/repo/seeds.exs` uses those same contexts for the demo scenarios.

For a production release, supply `DATABASE_PATH`, `SECRET_KEY_BASE`, `PHX_HOST`
and `PHX_SERVER=true`, and terminate HTTPS at your reverse proxy. This repository
is a local POC, with no deployment performed.

## Container demo

The multi-stage `Dockerfile` builds an OTP release (no compiler or Mix in the runtime).
GitHub Actions tests every change and publishes `ghcr.io/tellmey18/werepair.fyi:sha-<commit>`
on `main`. The image is linux/amd64 for the cluster's ZFS storage nodes.

Kubernetes manifests live in the infrastructure repository at
`k8s/clusters/glug-infra/werepair/`. One replica uses a ZFS-backed SQLite PVC and
Recreate updates. An init container migrates and idempotently seeds an explicitly
enabled demo. `PHX_SERVER=false` during initialization prevents early traffic.

Runtime uses a non-root UID, read-only root filesystem, dropped capabilities,
RuntimeDefault seccomp, no service-account token and denied egress. Only Traefik
can reach port 4000. Email delivery is
disabled in releases. Demo admins can modify demo records, not Kubernetes resources.
Resource quotas, request-size/rate limits and the 1 GiB PVC bound demo resource use.

The session-signing secret is generated in-cluster, never included in the image or
repository. Image publication uses GitHub's short-lived workflow token; deployment
credentials never enter GitHub Actions.

Code: AGPL-3.0-only. Authored wiki seed content: CC BY-SA 4.0.
