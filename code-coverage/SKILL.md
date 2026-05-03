---
name: code-coverage
description: A skill for analyzing and improving test code coverage in a codebase. Use this skill when you want to identify gaps in test coverage and enhance the robustness of your codebase by writing targeted tests to cover untested code paths. This skill should be ran after adding any new feature or making significant changes to the codebase to ensure that all new and modified code is adequately tested.
---

# Code Coverage Skill

## Purpose

The Code Coverage Skill is designed to help developers analyze and improve test code coverage in a codebase using deterministic code coverage tools. By identifying gaps in test coverage and writing targeted tests, this skill aims to enhance code robustness, reduce potential bugs, and maintain high code quality standards. Code coverage metrics provide objective insight into which code paths are exercised by tests and which remain untested.

## When to Use

Use this skill when:
- Adding new features to ensure new code is tested
- Making significant changes to existing code
- Preparing code for production deployment
- Refactoring code that lacks test coverage
- Implementing bug fixes to verify the fix and prevent regressions
- Onboarding new team members to understand test expectations
- Setting team standards for minimum acceptable coverage
- Identifying risky untested code paths before they cause production issues

## Prerequisites

- **Code coverage tool** specific to your language:
  - **Python**: `coverage` (pip install coverage)
  - **JavaScript/TypeScript**: `nyc` (npm install --save-dev nyc) or Jest with --coverage
  - **Java**: `JaCoCo` (Maven/Gradle plugin)
  - **Go**: Built-in coverage support (go test -cover)
  - **C#/.NET**: `OpenCover` or built-in support
  - **Other languages**: Use appropriate language-specific tools, ask user for recommendations if unsure.
- **Test framework**: pytest, unittest, Jest, Mocha, JUnit, etc.
- **Version control**: All work should be in a version-controlled repository to track coverage improvements over time

## Workflow

**Overview**: Systematically analyze and improve code coverage:
0. Set up code coverage tools and configuration
1. Generate initial coverage report
2. Analyze coverage gaps and identify untested code
3. Write tests for uncovered code paths
4. Verify coverage improvement
5. Document coverage targets and goals
6. Maintain coverage in ongoing development

---

### 0. Set Up Code Coverage Tools and Configuration

Configure and validate code coverage tools for your project.

**Details:**

**Detailed Steps:**

1. **Install appropriate tool for your language**:
   - Python: `pip install coverage`
   - JavaScript/TypeScript: `npm install --save-dev nyc` or use Jest
   - Go: Use built-in `go test -cover`
   - Other languages: Install language-specific tool
2. **Create configuration file** (if needed):
   - Python: `.coveragerc` or `pyproject.toml`
   - JavaScript: `.nycrc` or entry in `package.json`
   - Other languages: Follow tool-specific configuration guidelines
3. **Configure tool settings**:
   - Exclude files that shouldn't be tested (vendored code, auto-generated files, etc.)
   - Set branch coverage if available (more comprehensive than line coverage)
   - Configure output formats (HTML report, XML, JSON for automation)

**Example Configurations:**

Python `.coveragerc`:
```ini
[run]
source = src/
omit =
    */site-packages/*
    */tests/*
    */migrations/*
    **/__pycache__/*

[report]
precision = 2
skip_covered = False
exclude_lines =
    pragma: no cover
    def __repr__
    raise AssertionError
    raise NotImplementedError
    if __name__ == .__main__.:
```

JavaScript `package.json`:
```json
{
  "nyc": {
    "all": true,
    "include": ["src/**"],
    "exclude": ["src/**/*.test.js", "src/**/__tests__/**"],
    "reporter": ["html", "text", "lcov"],
    "check-coverage": true,
    "lines": 80,
    "statements": 80,
    "functions": 80,
    "branches": 75
  }
}
```

### 1. Generate Initial Coverage Report

Run the code coverage tool to generate a baseline report of your codebase's current test coverage.

**Details:**

**Detailed Steps:**

1. **Run coverage tool**:
   - Python: `coverage run -m pytest` then `coverage report`
   - JavaScript (Jest): `jest --coverage`
   - JavaScript (nyc): `nyc mocha` or `nyc npm test`
   - Go: `go test -cover ./...`
2. **Generate detailed report**:
   - Most tools support HTML reports for visual inspection
   - Python: `coverage html` generates `htmlcov/index.html`
   - JavaScript: `nyc report --reporter=html` generates HTML report
