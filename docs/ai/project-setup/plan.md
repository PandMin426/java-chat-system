# PLAN — project-setup

| Field | Value |
|---|---|
| Feature name | `project-setup` |
| Created | 08/11/2026 |
| Owner(s) | Trang |
| Status | `DONE` |
| Plan approved by user | YES (08/11/2026) |

---

## 1. SUMMARY

Create the Maven multi-module skeleton that every later feature builds on: a parent POM, a `common` module holding the shared JavaFX theme, and empty-but-runnable `user` and `admin` JavaFX applications. This is the base for V1 (screens only) and for the server module added in V2. It serves the delivery rule "thư mục src: mã nguồn các màn hình của 2 phân hệ" and the agreed 3-jar architecture (K3 in the use-case spec).

---

## 2. INPUT / OUTPUT

### Input
- Agreed stack: JavaFX + PostgreSQL + plain `java.net.Socket`, 3 jars (`docs/ai/requirements-analysis/use-case-specification.md`, K1/K3)
- Design tokens: `.agent/skills/DESIGN.md` and the prototype stylesheet `../design-ui/prototype-canvas/assets/app.css`
- Installed tools: Temurin JDK 25.0.4.1, Maven 3.9.16 bundled with IntelliJ IDEA 2026.2.3

### Output / Expected result
- `mvnw.cmd -q package` builds all modules with no error
- `mvnw.cmd -pl src/user javafx:run` opens an empty "ChatApp" window styled with the shared theme; same for `src/admin` ("ChatApp — Quản trị")

---

## 3. SCOPE

### In scope
- Parent `pom.xml` with dependency/plugin versions in one place
- Maven Wrapper (`mvnw`, `mvnw.cmd`, `.mvn/wrapper/`) so Minh and the instructor do not need a Maven install
- `src/common`: `theme.css` (tokens from DESIGN.md, contrast-fixed values from the prototype)
- `src/user`, `src/admin`: one `Application` class each that opens an empty themed window
- Java entries added to `.gitignore`

### Out of scope
- Any real screen (features `ui-user-screens`, `ui-admin-screens`)
- `src/server` module, database script, socket code (later features)
- Fat-jar packaging for `release/` (V2)
- Removing the Node.js entries already in `.gitignore` (not ours, left as is)

---

## 4. ASSUMPTIONS AND OPEN QUESTIONS

| # | Type | Description | Status |
|---|---|---|---|
| 1 | ASSUMPTION | Compile with `--release 21` and JavaFX 21.0.6 (LTS) so the project also runs on machines with JDK 21–24, not only the local JDK 25 | CONFIRMED (08/11/2026) |
| 2 | ASSUMPTION | Standard Maven layout inside each module: `src/user/src/main/java/com/chatapp/user/...`. The submission's `src/` folder therefore contains `admin/`, `user/`, `common/` (and `server/` in V2) | CONFIRMED (08/11/2026) |
| 3 | ASSUMPTION | No `module-info.java` (classpath mode) — simpler, and fat jars in V2 are easier. JavaFX prints one harmless "unnamed module" warning at start | CONFIRMED (08/11/2026) |
| 4 | ASSUMPTION | Package root `com.chatapp` (`com.chatapp.common`, `com.chatapp.user`, `com.chatapp.admin`) | CONFIRMED (08/11/2026) |
| 5 | QUESTION | Which JDK version does Minh have? If lower than 21, assumption 1 must change. **Answer 08/11/2026:** above 21 — assumption 1 stands. | RESOLVED |
| 6 | QUESTION | Drive C: has 0.8 GB free and Maven downloads go to `C:\Users\hoang\.m2`. Free space on C:, or move the Maven repository to D:? **Answer 08/11/2026:** user freed space; C: now has 1.2 GB free, enough for this feature (< 200 MB of downloads). Maven repository stays on C:. | RESOLVED |

---

## 5. APPROACH

### Step 1: Parent POM and Maven Wrapper
- **Action:** Create root `pom.xml` (`com.chatapp:chat-system`, packaging `pom`, modules `src/common`, `src/user`, `src/admin`; properties `maven.compiler.release=21`, `javafx.version=21.0.6`; `dependencyManagement` for `org.openjfx:javafx-controls`, `javafx-fxml`; `pluginManagement` for `maven-compiler-plugin 3.13.0`, `maven-surefire-plugin 3.5.2`, `org.openjfx:javafx-maven-plugin 0.0.8`). Generate the wrapper with the IntelliJ-bundled Maven: `mvn -N wrapper:wrapper -Dmaven=3.9.9`.
- **Verify:** `mvnw.cmd -v` prints Maven 3.9.9 and Java 25.

### Step 2: `common` module with theme
- **Action:** `src/common/pom.xml` (jar). `src/common/src/main/resources/com/chatapp/common/theme.css`: JavaFX CSS looked-up colors on `.root` (`-c-ink: #151515`, `-c-muted: #6B6B6B`, `-c-line: #EDEDED`, `-c-subtle: #FAFAFA`, `-c-accent: #1764D8`, `-c-accent-bg: #E5F0FF`, status colors) plus base style classes used by both apps (`.btn-primary`, `.btn-secondary`, `.btn-ghost`, `.text-field`, `.h1`, `.h2`, `.muted`, `.mono`, `.badge-*`, `.card`, `.table-view`, `.tab-pane`). Fonts: `Segoe UI` for UI text and `Consolas` for identifiers/timestamps (both ship with Windows; see ui plans for the alternative).
- **Verify:** File loads with no CSS parse warning in the console when a window applies it (Step 3).

