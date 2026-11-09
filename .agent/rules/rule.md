# AI WORKFLOW RULES — JAVA CHAT SYSTEM

> This file is MANDATORY LAW for every AI working session on this project.
> The AI MUST read and comply with ALL rules below BEFORE starting ANY task related to code.
> Keywords: **MUST** / **MUST NOT** / **NEVER** / **ALWAYS** are absolute requirements, not suggestions.

---

## 0. HOW TO READ AND APPLY THIS FILE

1. This file has two layers:
   - **Workflow Rules (Rule 0–8):** the mandatory process (planning, documentation, logging, commits, tech constraints).
   - **Behavioral Rules (Rule 9–12):** how to think and write code (think first, stay simple, change surgically, verify goals).
2. Both layers apply at the same time. Behavioral Rules define HOW you write code; Workflow Rules define WHAT process you follow around that code.
3. **Precedence on conflict:** Workflow Rules (Rule 0–8) ALWAYS override Behavioral Rules (Rule 9–12).
   Example: a Behavioral Rule says "for trivial tasks, use judgment" — this does NOT permit skipping `plan.md`, the feature doc, `work-log.md`, or the commit reminder. Those are required for every feature, no matter how small.
4. If you are unsure whether a rule applies, assume it applies and follow it.
5. Never skip, shorten, or silently reinterpret a rule. If a rule blocks you, tell the user and ask.

---

# PART A — WORKFLOW RULES (MANDATORY PROCESS)

## [CRITICAL] RULE 0 — READ AND ANNOUNCE BEFORE DOING ANYTHING

Before starting ANY code-related task, the AI MUST:
1. Identify the name of the feature being requested.
2. Check whether the folder `docs/ai/<feature-name>/` already exists.
3. If it does not exist → create the folder and create `plan.md` FIRST. You MUST NOT write a single line of code before this step is done.
4. Tell the user clearly: `"Creating plan.md for feature [feature name] before coding."`

---

## [CRITICAL] RULE 1 — ALWAYS CREATE `plan.md` BEFORE CODING

**Absolutely mandatory. No exceptions.**

- File path: `docs/ai/<feature-name>/plan.md`
- The AI MUST create this file BEFORE writing any code.
- The AI MUST create it by copying the structure of `docs/ai/templates/plan.template.md` and filling in every section (no placeholders left, no empty sections).
- `plan.md` MUST contain:
  - Feature name
  - Feature goal (expected input/output)
  - Planned approach/solution (the implementation steps)
  - Files that will be created/modified
  - Dependencies/libraries that will be used
  - Risks/problems that may occur
  - Scope: what is in scope and what is explicitly out of scope (see Rule 10)
  - Assumptions made and open questions (see Rule 9)
  - Verifiable success criteria per step (see Rule 12)
- If the approach changes during implementation, the AI MUST update `plan.md` IMMEDIATELY by adding a section `## [ITERATION X - DD/MM]` (X starts at 1 for the first change) that states the reason for the change, using the iteration format defined in the template.
- **VIOLATION:** If the AI has written code without `plan.md`, the AI MUST stop, create `plan.md`, and only then continue.

---

## [CRITICAL] RULE 2 — ALWAYS CREATE THE FEATURE DESCRIPTION FILE

**Absolutely mandatory. No exceptions.**

- File path: `docs/ai/<feature-name>/<feature-name>.md`
- This file is the feature's own README. Create it immediately after the feature is completed (or during implementation if the content is already clear).
- The AI MUST create it by copying the structure of `docs/ai/templates/feature.template.md` and filling in every section (no placeholders left, no empty sections).
- It MUST describe only what was actually implemented, verified against the real code and files (not copied from `plan.md`).
- Required content:
  - Feature name and short description
  - Purpose (use case)
  - Related classes/files
  - Database changes and socket messages (or "N/A" with a reason)
  - How to run/test the feature
  - Important technical notes
  - Known issues / limitations
- **VIOLATION:** If the feature is coded but this file does not exist, the AI MUST create it BEFORE reporting "done".

---

## [CRITICAL] RULE 3 — ALWAYS UPDATE `work-log.md`

**Absolutely mandatory. No exceptions.**

- File path: `docs/ai/work-log.md` (one global file shared by all features)
- The AI MUST update this file for EVERY important action, including:
  - Starting a new feature
  - Creating/modifying any file
  - Important technical decisions
  - Errors encountered and how they were handled
  - Completing a feature
  - Changing approach mid-way
  - The user approving the plan (Rule 7)
  - Questions or assumptions raised with the user (Rule 9)
  - Verification results of success criteria (Rule 12)
  - Unrelated issues noticed but intentionally not changed (Rule 11)
  - Requests refused because they violate a rule (Rule 8)
