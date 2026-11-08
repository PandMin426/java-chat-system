# PLAN — requirements-analysis

| Field | Value |
|---|---|
| Feature name | `requirements-analysis` |
| Created | 08/11/2026 |
| Owner(s) | Trang |
| Status | `IN_PROGRESS` |
| Plan approved by user | YES (08/11/2026) — the user directly requested this docs-only deliverable (analysis → use cases → prototype) before any UI code |

---

## 1. SUMMARY

Analyse the customer requirements in `Final Project.pdf` (admin subsystem items 1–9, user subsystem items 1–12, delivery rules), list every ambiguity or conflict, and turn the requirements into a use-case specification. Then build a clickable prototype of all screens so the user can review the UX before UI coding starts. No Java code is written in this step.

---

## 2. INPUT / OUTPUT

### Input
- `dumpDocs/Final Project.pdf` (customer requirements)
- `dumpDocs/YeuCau.txt` (technical constraints: Java GUI, Java backend, plain socket, AI workflow)
- `code/.agent/rules/rule.md`, `code/README.md`, `dumpDocs/project_roadmap.md`, `dumpDocs/framework_recommendations.md`
- `.agent/skills/DESIGN.md` (design tokens) and the existing `design-ui/*.html` mockups

### Output / Expected result
- `docs/ai/requirements-analysis/use-case-specification.md`: ambiguity list, actors, use-case list mapped to every requirement ID, and one specification per use case
- A clickable HTML prototype covering every screen in the use-case list, published as a private artifact for review
- `docs/ai/requirements-analysis/requirements-analysis.md` (feature doc) and work-log entries

---

## 3. SCOPE

### In scope
- Ambiguity/conflict list with a proposed default for each point
- Use-case specification for both subsystems
- Clickable prototype (HTML) using the DESIGN.md tokens, laid out as desktop windows so it maps to JavaFX

### Out of scope
- Any Java/JavaFX code, FXML, or database script (separate features after the prototype is approved)
- Figma file (connector not authorized in this session)
- Editing the existing `design-ui/` mockups or README.md (conflicts are reported, not fixed)

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

| # | Type | Description | Status |
|---|---|---|---|
| 1 | ASSUMPTION | Use-case spec and prototype UI text are written in Vietnamese (the report language); plan/feature docs stay in English per template | UNCONFIRMED |
| 2 | ASSUMPTION | Each ambiguity in the PDF gets a proposed default, written in the spec, so the prototype can show one concrete behavior | UNCONFIRMED |
| 3 | QUESTION | Final tech stack: JavaFX + PostgreSQL (work-log) or React + MySQL (README)? React is not allowed by YeuCau.txt. **User answer 08/11/2026:** PostgreSQL; fix README. | RESOLVED |
| 4 | QUESTION | Real V1/V2 deadlines: README says V1 18/10/2026, roadmap says V1 22/11 and V2 12/12. **User answer 08/11/2026:** V1 22/11/2026, V2 12/12/2026. | RESOLVED |
| 5 | QUESTION | 3-jar architecture (server/user/admin + 1 config.properties)? **User answer 08/11/2026:** agreed. | RESOLVED |
| 6 | QUESTION | Group encryption: true E2EE or simple server-held key? **User answer 08/11/2026:** simple. | RESOLVED |
| 7 | QUESTION | Defaults M7, M12, M15, M18, M17 (spec section 8, questions 5–9) | OPEN — user will answer later |

Question 7 does not block this docs-only step; it must be resolved before the related features are coded.

---

## 5. APPROACH

### Step 1: Requirement analysis
- **Action:** Read every requirement line and the delivery rules; record ambiguities, conflicts and risks with a proposed default.
- **Verify:** Every numbered item/sub-item in the PDF (A1a–A9, U1–U12g) appears in the traceability table of the spec.

### Step 2: Use-case specification
- **Action:** Define actors, the use-case list, and a specification (actor, pre/post-conditions, main flow, alternative/exception flows, business rules) for each use case.
- **Verify:** No requirement ID is missing from the traceability table; each use case references at least one requirement ID or is marked as an added supporting use case.

### Step 3: Clickable prototype
- **Action:** Build a single HTML prototype with desktop-window frames for the login windows, user app and admin app; publish it as a private artifact.
- **Verify:** Every screen listed in the spec's screen inventory can be reached by clicking from the prototype's navigation.

### Alternatives considered
- Figma file via the Figma connector — not possible, the connector needs authorization in claude.ai settings.
- Re-using the 15 existing `design-ui/` pages as-is — not chosen: they mix English developer jargon ("Peers", "credential-handshake"), show requirement labels in the UI, and miss several flows (block list, report dialog, group key rotation). They remain as reference.

