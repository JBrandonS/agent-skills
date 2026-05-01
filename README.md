# Agent Skills

**A modular suite of custom tools designed to enhance the reasoning, diagnostic, and refactoring capabilities of AI coding agents.**

These skills are optimized for integration with `opencode-codebase-index` and `serena`, providing agents with deterministic data to make higher-quality architectural decisions.

## 🚀 The Skills

### 🔍 Code Knowledge (`code-knowledge`)

Empowers agents to leverage advanced indexing. This skill bridges the gap between the agent and tools by using `opencode-codebase-index`, and `Serena`, allowing the model to perform "deep-read" operations across large repositories without blowing out the context window.

### 🧪 Code Coverage (`code-coverage`)

The Code Coverage Skill is designed to help developers analyze and improve test code coverage in a codebase using deterministic code coverage tools. By identifying gaps in test coverage and writing targeted tests, this skill aims to enhance code robustness, reduce potential bugs, and maintain high code quality standards. Code coverage metrics provide objective insight into which code paths are exercised by tests and which remain untested.

### ✂️ Deduplicate (`/deduplicate`)

The Deduplication Skill is designed to help developers identify and refactor duplicate code across a codebase. By consolidating similar code patterns into reusable components, this skill aims to improve code maintainability and reduce technical debt. Duplicate code increases maintenance burden, introduces inconsistencies, and makes it harder to implement bug fixes consistently across the application.

---

## 🛠 Prerequisites & Dependencies

To ensure full functionality, this suite relies on the following ecosystem:

* **Core Indexing:** `opencode-codebase-index` and `serena`.
* **External Tooling:** `jscpd` (Node.js) and coverage tools such as `coverage` (Python) must be installed and available in your environment.
* **External Skillsets:** This repo refrences patterns found in [Matt Pocock’s Skills](https://github.com/mattpocock/skills). Some functions may require these external skills to operate at full efficency.