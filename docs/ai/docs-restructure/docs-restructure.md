# FEATURE — docs-restructure

| Field | Value |
|---|---|
| Feature name | `docs-restructure` |
| Created | 20/11/2026 |
| Last updated | 20/11/2026 |
| Owner(s) | Trang |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

Splits `docs/` by area: `docs/frontend`, `docs/backend`, `docs/database`. Screenshots, reports and research notes and the per-feature AI folders now sit under the area they belong to. `docs/ai/` keeps only the global work-log, the templates and cross-cutting features. `rule.md`, the templates, README, the ScreenshotTool output path and every working link point to the new layout.

---

## 2. PURPOSE / USE CASE

- **Actor:** Team members and AI sessions working on the project.
- **Trigger:** Looking for a document, or starting a new feature (Rule 0 decides its folder).
- **Goal:** Find frontend, backend and database documents in their own folder instead of one flat `docs/ai/`.

---

## 3. RELATED CLASSES / FILES

| Action | File path | Role |
|---|---|---|
| MOVED | `docs/screens/**` → `docs/frontend/screens/**` | 29 screenshots (user, admin) |
| MOVED | `docs/ai/ui-user-screens`, `ui-admin-screens`, `ui-align-decisions`, `ui-username-group-size` → `docs/frontend/ai/` | Frontend feature docs |
| MOVED | `docs/ai/database-schema` → `docs/database/ai/database-schema` | Database feature docs |
| MOVED | `docs/reports/**` → `docs/database/reports/**` | Screen-vs-DB conflict reports |
| MOVED | `docs/research_notes/**` → `docs/database/research_notes/**` | Notes behind those reports |
| CREATED | `docs/backend/.gitkeep` | Empty backend area (no backend feature yet) |
| MODIFIED | `.agent/rules/rule.md` | New `<feature-dir>` rule (Rules 0/1/2/5, Part C), new Rule 6 tree; template path `templates/` → `_template/` |
| MODIFIED | `docs/ai/_template/plan.template.md`, `feature.template.md` | Copy-to path uses `<feature-dir>` |
| MODIFIED | `docs/ai/work-log.md` | Header rule 3 and template entries use the new folder rule; new log entries; tracker |
| MODIFIED | `README.md` | `docs/` tree in section 3 |
| MODIFIED | `src/user/src/test/java/com/chatapp/user/ScreenshotTool.java`, `src/admin/src/test/java/com/chatapp/admin/ScreenshotTool.java` | Default output `../../docs/frontend/screens/<app>` and javadoc |
| MODIFIED | 20 markdown files in `docs/` | Relative links recomputed (moved file or moved target) and `docs/...` path mentions renamed |

---

## 4. DATA AND PROTOCOL

### Database changes
N/A - no database changes.

### Socket messages
N/A - no network communication.

---

## 5. HOW TO RUN / TEST

### Prerequisites
- JDK 21+, Python 3 (link check), Git Bash.

### How to run
```bash
./mvnw -B -q test
./mvnw -B -q -pl src/common,src/user,src/admin test -Dtest=ScreenshotTool -Dsurefire.failIfNoSpecifiedTests=false
grep -rnI -E "docs/(screens|reports|research_notes)|docs/ai/(ui-|database-schema)" --exclude-dir=target --exclude-dir=.git .
```

### How to test

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | `find docs -maxdepth 3`; read rule.md Rule 6 | Layout matches section 3 and Rule 6 | PASS |
| 2 | Link check of every relative markdown link, before and after the move | No new broken link (same 459 pre-existing ones in two research notes, plus template placeholders) | PASS |
| 3 | Stale-path grep above | Only old work-log entries and this feature's plan (which lists the old paths) | PASS |
| 4 | Maven tests and ScreenshotTool | user 29/29, admin 23/23; PNGs rewritten under `docs/frontend/screens/` (byte-identical), old folder not recreated | PASS |

---

## 6. TECHNICAL NOTES

- Moves use `git mv`, so Git shows renames and history follows the files.
- Folder rule: `<feature-dir>` = `docs/<area>/ai/<feature-name>/` (area = frontend, backend, database) or `docs/ai/<feature-name>/` for cross-cutting work. `work-log.md` and `_template/` stay global. The course brief stays at `docs/` root (user's choice).
- Relative links were recomputed only when they worked before the move. `research_notes/.../admin.md` and `user_tai_khoan.md` write links from the workspace root (not from the file), which were already broken before; their style was kept and only the `docs/...` part renamed.
- Old work-log entries keep their historical paths (append-only).
- rule.md said `docs/ai/templates/`, but the real folder is `docs/ai/_template/` (logged as a NOTE on 08/11/2026). Fixed because these exact lines were being rewritten.
- Networking: none; no WebSocket.

### Changes from the original plan
None - implemented as planned after the user's answers (Q1 = split feature folders by area, Q2 = course brief at docs root).

---

## 7. KNOWN ISSUES / LIMITATIONS

- 459 pre-existing broken links in the two research notes listed above (workspace-root style). Not converted.
- Branches created before this commit (e.g. `fix_FE`, `feature/*`) still use the old paths. Git rename detection handles most merges, but new files added there under `docs/ai/ui-*` or `docs/screens/` must be moved by hand.
- README section 3 still lists `script/create_db.sql` and rule.md Rule 6 still shows `script/create_db.sql`, while the real scripts are `schema.sql`, `seed.sql`, `queries.sql`. This was already noted in the database-schema handoff and was not changed here.
