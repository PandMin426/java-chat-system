# PLAN — docs-restructure

| Field | Value |
|---|---|
| Feature name | `docs-restructure` |
| Created | 20/11/2026 |
| Owner(s) | Trang |
| Status | `DONE` |
| Plan approved by user | YES (20/11/2026) |

---

## 1. SUMMARY

Split `docs/` into `docs/frontend`, `docs/backend`, `docs/database` and move the current folders into the matching category so the docs are easier to find. All references (README, rule.md, ScreenshotTool output path, links inside docs) are updated so nothing points to an old path.

---

## 2. INPUT / OUTPUT

### Input
- User request (20/11/2026): "phần ra là docs/backend, doc/frontend, doc/database để phân loại và đưa các folder hiện tại vào các folder phân loại liên quan".

### Output / Expected result (Q1 = B, Q2 = docs root)

| Current | New |
|---|---|
| `docs/screens/user`, `docs/screens/admin` | `docs/frontend/screens/user`, `docs/frontend/screens/admin` |
| `docs/ai/ui-user-screens`, `ui-admin-screens`, `ui-align-decisions`, `ui-username-group-size` | `docs/frontend/ai/<feature>` |
| `docs/database/design-baseline.md` | unchanged |
| `docs/ai/database-schema` | `docs/database/ai/database-schema` |
| `docs/reports/` (screen-vs-DB conflict reports, DB as standard) | `docs/database/reports/` |
| `docs/research_notes/` (notes behind those reports) | `docs/database/research_notes/` |
| — (no backend docs yet) | `docs/backend/.gitkeep`; future backend features go to `docs/backend/ai/<feature>` |
| `docs/Final_Project_He_Thong_Chat_Chi_Tiet.md` (course brief) | unchanged (docs root) |
| `docs/ai/work-log.md`, `docs/ai/_template/`, cross-cutting features (`requirements-analysis`, `project-setup`, `docs-db-rule-sync`, `docs-restructure`) | unchanged in `docs/ai/` |

- New rule: a feature folder lives in `docs/<area>/ai/<feature-name>/` where `<area>` is `frontend`, `backend` or `database`; cross-cutting features stay in `docs/ai/<feature-name>/`. `work-log.md` and the templates stay global in `docs/ai/`.
- `.agent/rules/rule.md` (Rules 0/1/2/3/5/6, Part C), the templates' instructions and the work-log header rules are updated to this layout.
- `ScreenshotTool` (user and admin) default output → `../../docs/frontend/screens/<app>`.
- README project tree and links, and every markdown link/path mention in docs, point to the new paths.

---

## 3. SCOPE

### In scope
- `git mv` of the folders/files above (keeps Git history).
- Path updates in README.md, ScreenshotTool javadoc/default path, and links/path mentions inside docs (except old work-log entries).

### Out of scope
- Content changes to any moved document.
- Old `work-log.md` entries (append-only): they keep the old paths; a new entry records the move.
- Backend documentation content (no backend exists yet).

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

| # | Type | Description | Status |
|---|---|---|---|
| 1 | QUESTION | Where do AI process docs go? (A) keep `docs/ai/` as is (rule.md unchanged), only categorize the content docs; (B) also move feature folders into categories (e.g. `docs/frontend/ai/ui-user-screens`, `docs/database/ai/database-schema`) and rewrite rule.md Rules 1/2/3/6 paths. User answered: (B) split feature folders by area and update rule.md. | RESOLVED |
| 2 | QUESTION | Docs that are not frontend/backend/database (course brief, requirements): put in a 4th folder `docs/general/`, or keep at `docs/` root? User answered: keep at `docs/` root; cross-cutting AI feature folders stay in `docs/ai/`. | RESOLVED |
| 3 | ASSUMPTION | Reports and research notes "Xung đột màn hình và CSDL" go to `docs/database/` because they take the DB as the standard. Approved with the plan. | CONFIRMED |
| 4 | ASSUMPTION | Done after `ui-username-group-size` and `docs-db-rule-sync` are committed, so moves are a clean separate commit. User asked the AI to commit each feature (no push). | CONFIRMED |