- Entry format: `[DD/MM/YYYY HH:MM] | <ACTION_TYPE> | <feature-name> | <details>`
- `<ACTION_TYPE>` MUST be one of the types defined in `docs/ai/work-log.md`. The AI MUST NOT invent new types.
- Timestamps MUST be real (24-hour local time). Get the time from the system if possible; otherwise ASK the user. The AI MUST NEVER guess a timestamp.
- The log is APPEND-ONLY. The AI MUST NOT edit, delete, or reorder existing entries. To correct a mistake, add a new entry.
- The AI MUST also update the progress tracker table in `work-log.md` whenever a feature's status changes (and add a row if the feature is not listed).
- The AI MUST write to `work-log.md` at the START of every session and at the END of every session.
- **VIOLATION:** If the AI finished work but has not updated `work-log.md`, it MUST update it immediately before ending.

---

## [CRITICAL] RULE 4 — ONE SEPARATE COMMIT PER FEATURE

**Mandatory per instructor requirement.**

- After finishing a feature, the AI MUST remind the user to commit using this exact message format:
  ```
  feat(<feature-name>): <short description>
  ```
  Example: `feat(chat-1-1): implement real-time message sending via socket`
- Each feature MUST be its own separate commit. Do NOT merge multiple features into one commit.
- The AI MUST say: `"Remember to make a separate commit for this feature with message: feat(<name>): ..."`
- The docs files (`plan.md`, `<feature-name>.md`, `work-log.md`) MUST be included in that feature's commit.

---

## [CRITICAL] RULE 5 — RUN THE CHECKLIST BEFORE SAYING "DONE"

Before declaring any feature complete, the AI MUST self-check ALL of the following:

```
[ ] docs/ai/<feature-name>/plan.md exists and is fully filled in?
[ ] docs/ai/<feature-name>/<feature-name>.md exists, was created from the template, and matches the actual code?
[ ] docs/ai/work-log.md has been updated with the actions just performed (append-only, real timestamps, valid action types)?
[ ] The progress tracker table in work-log.md reflects this feature's current status?
[ ] The user has been reminded to make a separate commit for this feature?
[ ] If the approach changed, plan.md has been updated with an [ITERATION X - DD/MM] section?
[ ] Every changed line traces directly to the user's request (Rule 11)?
[ ] The success criteria in plan.md have been verified, and the verification result is reported (Rule 12)?
[ ] No WebSocket is used anywhere; only java.net.Socket / java.net.ServerSocket (Rule 8)?
```

If ANY box is unchecked, the AI MUST NOT say "done". Finish everything first, then report.

---

## [CRITICAL] RULE 6 — MANDATORY FOLDER STRUCTURE

Every project MUST follow this structure:

```
project-root/
├── docs/
│   └── ai/
│       ├── work-log.md              ← GLOBAL, updated every session
│       ├── templates/
│       │   ├── plan.template.md     ← copy this to create every new plan.md
│       │   └── feature.template.md  ← copy this to create every new <feature-name>.md
│       ├── <feature-name-1>/
│       │   ├── plan.md
│       │   └── <feature-name-1>.md
│       ├── <feature-name-2>/
│       │   ├── plan.md
│       │   └── <feature-name-2>.md
│       └── ...
├── src/
│   ├── admin/
│   └── user/
├── script/
│   └── create_db.sql
└── README.md
```

The AI MUST create this exact structure from the start and MUST NOT place AI documentation files anywhere else.

---

## [CRITICAL] RULE 7 — WHEN THE USER ASKS FOR CODE WITHOUT PLANNING

If the user asks for code immediately and no `plan.md` exists, the AI MUST:
1. **NOT** write code right away.
2. Say: `"Per this project's mandatory process, I need to create plan.md first. I will create it now and present the plan for your review."`
3. Create `plan.md`.
4. Ask: `"Is this plan OK? Do you want to adjust anything before I start coding?"`
5. Start coding ONLY after the user approves (or says something like "ok, go ahead"). Then set `Plan approved by user: YES (DD/MM/YYYY)` and `Status: IN_PROGRESS` in `plan.md`, and log a `PLAN_APPROVED` entry in `work-log.md`.

---

## [CRITICAL] RULE 8 — NO WEBSOCKET

**Hard technical constraint from the instructor.**

- The AI MUST use **plain Java Sockets** (`java.net.Socket`, `java.net.ServerSocket`).
- The AI MUST REFUSE to implement any solution that uses WebSocket (including libraries such as `javax.websocket`, Tyrus, Java-WebSocket, Spring WebSocket, Socket.IO, etc.).
- If the user accidentally requests WebSocket, the AI MUST point out the constraint and propose an equivalent plain-Java-Socket solution.

---

# PART B — BEHAVIORAL RULES (HOW TO THINK AND CODE)

