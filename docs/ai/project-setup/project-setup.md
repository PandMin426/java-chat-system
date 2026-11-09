# FEATURE — project-setup

| Field | Value |
|---|---|
| Feature name | `project-setup` |
| Created | 08/11/2026 |
| Last updated | 08/11/2026 |
| Owner(s) | Trang |
| Related plan | [plan.md](./plan.md) |

---

## 1. DESCRIPTION

Maven multi-module skeleton for the chat system: a parent POM, a `common` module with the shared JavaFX theme, and two runnable JavaFX applications (`user`, `admin`) that open an empty themed window. Every later feature (screens, server, database access) builds on it.

---

## 2. PURPOSE / USE CASE

- **Actor:** Developers (Minh, Trang)
- **Trigger:** Start of V1 screen coding
- **Goal:** One command builds both subsystems; each app starts with the shared look

---

## 3. RELATED CLASSES / FILES

| Action | File path | Role |
|---|---|---|
| CREATED | `pom.xml` | Parent POM `com.chatapp:chat-system`; modules `src/common`, `src/user`, `src/admin`; `--release 21`; JavaFX 21.0.6; plugin versions |
| CREATED | `mvnw`, `mvnw.cmd`, `.mvn/wrapper/maven-wrapper.properties` | Maven Wrapper (Maven 3.9.9), generated with `mvn -N wrapper:wrapper -Dmaven=3.9.9` |
| CREATED | `src/common/pom.xml` | Common module (jar) |
| CREATED | `src/common/src/main/resources/com/chatapp/common/theme.css` | Shared JavaFX theme: looked-up colors from DESIGN.md (contrast-fixed), Segoe UI / Consolas, styles for buttons, segmented toggles, inputs, cards, notes, badges, avatars, lists, tables, tabs, scroll bars, menus, dialogs, tooltips |
| CREATED | `src/user/pom.xml` | User module; `javafx-maven-plugin` main class `com.chatapp.user.UserApp` |
| CREATED | `src/user/src/main/java/com/chatapp/user/UserApp.java` | Opens an empty 1280×800 "ChatApp" window with `theme.css` |
| CREATED | `src/admin/pom.xml` | Admin module; main class `com.chatapp.admin.AdminApp` |
| CREATED | `src/admin/src/main/java/com/chatapp/admin/AdminApp.java` | Opens an empty 1280×800 "ChatApp — Quản trị" window with `theme.css` |
| MODIFIED | `.gitignore` | Appended Java / Maven / IDE section (`target/`, `*.class`, `.idea/`, `*.iml`, `.vscode/`) |

---

## 4. DATA AND PROTOCOL

### Database changes
N/A - no database changes in this feature.

### Socket messages
N/A - no network communication in this feature.

---

## 5. HOW TO RUN / TEST

### Prerequisites
- JDK 21 or newer (tested with Temurin 25.0.4.1)
- Internet on first build (wrapper downloads Maven 3.9.9 and JavaFX into `%USERPROFILE%\.m2`)

### How to run
```powershell
cd code
.\mvnw.cmd -q install                    # build all modules once (needed before -pl runs)
.\mvnw.cmd -pl src/user javafx:run       # user app
.\mvnw.cmd -pl src/admin javafx:run      # admin app
```

### How to test

| # | Test steps | Expected result | Result |
|---|---|---|---|
| 1 | `.\mvnw.cmd -B -q package` | Exit code 0; jars in `src/*/target/`; `theme.css` inside `common-1.0.0-SNAPSHOT.jar` | PASS |
| 2 | `.\mvnw.cmd -pl src/user javafx:run` | Window "ChatApp" opens, white themed background, no exception or CSS error in output | PASS (process running after 25 s, window seen in screen capture, log clean) |
| 3 | `.\mvnw.cmd -pl src/admin javafx:run` | Window "ChatApp — Quản trị" opens, no exception or CSS error | PASS (process running after 25 s, log clean; window was behind VS Code so it is not visible in the capture) |
| 4 | `git status --short` after building | No `target/` entries | PASS |

---

## 6. TECHNICAL NOTES

- Classpath mode (no `module-info.java`). `javafx-maven-plugin` puts JavaFX on the module path for `javafx:run`. A fat-jar launcher class will be needed for `release/` in V2.
- `-pl src/user` resolves `common` from the local repository, so run `install` after changing `common`.
- On JDK 25 the output shows harmless warnings: Maven 3.9.9 (jansi native access, guava `sun.misc.Unsafe`) and JavaFX (`NativeLibLoader` native access). They do not affect the build or the apps.
- In this shell environment `NoDefaultCurrentDirectoryInExePath=1`, so the wrapper must be called as `.\mvnw.cmd`, not `mvnw.cmd`.
- Networking: none in this feature; no WebSocket used anywhere.

### Changes from the original plan
None - implemented as planned.

---

## 7. KNOWN ISSUES / LIMITATIONS

- `src/user/.gitkeep` and `src/admin/.gitkeep` are now redundant; left in place (not part of this change).
- `.gitignore` still contains the original Node.js entries; left unchanged.
- The `.agent/` entry in `.gitignore` also ignores `code/.agent/rules/rule.md`; noticed, not changed.