3. **Capture baseline metrics**:
   - Overall coverage percentage (line, branch, function coverage)
   - Number of uncovered lines/branches
   - Uncovered code distribution (which files/modules have lowest coverage)
4. **Save or document baseline**:
   - Keep baseline report for comparison
   - Document current coverage for reference in future iterations

**Example Output Interpretation:**

```
Name                          Stmts   Miss  Cover   Missing
------------------------------------------------------------------------
src/services/user_service.py      45      8    82%   42-45, 67-69, 85
src/utils/validators.py           30      2    93%   12, 28
src/models/user.py                28      5    82%   15-17, 33, 50
------------------------------------------------------------------------
TOTAL                            103     15    85%
```

Analysis:
- Overall: 85% coverage (good baseline)
- Gaps: user_service.py has 8 uncovered statements
- Priority: Focus on user_service.py for improvement

### 2. Analyze Coverage Gaps and Identify Untested Code

Study the coverage report to identify which code paths remain untested and understand why.

**Details:**

**Detailed Steps:**

1. **Examine uncovered lines/branches**:
   - Open HTML coverage report for visual inspection (highlighted uncovered code)
   - Identify which code paths are not exercised by tests
   - Look for patterns (error handling, edge cases, specific conditions)
2. **Categorize uncovered code**:
   - **High-value**: Core business logic, frequently used code paths
   - **Edge cases**: Error conditions, boundary conditions, rare scenarios
   - **Dead code**: Code that's never executed (may be obsolete)
   - **Infrastructure**: Logging, configuration, setup/teardown code
3. **Ask questions about each gap**:
   - **Why is it untested?** (Overlooked, difficult to test, intentionally not tested?)
   - **What's the risk?** (Bug potential if this path fails?)
   - **How to test it?** (What conditions trigger this path?)
   - **What's the test complexity?** (Quick fix vs. complex setup?)
4. **Prioritize by risk and effort**:
   - Focus on high-risk, achievable-to-test code first
   - Defer dead code analysis (may require removal)
   - Accept infrastructure code with lower coverage if appropriate

**Example Analysis:**

```
File: src/services/user_service.py (82% coverage, 8 uncovered lines)

Uncovered code:
1. Line 42-45: Password reset when email not found (error case)
   Risk: HIGH - Silent failure could break user flows
   Test complexity: MEDIUM - Requires mocking email service
   Priority: HIGH

2. Line 67-69: Retry logic for database connection failures
   Risk: MEDIUM - Affects reliability but not core feature
   Test complexity: HIGH - Requires chaos engineering/mocks
   Priority: MEDIUM

3. Line 85: Logging in success path
   Risk: LOW - Non-critical logging
   Test complexity: LOW - Easy to mock
   Priority: LOW
```

### 3. Write Tests for Uncovered Code Paths

Create targeted tests that exercise the uncovered code paths identified in the previous step.

**Details:**

**Detailed Steps:**

1. **Write tests for high-priority gaps first**:
   - Start with high-risk, high-value code
   - Easier wins boost morale and coverage metrics quickly
2. **Create appropriate test fixtures**:
   - Mock external dependencies (databases, APIs, file systems)
   - Set up preconditions for the specific code path
   - Prepare expected outcomes
3. **Write test cases covering**:
   - Normal case (if not already tested)
   - Error/exception cases
   - Boundary conditions
   - Edge cases specific to this code path
4. **Verify test exercises the code**:
   - Run with coverage to confirm line is now marked as covered
   - Verify test fails if code is removed (validates test quality)

**Example Test Writing:**

Before (uncovered error case):
```python
# src/services/user_service.py
def reset_password(email: str) -> bool:
    user = User.find_by_email(email)
    if not user:  # <- Line 42-45: UNCOVERED
        logger.warning(f"Password reset attempted for non-existent email: {email}")
        return False
    # ... send email, update password
    return True
```

After (test added):
```python
# tests/test_user_service.py
def test_reset_password_email_not_found(caplog):
    """Test that password reset handles missing email gracefully."""
    with caplog.at_level(logging.WARNING):
        result = reset_password("nonexistent@example.com")
    
    assert result is False
    assert "non-existent email" in caplog.text
```