---

## 5. APPROACH

### Step 1: Move files
- **Action:** `git mv` per the table in section 2; add `docs/backend/.gitkeep`; update rule.md, templates and work-log header rules to the new layout.
- **Verify:** `git status` shows renames (R), no deletions without matching additions; old folders gone.

### Step 2: Update references
- **Action:** Replace old paths in README.md, both `ScreenshotTool.java`, and markdown links/mentions in docs (relative links recomputed for moved files).
- **Verify:** A link-check script resolves every relative markdown link in `docs/` and README to an existing file; `grep` for `docs/screens/`, `docs/reports/`, `docs/research_notes/`, `docs/ai/ui-`, `docs/ai/database-schema` outside old work-log entries returns nothing.

### Step 3: Build check
- **Action:** Run `./mvnw -B -q test` and the ScreenshotTool once.
- **Verify:** Tests pass; screenshots are written to `docs/frontend/screens/*` and `git status` shows no new files under the old path.

### Alternatives considered
- Leave `docs/ai/` untouched (option A): no rule change. User chose option B: feature docs grouped by layer, at the cost of changing rule.md that every teammate follows.

---

## 6. FILES TO CREATE / MODIFY

| Action | File path | Description |
|---|---|---|
| MOVE | `docs/screens/**` → `docs/frontend/screens/**` | Screenshots |
| MOVE | `docs/reports/**` → `docs/database/reports/**` | Conflict reports |
| MOVE | `docs/research_notes/**` → `docs/database/research_notes/**` | Research notes |
| MOVE | `docs/ai/ui-*` (4 folders) → `docs/frontend/ai/` | Frontend feature docs |
| MOVE | `docs/ai/database-schema` → `docs/database/ai/` | Database feature docs |
| CREATE | `docs/backend/.gitkeep` | Empty backend category |
| MODIFY | `README.md` | Project tree and links |
| MODIFY | `src/user/src/test/java/com/chatapp/user/ScreenshotTool.java` | Default output path and javadoc |
| MODIFY | `src/admin/src/test/java/com/chatapp/admin/ScreenshotTool.java` | Default output path and javadoc |
| MODIFY | Markdown files in `docs/` that link to moved paths | Path/link updates only |
| MODIFY | `.agent/rules/rule.md` | Feature folder location rule (Rules 0/1/2/3/5/6, Part C) |
| MODIFY | `docs/ai/_template/plan.template.md`, `feature.template.md` | Copy-to path in instructions |
| CREATE | `docs/ai/docs-restructure/docs-restructure.md` | Feature description (Rule 2) |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker (Rule 3) |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- None.

### Depends on other features
- ui-username-group-size, docs-db-rule-sync — committed first (assumption 4).

### Technical constraint check (Rule 8)
- [x] No networking code touched.
- [x] No WebSocket library or API is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| Broken relative links after moving | MEDIUM | Link-check script in Step 2 |
| ScreenshotTool writes to old path | MEDIUM | Change default path; verify in Step 3 |
| Teammates' open branches still use old paths | LOW | Mention in feature doc; Git rename detection handles most merges |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | Docs live under frontend/backend/database (+ global ai, course brief at root); rule.md describes this layout | `find docs -maxdepth 3`; read rule.md Rule 6 | PASS |
| 2 | No broken relative links in docs/README | Link-check script (no new broken link vs. pre-move baseline) | PASS |
| 3 | No stale path mentions outside old work-log entries | grep | PASS |
| 4 | Tests pass and screenshots land in new folder | `./mvnw -B -q test`, ScreenshotTool | PASS |

---

## 10. ITERATION LOG

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | 20/11/2026 |
| Commit message to use | `feat(docs-restructure): split docs into frontend, backend and database` |
| Notes | Feature folders split by area with rule.md/templates/README/ScreenshotTool updated; course brief and cross-cutting features stay in docs root / docs/ai; 459 pre-existing broken links in two research notes left as they were. |

Do NOT write a commit hash here. This file is part of the commit itself, so the hash does not exist yet when the file is written.

---
*Feature description: [docs-restructure.md](./docs-restructure.md)*