### Step 3: Runnable `user` and `admin` apps
- **Action:** `src/user/pom.xml` and `src/admin/pom.xml` (jar; depend on `common`, `javafx-controls`, `javafx-fxml`; `javafx-maven-plugin` with `mainClass`). `com.chatapp.user.UserApp` and `com.chatapp.admin.AdminApp` extend `Application`, open a 1280×800 window with an empty `BorderPane`, and attach `/com/chatapp/common/theme.css`.
- **Verify:** `mvnw.cmd -pl src/user javafx:run` and `mvnw.cmd -pl src/admin javafx:run` each open a window with the right title, no exception, no CSS warning.

### Step 4: `.gitignore`
- **Action:** Append a `# Java / Maven / IDE` section: `target/`, `*.class`, `.idea/`, `*.iml`, `.vscode/`, `!.mvn/wrapper/maven-wrapper.properties`.
- **Verify:** `git status` after a build shows no `target/` or `.idea/` entries.

### Alternatives considered
- Gradle: equally valid, but the VS Code Maven extension and IntelliJ Maven are already installed and the roadmap chose Maven.
- One single module with two `main` classes: less setup, but two jars and a later server module become messier; rejected.
- Spring Boot: not needed for V1 screens; the backend framework decision stays with the server feature.

---

## 6. FILES TO CREATE / MODIFY

| Action | File path | Description |
|---|---|---|
| CREATE | `pom.xml` | Parent POM, versions, module list |
| CREATE | `mvnw`, `mvnw.cmd`, `.mvn/wrapper/maven-wrapper.properties` | Maven Wrapper |
| CREATE | `src/common/pom.xml` | Common module |
| CREATE | `src/common/src/main/resources/com/chatapp/common/theme.css` | Shared JavaFX theme |
| CREATE | `src/user/pom.xml` | User app module |
| CREATE | `src/user/src/main/java/com/chatapp/user/UserApp.java` | User app entry point (empty window) |
| CREATE | `src/admin/pom.xml` | Admin app module |
| CREATE | `src/admin/src/main/java/com/chatapp/admin/AdminApp.java` | Admin app entry point (empty window) |
| MODIFY | `.gitignore` | Append Java/Maven/IDE section |
| CREATE | `docs/ai/project-setup/project-setup.md` | Feature description document (Rule 2) |
| MODIFY | `docs/ai/work-log.md` | Log entries and progress tracker (Rule 3) |

---

## 7. DEPENDENCIES

### Libraries / frameworks
- `org.openjfx:javafx-controls 21.0.6`, `org.openjfx:javafx-fxml 21.0.6` — GUI toolkit
- `org.openjfx:javafx-maven-plugin 0.0.8` — `javafx:run` during development
- `maven-compiler-plugin 3.13.0`, `maven-surefire-plugin 3.5.2`, Maven Wrapper (Maven 3.9.9)

### Depends on other features
- `requirements-analysis` — agreed stack and design tokens.

### Technical constraint check (Rule 8)
- [x] This feature uses only `java.net.Socket` / `java.net.ServerSocket` for networking. (N/A — no networking)
- [x] No WebSocket library or API is used.

---

## 8. RISKS

| Risk | Severity | Planned mitigation |
|---|---|---|
| Drive C: full → Maven cannot download JavaFX (~60 MB) | HIGH | Resolve question 6 before Step 1 |
| JavaFX 21 artifacts on JDK 25 print warnings | LOW | Warnings only; verified at Step 3 |
| Minh's JDK older than 21 | MEDIUM | Question 5; lower `release` if needed |

---

## 9. SUCCESS CRITERIA AND VERIFICATION

| # | Criterion (observable behavior) | How to verify | Result |
|---|---|---|---|
| 1 | Whole project builds | `mvnw.cmd -q package` exits with code 0 | PASS |
| 2 | User app window opens, themed, no exception | `mvnw.cmd -pl src/user javafx:run` | PASS |
| 3 | Admin app window opens, themed, no exception | `mvnw.cmd -pl src/admin javafx:run` | PASS (process alive, clean log; window not captured on screen) |
| 4 | Build output is ignored by git | `git status --short` after build shows no `target/` | PASS |

---

## 10. ITERATION LOG

<!-- ADD NEW ITERATIONS DIRECTLY ABOVE THIS LINE -->

---

## 11. FINAL RESULT (fill in only when the feature is DONE)

| Field | Value |
|---|---|
| Completion date | 08/11/2026 |
| Commit message to use | `feat(project-setup): add Maven multi-module JavaFX skeleton with shared theme` |
| Notes | Built as planned. JDK 25 prints harmless Maven/JavaFX native-access warnings. `install` is needed before `-pl` runs. |

---
*Feature description: [project-setup.md](./project-setup.md)*