Another example (branch coverage):
```python
# Before: Missing test for retry success after failure
def fetch_with_retry(url: str, max_retries: int = 3) -> dict:
    for attempt in range(max_retries):
        try:
            return requests.get(url).json()
        except ConnectionError:
            if attempt < max_retries - 1:
                time.sleep(0.1 * (attempt + 1))
            else:
                raise

# After: Test retry success case
def test_fetch_with_retry_succeeds_after_failure(mocker):
    """Test that fetch eventually succeeds after transient failures."""
    mock_get = mocker.patch("requests.get")
    mock_get.side_effect = [
        ConnectionError("Transient failure"),
        ConnectionError("Transient failure"),
        mocker.Mock(json=lambda: {"status": "ok"})
    ]
    
    result = fetch_with_retry("http://api.example.com")
    assert result == {"status": "ok"}
    assert mock_get.call_count == 3
```

### 4. Verify Coverage Improvement

Re-run the coverage tool to confirm that new tests have increased coverage and achieved the target.

**Details:**

**Detailed Steps:**

1. **Re-run coverage analysis**:
   - Execute the same coverage command as before: `coverage run -m pytest && coverage report`
   - Generate updated HTML report for visual confirmation
2. **Compare baseline to current**:
   - Calculate improvement percentage
   - Verify specific lines/branches now marked as covered
   - Identify any remaining gaps
3. **Validate test quality**:
   - Ensure tests fail if code is modified (strong tests)
   - Verify tests don't just stub behavior but actually exercise code
   - Run tests in isolation to catch inter-test dependencies
4. **Address coverage regressions**:
   - If coverage decreased, investigate what changed
   - May indicate dead code removal or new untested code
   - Update tests or code as needed

**Example Verification:**

```
Before: 85% coverage
After:  92% coverage
Improvement: +7%

Specific improvements:
- user_service.py: 82% → 95% (error handling tests added)
- validators.py: 93% → 100% (edge case tests added)
- models.py: 82% → 82% (no new tests needed yet)
```

### 5. Document Coverage Targets and Goals

Establish and document coverage targets for your project to guide ongoing development.

**Details:**

**Detailed Steps:**

1. **Define coverage targets**:
   - Minimum acceptable overall coverage (typically 80%+)
   - Per-module or per-file targets if appropriate
   - Different targets for different code types (core vs. utils)
   - Example: "Core business logic: 95%, utilities: 80%, infrastructure: 60%"
2. **Document in project files**:
   - Add to README or contributing guidelines
   - Include in code review checklist
   - Specify in CI/CD pipeline configuration
3. **Create enforcing mechanism**:
   - Configure tool to fail if coverage drops below threshold
   - Most tools support `--fail-under` or similar flags
   - Integrate into CI pipeline to block merges with low coverage
4. **Document coverage philosophy**:
   - Why these targets were chosen
   - What's acceptable to leave untested (infrastructure, logging)
   - How to handle external service interactions

**Example Documentation:**

```markdown
## Test Coverage Standards

### Coverage Targets
- **Overall**: Minimum 85% line coverage
- **Core business logic** (src/services/, src/models/): 95%
- **Utilities** (src/utils/): 80%
- **Infrastructure** (src/config/, src/logging/): 60%

### Coverage Tool Configuration
- Tool: coverage.py with branch coverage enabled
- Configuration: See `.coveragerc`
- Run: `coverage run -m pytest && coverage report`
- Enforce: CI pipeline fails if coverage < 85%

### What We Don't Cover
- Third-party library code
- Auto-generated code (migrations, protobuf, etc.)
- Infrastructure bootstrapping code
- Logging statements (non-critical)

### Code Review Checklist
- New code includes tests
- Coverage for new code: ≥ target for that module
- No coverage regressions
- Edge cases and error paths tested
```

### 6. Maintain Coverage in Ongoing Development

Establish practices to maintain or improve coverage as development continues.

**Details:**

**Detailed Steps:**

1. **Integrate into code review process**:
   - Require coverage reports in pull requests
   - Flag PRs with coverage regressions
   - Use automated comments to highlight untested code additions
2. **Set up CI/CD checks**:
   - Run coverage on every commit
   - Block merges if coverage threshold not met
   - Generate coverage badges for visibility (e.g., README badge)
3. **Regular coverage audits**:
   - Schedule quarterly reviews of coverage metrics
   - Identify trends (improving, stagnant, declining)
   - Plan refactoring to improve coverage of complex areas
