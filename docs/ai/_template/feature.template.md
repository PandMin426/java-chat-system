# FEATURE — <feature-name>

<!--
TEMPLATE INSTRUCTIONS (the AI MUST delete this comment and every other HTML comment in the real feature doc):
1. Copy this file to docs/ai/<feature-name>/<feature-name>.md. Never edit the template itself.
2. Create it right after the feature is finished (Rule 2), BEFORE reporting "done".
3. Describe ONLY what was actually implemented. Do not copy from plan.md. Compare against the real code and files first.
4. Replace EVERY <placeholder>. Never leave "...", "<...>", or example text in the real document.
5. Never leave a section empty. If a section does not apply, write "N/A - <reason>".
6. Use the real current date (get it from the system, or ask the user). Never guess it.
7. Write in English. Be concrete: real class names, real file paths, real commands that were actually run.
-->

| Field | Value |
|---|---|
| Feature name | `<feature-name>` |
| Created | DD/MM/YYYY |
| Last updated | DD/MM/YYYY |
| Owner(s) | <member name(s)> |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

<2-3 sentences: What does this feature do? Why does it exist?>

---

## 2. PURPOSE / USE CASE

- **Actor:** <who uses it: Admin / User / System>
- **Trigger:** <when the feature is invoked (for example: user clicks "Send")>
- **Goal:** <the result the actor gets>

---

## 3. RELATED CLASSES / FILES

List every file that was created or modified for this feature. This list MUST match the real code.

| Action | File path | Role |
|---|---|---|
| CREATED | `src/.../<ClassName>.java` | <what the class does> |
| MODIFIED | `src/.../<ExistingClass>.java` | <exactly what was added or changed> |

---

## 4. DATA AND PROTOCOL

### Database changes
<Tables/columns added or changed, and the script file that contains them (for example `script/create_db.sql`). Write "N/A - no database changes" if none.>

### Socket messages
<Messages exchanged over java.net.Socket for this feature. Write "N/A - no network communication" if none.>

| Message / command | Direction | Payload format | Response |
|---|---|---|---|
| <name> | Client -> Server | <fields, separators, or JSON example> | <response or ack> |

---

## 5. HOW TO RUN / TEST

### Prerequisites
- <what must be installed, configured, or running first (for example: PostgreSQL running, server started)>

### How to run
```bash
# Use the exact commands that were actually run, in order.
<command 1>
<command 2>
```

### How to test
Mirror the success criteria in section 9 of `plan.md`, with their final results.

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | <exact steps> | <expected behavior> | PASS / FAIL / NOT RUN |

---

## 6. TECHNICAL NOTES

- <important detail, such as threading model, synchronization, message encoding, validation rules, design decision and its reason>
- Networking: <confirm that only plain `java.net.Socket` / `java.net.ServerSocket` is used, with no WebSocket>

### Changes from the original plan
<Short summary of iterations from section 10 of `plan.md`, or "None - implemented as planned.">

---

## 7. KNOWN ISSUES / LIMITATIONS

- <bug, missing behavior, or trade-off that still exists. Write "None known" only if you are sure.>