---

## 6. FILES TO CREATE / MODIFY

| Action | File path | Description |
|---|---|---|
| CREATE | `docs/ai/requirements-analysis/plan.md` | This plan |
| CREATE | `docs/ai/requirements-analysis/use-case-specification.md` | Ambiguities + use-case specification |
| CREATE | `../design-ui/prototype-canvas/` (`project/canvas.json`, `project/*.dc.html`, `assets/app.css`) | Clickable prototype source, 22 artboards (outside the git repo, next to existing mockups) — see Iteration 1 |
| CREATE | `docs/ai/requirements-analysis/requirements-analysis.md` | Feature description document (Rule 2) |
| MODIFY | `README.md` | Iteration 2: tech stack (JavaFX, PostgreSQL, plain socket, 3 jars), member roles, V1/V2 deadlines, folder structure, checklist wording |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker (Rule 3) |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- None for the repo. The prototype is a standalone HTML file (plain CSS/JS, Google Fonts Inter + JetBrains Mono).

### Depends on other features
- None.

### Technical constraint check (Rule 8)
- [x] This feature uses only `java.net.Socket` / `java.net.ServerSocket` for networking. (N/A — no networking code)
- [x] No WebSocket library or API is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| Defaults chosen for ambiguities differ from what the instructor expects | MEDIUM | Each default is marked in the spec and listed for the user to confirm before coding |
| HTML prototype shows layouts that JavaFX cannot reproduce easily | MEDIUM | Use only patterns available in JavaFX (BorderPane/SplitPane, TableView, ListView, TabPane, Dialog, BarChart) |
| Group encryption (U12g) conflicts with password reset, admin password update, server-side search and LLM | HIGH | Documented as a blocking question with a recommended design |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | All requirement IDs A1a–A9c and U1–U12g are traced to a use case | Compare the traceability table with the PDF line by line | PASS — every PDF item appears in section 4 of the spec |
| 2 | Every use case has actor, preconditions, main flow, exceptions, postconditions | Read through the spec | PASS for complex use cases; simple admin UCs (UC-32..38) use a one-line flow by design |
| 3 | Every screen in the screen inventory is reachable in the prototype | Click through every navigation entry in the published prototype | NOT RUN — all 22 artboards were published and each is linked from `Main.dc.html`, but the click-through was not rendered or tested by the AI; the user must click through in Play mode |

---

## 10. ITERATION LOG

## [ITERATION 1 - 08/11]
**Reason for change:** (1) The artifact quickstart offered a "Design" canvas type (one artboard per screen, linked for click-through), which fits a prototype better than one long HTML file. (2) Drive C: ran out of space (0 GB free) while writing to the session scratchpad, so the prototype source had to move to drive D:.
**Old approach:** One file `../design-ui/prototype/chat-prototype.html`.
**New approach:** A Design canvas with 22 artboards (`Main` screen map + 12 user-app boards + 9 admin-app boards). Source files live in `../design-ui/prototype-canvas/project/*.dc.html` + `project/canvas.json`; the shared stylesheet `../design-ui/prototype-canvas/assets/app.css` is uploaded as an artifact asset.
**Impact:** Section 6 file list: the prototype row now points to `../design-ui/prototype-canvas/` (still outside the git repo). Success criterion 3 is unchanged.

## [ITERATION 2 - 08/11]
**Reason for change:** User answered the blocking questions: PostgreSQL + fix README (K1), V1 22/11 / V2 12/12 (K5), 3-jar architecture (K3), simple group encryption instead of E2EE (K4).
**Old approach:** Spec and prototype described end-to-end encryption (client RSA keys, key re-share after password reset, fingerprint, AI disabled in encrypted groups); README left unchanged.
**New approach:** Spec rewritten for server-held group keys with encryption at rest (UC-28 and every UC that referenced E2EE); affected prototype boards updated; README fixed to the agreed stack, deadlines and folder structure.
**Impact:** Adds `README.md` to the file list. Prototype boards changed: `U-GroupChat`, `D-CreateGroup`, `U-Chat`, `U-ForgotPassword`, `U-Profile`, `A-UserDialogs`. Success criteria unchanged.

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | Pending user review of the prototype |
| Commit message to use | `docs(requirements-analysis): add use-case specification, prototype and fix README stack` |
| Notes | Pending |

---
*Feature description: [requirements-analysis.md](./requirements-analysis.md)*
