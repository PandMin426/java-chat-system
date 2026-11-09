# FEATURE — requirements-analysis

| Field | Value |
|---|---|
| Feature name | `requirements-analysis` |
| Created | 08/11/2026 |
| Last updated | 08/11/2026 |
| Owner(s) | Trang |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

Docs-only step done before any UI code. The customer requirements (`Final Project.pdf`) were analysed for ambiguities and conflicts, turned into a use-case specification, and visualised as a clickable prototype of every screen so the team can agree on behaviour and layout before building JavaFX screens.

---

## 2. PURPOSE / USE CASE

- **Actor:** Project team (Minh, Trang) and the instructor reviewing V1
- **Trigger:** Start of the UI/UX phase, before V1 screen coding
- **Goal:** A confirmed list of use cases, defaults for unclear requirements, and an approved screen design to implement

---

## 3. RELATED CLASSES / FILES

| Action | File path | Role |
|---|---|---|
| CREATED | `docs/ai/requirements-analysis/plan.md` | Plan for this step |
| CREATED | `docs/ai/requirements-analysis/use-case-specification.md` | Ambiguity list (K1–K6, M1–M23), actors, 45 use cases, traceability matrix, business rules BR-01..BR-15, screen inventory S01–S17 + dialogs, open questions |
| CREATED | `../design-ui/prototype-canvas/project/canvas.json` | Canvas index: 22 artboards in 8 rows |
| CREATED | `../design-ui/prototype-canvas/project/*.dc.html` | One artboard per screen: `Main` (screen map), `U-*` (user app), `D-*` (user dialogs), `A-*` (admin app) |
| CREATED | `../design-ui/prototype-canvas/assets/app.css` | Shared stylesheet (DESIGN.md tokens; muted text darkened to #6B6B6B and accent to #1764D8 to reach 4.5:1 contrast) |
| MODIFIED | `README.md` | Stack (JavaFX, PostgreSQL, plain socket, 3 jars), member roles, V1 22/11/2026 and V2 12/12/2026 deadlines, folder structure, checklist wording |
| MODIFIED | `docs/ai/work-log.md` | Session entries and progress tracker row |

Published prototype (private): https://claude.ai/artifact/MxZtuhNSYunZ2YF3Z4odwA

---

## 4. DATA AND PROTOCOL

### Database changes
N/A - no database changes. The spec lists data the schema will need (soft-delete flag, login_history, spam report status, block relation, per-user message hiding, group key versions) for the DB feature.

### Socket messages
N/A - no network communication. Message types are named in the spec only (`PRIVATE_MSG`, `GROUP_MSG`).

---

## 5. HOW TO RUN / TEST

### Prerequisites
- A browser signed in to the claude.ai account that owns the artifact.

### How to run
```text
Open https://claude.ai/artifact/MxZtuhNSYunZ2YF3Z4odwA
Select artboard "00 · Sơ đồ màn hình" and press Play, then click any screen card.
```

### How to test

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | Compare section 4 of the spec with every item of the PDF | Every item A1a–A9c, U1–U12g maps to a UC | PASS |
| 2 | Read every UC in section 6 of the spec | Actor, flow and exceptions present | PASS |
| 3 | In Play mode, open every card on the screen map and use the side navigation | Every screen opens; tabs, menus and toggles respond | NOT RUN (needs the user; not rendered by the AI) |

---

## 6. TECHNICAL NOTES

- Prototype boards use fixed desktop window sizes (1280×800 main windows, 880×620 login windows) and only layouts JavaFX supports directly: BorderPane/SplitPane shells, TableView with sortable headers, TabPane, ListView, modal Dialogs, BarChart.
- Interactive states built into boards: chat search bar, AI panel (suggest / rewrite), "⋯" menu, message select-and-delete mode, group rename, admin-vs-member view (tweak), friend tabs, friend request send/cancel, profile tabs, admin sort/select/lock, spam lock/ignore, chart year switch with hover tooltips, =/</> count filters.
- Tweaks: `U-Login` (normal / wrong password / locked), `U-Register` (show errors), `U-GroupChat` (view as admin or member), `A-Login` (non-admin account).
- Networking: not applicable — no code. Spec keeps the rule of plain `java.net.Socket` / `ServerSocket` only.

### Changes from the original plan
Iteration 1: a Design canvas with 22 artboards replaced the single HTML file, and the source moved to drive D: because drive C: was full.
Iteration 2: user decisions applied — PostgreSQL, 3-jar architecture, V1 22/11 / V2 12/12, simple group encryption (server-held AES-256 key per group, wrapped by `crypto.masterKey`, encryption at rest). UC-28 rewritten; E2EE wording removed from UC-04/06/20/21/22/24/26/36 and from boards `U-GroupChat`, `D-CreateGroup`, `U-Chat`, `U-ForgotPassword`, `U-Profile`, `A-UserDialogs`; the AI assistant is now allowed in encrypted groups `[ĐX]`. README fixed.

---

## 7. KNOWN ISSUES / LIMITATIONS

- Not in Figma: the Figma connector is not authorized in this Claude session.
- The prototype was not rendered or click-tested by the AI; layout issues (overflow, alignment of y-axis labels) may exist.
- D04 (add member dialog) has no own board; the "Thêm thành viên" button links to the create-group dialog, which uses the same picker.
- K1, K3, K4, K5 are confirmed (08/11/2026). Defaults M7, M12, M15, M17, M18 (spec section 8, questions 5–9) are still unconfirmed; other `[ĐX]` defaults were accepted by the user.
- Group encryption is at rest only: messages travel over the plain socket unencrypted, and anyone holding `crypto.masterKey` can read encrypted groups.
- Sample data only; numbers in tables and charts are invented for layout.