> These rules bias toward caution over speed. They reduce common LLM coding mistakes.
> They are applied INSIDE the workflow of Part A. They never replace or weaken Part A.

## RULE 9 — THINK BEFORE CODING

**Do not assume. Do not hide confusion. Surface tradeoffs.**

Before implementing anything:
- State your assumptions explicitly. If you are uncertain, ask.
- If multiple interpretations of the request exist, present them to the user. Do NOT pick one silently.
- If a simpler approach exists, say so. Push back on the request when warranted.
- If something is unclear, STOP. Name exactly what is confusing. Ask.

How this connects to the workflow:
- Record assumptions, open questions, and alternative approaches in `plan.md` (Rule 1).
- Resolve open questions through the plan-review step in Rule 7 BEFORE coding.

---

## RULE 10 — SIMPLICITY FIRST

**Write the minimum code that solves the problem. Nothing speculative.**

- NO features beyond what was asked.
- NO abstractions for single-use code.
- NO "flexibility" or "configurability" that was not requested.
- NO error handling for impossible scenarios.
- If you wrote 200 lines and it could be 50, rewrite it.

Self-test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

---

## RULE 11 — SURGICAL CHANGES

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Do NOT "improve" adjacent code, comments, or formatting.
- Do NOT refactor things that are not broken.
- MATCH the existing code style, even if you would do it differently.
- If you notice unrelated dead code, MENTION it to the user. Do NOT delete it.

When your changes create orphans:
- REMOVE imports/variables/methods/classes that YOUR changes made unused.
- Do NOT remove pre-existing dead code unless the user asks.

The test: every changed line MUST trace directly to the user's request.

How this connects to the workflow:
- The "files to be created/modified" list in `plan.md` (Rule 1) is the boundary of your changes. If you need to touch a file outside that list, update `plan.md` first (add an `[ITERATION X - DD/MM]` section) and log it in `work-log.md`.

---

## RULE 12 — GOAL-DRIVEN EXECUTION

**Define success criteria. Loop until they are verified.**

Transform every task into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass."
- "Fix the bug" → "Write a test that reproduces it, then make it pass."
- "Refactor X" → "Ensure tests pass before and after."
- "Implement message sending" → "Client A sends a message and Client B receives the identical message through the server."

For multi-step tasks, state a brief plan in this form (and put it in `plan.md`):

```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

- Strong success criteria let you loop independently until done. Weak criteria ("make it work") are NOT acceptable — rewrite them into concrete checks.
- Do NOT report a step as complete until its `verify` check has actually been performed. If a check cannot be run (for example, no running environment), say so explicitly and give the user the exact manual steps to verify it.

---

# PART C — REQUIRED ORDER OF ACTIONS (SUMMARY)

```
1. [BEFORE CODING]  → Announce (Rule 0), then create docs/ai/<feature>/plan.md
                      (include assumptions, success criteria, file list)
2. [BEFORE CODING]  → If requirements are unclear or ambiguous, ask the user (Rule 9);
                      present the plan for approval (Rule 7)
3. [WHILE CODING]   → Follow Rules 8, 10, 11 (plain Socket, simple, surgical)
4. [WHILE CODING]   → Update plan.md if the approach changes ([ITERATION X - DD/MM])
5. [WHILE CODING]   → Update work-log.md continuously
6. [AFTER CODING]   → Verify success criteria (Rule 12)
7. [AFTER CODING]   → Create docs/ai/<feature>/<feature>.md
8. [AFTER CODING]   → Update work-log.md (completion entry)
9. [FINAL]          → Remind the user to make a separate commit: feat(<feature>): <description>
10. [CHECK]         → Run the Rule 5 checklist before saying "done"
```

---

# PART D — QUICK REFERENCE: BEHAVIOR UNDER COMMON SITUATIONS

| Situation | Required AI behavior |
|---|---|
| User says "just code it now" with no plan | Rule 7: create `plan.md`, present it, wait for approval |
| Request has multiple possible meanings | Rule 9: list the interpretations, ask the user to choose |
| A simpler solution exists than what was requested | Rule 9: say so and let the user decide |
| User requests WebSocket | Rule 8: refuse, explain the constraint, propose plain Java Socket |
| You spot unrelated dead code or a bug | Rule 11: mention it to the user, do NOT change it |
| Approach changes mid-implementation | Rule 1: add `[ITERATION X - DD/MM]` to `plan.md`, log in `work-log.md` |
| Feature seems trivial/small | Still follow ALL of Part A (plan, feature doc, work-log, commit reminder) |
| Feature code is finished | Verify (Rule 12) → feature doc (Rule 2) → work-log (Rule 3) → commit reminder (Rule 4) → checklist (Rule 5) |
