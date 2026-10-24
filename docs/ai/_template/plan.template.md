# PLAN — <feature-name>

<!--
TEMPLATE INSTRUCTIONS (the AI MUST delete this comment and every other HTML comment in the real plan.md):
1. Copy this file to docs/ai/<feature-name>/plan.md. Never edit the template itself.
2. Replace EVERY <placeholder>. Never leave "...", "<...>", or example text in the real plan.md.
3. Never leave a section empty. If a section does not apply, write "N/A - <reason>".
4. Use the real current date (get it from the system, or ask the user). Never guess it.
5. Write in English. Be concrete: name real classes, files, methods, and message formats.
6. Follow rule.md at all times: Rule 8 (no WebSocket), Rule 9 (state assumptions), Rule 10 (keep it simple), Rule 11 (stay within the file list), Rule 12 (every step has a verify check).
-->

| Field | Value |
|---|---|
| Feature name | `<feature-name>` (kebab-case, same as the folder name) |
| Created | DD/MM/YYYY |
| Owner(s) | <member name(s)> |
| Status | `PLANNING` |
| Plan approved by user | NO |

<!--
Allowed Status values, in order: PLANNING -> AWAITING_APPROVAL -> IN_PROGRESS -> DONE
Allowed "Plan approved by user" values: NO / YES (DD/MM/YYYY)
Coding MUST NOT start until "Plan approved by user" is YES and Status is IN_PROGRESS (Rule 7).
-->

---

## 1. SUMMARY

<2-3 sentences: What does this feature do? Why is it needed? Which use case does it serve?>

---

## 2. INPUT / OUTPUT

### Input
- <data the feature receives, or the event that triggers it (for example: user clicks "Send"; senderId, receiverId, content)>

### Output / Expected result
- <observable result (for example: the message appears on both users' screens; a row is saved in table `messages`)>

---

## 3. SCOPE

### In scope
- <what this feature WILL do>

### Out of scope
- <what this feature will NOT do, including tempting extras that were not requested (Rule 10)>

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

<!-- Every unclear point goes here (Rule 9). Do not pick an interpretation silently. -->

| # | Type | Description | Status |
|---|---|---|---|
| 1 | ASSUMPTION | <assumption made> | CONFIRMED / UNCONFIRMED |
| 2 | QUESTION | <question for the user> | OPEN |

All rows of type QUESTION MUST have Status `RESOLVED` before coding starts. Record the user's answer in the Description cell.

---

## 5. APPROACH

### Step 1: <short title>
- **Action:** <what will be done>
- **Verify:** <concrete check that proves this step works>

### Step 2: <short title>
- **Action:** <what will be done>
- **Verify:** <concrete check>

### Step 3: <short title>
- **Action:** <what will be done>
- **Verify:** <concrete check>

<!-- Add or remove steps as needed. Every step MUST have a Verify line (Rule 12). "Make it work" is NOT a valid check. -->

### Alternatives considered
- <simpler or different option, and why it was or was not chosen. Write "None" only if there is truly no alternative.>

---

## 6. FILES TO CREATE / MODIFY

This list is the boundary of the change (Rule 11). To touch a file that is not listed, first add an iteration entry in section 10 and update this table.

| Action | File path | Description |
|---|---|---|
| CREATE | `src/.../<ClassName>.java` | <what the class does> |
| MODIFY | `src/.../<ExistingClass>.java` | <exactly what is added or changed> |
| CREATE | `docs/ai/<feature-name>/<feature-name>.md` | Feature description document (Rule 2) |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker (Rule 3) |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- `<library> <version>` — <why it is needed>

### Depends on other features
- <feature-name> — <what is needed from it (for example: userId from the session)>. Write "None" if independent.

### Technical constraint check (Rule 8)
- [ ] This feature uses only `java.net.Socket` / `java.net.ServerSocket` for networking.
- [ ] No WebSocket library or API (`javax.websocket`, `spring-boot-starter-websocket`, Tyrus, Java-WebSocket, Socket.IO, ...) is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| <what could go wrong> | HIGH / MEDIUM / LOW | <how it will be handled> |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

The feature is DONE only when every criterion below has Result `PASS`. Run each check for real (Rule 12). If a check cannot be run, keep `NOT RUN`, state why, and give the user the exact manual steps.

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | <expected behavior> | <exact steps or command> | NOT RUN |
| 2 | <expected behavior> | <exact steps or command> | NOT RUN |
| 3 | <expected behavior> | <exact steps or command> | NOT RUN |

Allowed Result values: `NOT RUN` / `PASS` / `FAIL`. Update the Result as soon as a check is done.

---

## 10. ITERATION LOG

<!--
Leave this section empty at first. Add an iteration ONLY when the approach changes during implementation (Rule 1).
Add each new iteration directly above the marker line below. Use EXACTLY this heading format, numbered from 1:

## [ITERATION 1 - DD/MM]
**Reason for change:** <why the approach had to change>
**Old approach:** <what the plan said before>
**New approach:** <what will be done instead>
**Impact:** <files added/removed/changed, dependencies, criteria in section 9 that changed>

Also log a PLAN_UPDATED entry in docs/ai/work-log.md.
-->

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | DD/MM/YYYY |
| Commit message to use | `feat(<feature-name>): <short description>` |
| Notes | <what was done / what was NOT done / trade-offs> |

Do NOT write a commit hash here. This file is part of the commit itself, so the hash does not exist yet when the file is written.

---
*Feature description: [<feature-name>.md](./<feature-name>.md)*