4. **Team practices**:
   - Include coverage discussion in retrospectives
   - Share coverage improvements (celebrate wins)
   - Address coverage regressions promptly (don't let debt accumulate)
5. **Handle coverage gaps thoughtfully**:
   - If code is untested, ask: "Should we test it or remove it?"
   - Dead code removal is a valid coverage "fix"
   - Document intentional gaps with `pragma: no cover` comments

**Example CI Configuration:**

```yaml
# .github/workflows/test.yml (GitHub Actions)
- name: Run tests with coverage
  run: pytest --cov=src --cov-report=xml --cov-report=html

- name: Check coverage
  run: coverage report --fail-under=85

- name: Upload coverage to service
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage.xml
```

**Example Pragma Usage:**

```python
def unsupported_feature():  # pragma: no cover
    """Not yet implemented - coverage not required."""
    raise NotImplementedError("Coming soon")

def log_debug(msg):
    if __debug__:  # pragma: no cover
        logger.debug(msg)  # Skip in optimized builds
```

## Best Practices

### DO:
- ✅ Start with critical business logic (higher coverage targets)
- ✅ Use branch coverage in addition to line coverage (more comprehensive)
- ✅ Write tests that verify behavior, not just code execution
- ✅ Treat low coverage as a red flag (investigate why)
- ✅ Exclude truly untestable code (generated, third-party, infrastructure)
- ✅ Make coverage part of CI/CD pipeline (enforced, not optional)
- ✅ Celebrate coverage improvements (team morale)
- ✅ Refactor difficult-to-test code to make it testable
- ✅ Review coverage reports visually (HTML reports reveal patterns)
- ✅ Set realistic targets based on project type and resources

### DON'T:
- ❌ Chase 100% coverage obsessively (diminishing returns)
- ❌ Write bad tests just to increase coverage (coverage ≠ quality)
- ❌ Test trivial code (getters, setters, auto-generated methods)
- ❌ Coverage-bomb: adding many weak tests instead of few strong ones
- ❌ Leave coverage gaps without explanation or documentation
- ❌ Ignore coverage regressions (debt accumulates)
- ❌ Trust coverage reports without reading the actual code
- ❌ Over-test infrastructure code (logging, configuration)
- ❌ Test implementation details instead of behavior
- ❌ Ignore hard-to-test code (refactor instead of ignoring)

## Troubleshooting

### Issue: Coverage tool reports false negatives (code marked uncovered but actually tested)

**Solution:**
- Verify test is actually being run: Add deliberate failure to test to confirm execution
- Check that coverage tool is analyzing correct files (verify `source` configuration)
- Ensure test doesn't exit early or skip the code path
- Some dynamic code (imports, reflection) may not be detected; consider ignoring or refactoring
- Check for multi-process test execution (coverage.py needs special configuration for multiprocessing)

### Issue: Tests pass but coverage report shows 0% coverage

**Solution:**
- Verify coverage tool is configured correctly in project
- Check that source files are in configured `source` or `include` paths
- Run coverage tool directly, not through test runner (some runners override config)
- Ensure tests are running: coverage only tracks executed code
- Check for Python bytecode cache issues: `python -B` or delete `__pycache__`

### Issue: Coverage is low because of unreachable error handling (try/except blocks)

**Solution:**
- Consider whether error is truly unreachable or just rare
- Add tests that trigger the error condition (mock failures, test edge cases)
- If error truly unreachable, either remove code or add `pragma: no cover`
- Sometimes restructuring code (dependency injection, better error propagation) makes testing possible
- Document why error handling is intentionally not covered

### Issue: Coverage drops after refactoring, even though tests pass

**Solution:**
- Review new code introduced in refactoring
- Coverage may have improved readability but added paths (expected)
- Verify refactoring didn't introduce dead code
- Add tests for any new conditionals or error paths
- Sometimes coverage drops temporarily before new tests are written

## Related Skills

- **code-knowledge**: Use to understand code structure and identify areas lacking tests. Index will need to be updated and retrained after adding tests to reflect the new structure of the codebase, and to ensure that future searches return accurate results. Be sure to load have this in context before starting.
- **deduplicate**: Use to identify and refactor duplicate code, which can improve testability and reduce the amount of code that needs to be covered by tests.
- **tdd**: Use when writing tests alongside code (red-green-refactor)
- **diagnose**: Use when identifying why code is untested or difficult to test
- **improve-codebase-architecture**: Use to refactor hard-to-test code into more testable patterns

