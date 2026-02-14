# PROMPT.md — Per-Iteration Agent Instructions

> This file is read by the agent at the start of each Ralph loop iteration.
> It complements AGENTS.md (project policy) with iteration-specific behavior.

---

## Context

You are running inside an autonomous loop. Each iteration:

1. You receive ONE story from prd.json to implement.
2. You have a fresh context window — no memory of previous iterations.
3. Your only memory is: jj history, progress.txt, and prd.json status.

**Read progress.txt first.** It tells you what previous iterations accomplished
and any decisions or gotchas they discovered. This saves you from re-exploring
the entire codebase.

**Read `.agents/skills/swift6/SKILL.md` before writing Swift code.** This
documents Swift 6 concurrency patterns, Swift Testing syntax, and common
pitfalls specific to this project.

---

## Iteration Protocol

### Phase 1: Orient (do this before writing any code)

1. **Read context files**:
   ```bash
   cat progress.txt | tail -30        # Recent iteration summaries
   cat .agents/skills/swift6/SKILL.md # Swift 6 patterns
   ```

2. **Understand your assignment**:
   ```bash
   # Read your assigned story
   jq '.stories[] | select(.id == "S##")' prd.json
   ```
   
3. **Check repository state**:
   ```bash
   jj log --limit 10                  # Recent commits
   jj st                              # Working copy status
   ls Sources/ApplSpeech/              # Current structure
   ```

4. **Review relevant code**:
   - Check Package.swift for dependencies
   - Examine existing modules you'll interact with
   - Review existing tests to understand patterns
   - Verify .swift-format config if making new files
   - **Read AGENTS.md §12 (Discovered Patterns)** — learn from prior iterations

5. **Verify you can build and test**:
   ```bash
   swift build                        # Should succeed before you start
   swift test                         # Baseline: all tests pass
   ```

### Phase 2: Plan

Write your TCR cycle plan before touching any code. Break the story into
atomic changes, each of which can be tested independently.

**Example plan for S05-transcribe-file**:
```
TCR Plan:
  1. Add SFSpeechRecognizer wrapper — build succeeds
  2. Implement basic file loading from URL — test file access
  3. Add TranscriptionRequest struct — test request building
  4. Add Transcriber.transcribeFile() — test full transcription
  5. Wire command into CLI — integration test
  6. Add tests for all error paths — verify coverage
```

Each step should:
- Be < 50 lines of code
- Have a clear test or verification
- Leave the codebase in a working state

### Phase 3: Implement (TCR Loop)

For each step in your plan:

```bash
# 1. Describe what you're doing
jj desc -m "feat(transcribe): add file loading"

# 2. Make the change (edit one or two files)

# 3. Verify
swift build
swift test

# 4. Decide:
# ✅ Both pass → commit and move to next step
jj new

# ❌ Either fails → revert and try smaller change
jj restore
```

**TCR Discipline**:
- If `swift build` fails: your change broke compilation → revert
- If `swift test` fails: you broke existing behavior → revert
- Don't "fix forward" — revert and make a smaller change
- Never commit code that doesn't build or pass tests

### Phase 4: Verify Story Completion

Before marking the story done, run the full verification suite:

```bash
# Type checking
swift build

# Release build (optimizations may catch issues)
swift build -c release

# All tests
swift test --verbose

# Code style (if swift-format available)
swift format lint --recursive Sources/ Tests/
```

**ALL must pass.** If any fails, fix it before completing the story.

### Phase 5: Extract & Document Discoveries (COMPOUNDING STEP)

**This step is critical. Do not skip it.**

Before marking the story complete, explicitly ask yourself:

1. **Did I encounter any gotchas?** (API quirks, unexpected errors, edge cases)
2. **Did I learn anything about the Speech framework?**
3. **Did I discover any patterns that future iterations should know?**
4. **Were there any workarounds I needed?**

If you discovered ANYTHING worth documenting:

1. **Append to AGENTS.md §12 (Discovered Patterns)**:
   - Add a clear, actionable entry
   - Include code examples if helpful
   
2. **Commit the AGENTS.md update separately:**
   ```bash
   jj desc -m "docs(agents): add discovered pattern for <topic>"
   jj new
   ```

This is how the project compounds knowledge over iterations. Future agents
will read §12 and avoid repeating your mistakes.

### Phase 6: Complete

1. **Update prd.json**: Set your story's `"passes"` to `true`

2. **Append to progress.txt**:
   ```
   ## Iteration N — S##-story-id — Story Title
   Date: YYYY-MM-DDTHH:MM:SSZ
   - Brief summary of what was implemented
   - Key technical decisions
   - Files added/modified
   - Gotchas discovered
   - Test coverage notes
   - Patterns added to AGENTS.md §12 (if any)
   ```

3. **Commit tracking files**:
   ```bash
   jj desc -m "chore(ralph): complete story S##-story-id"
   jj new
   ```

---

## Rules

### Story Scope
- **One story per iteration.** Never work on unassigned stories.
- **Finish completely.** All acceptance criteria must be met.
- **No partial work.** Either complete the story or don't commit tracking files.

### Code Quality
- **TCR is mandatory.** No large uncommitted changes.
- **No stubs.** No TODO comments, no placeholder functions.
- **No skipping tests.** New code = new tests.
- **Security first.** Follow AGENTS.md §7 security/privacy guidelines.
- **Swift 6 patterns.** Use Sendable, strict concurrency, value types.

### Testing
- **Use Swift Testing.** `@Test` macros, not XCTest.
- **Test error paths.** Don't just test the happy path.
- **Test edge cases.** Empty strings, nil values, boundary conditions.
- **Verify test output.** Use `swift test --verbose` to check messages.

### Documentation
- **Document public APIs.** Use `///` comments with parameters and examples.
- **Update README.** If you add user-facing features, document them.
- **Keep progress.txt concise.** Future iterations read it for context.

---

## Common Workflows

### Starting Work
```bash
# 1. Read context
cat progress.txt | tail -30

# 2. Read discovered patterns
cat AGENTS.md | grep -A100 "## §12"

# 3. Get your assignment
export STORY_ID=$(jq -r '.stories[] | select(.passes == false) | .id' prd.json | head -1)
jq ".stories[] | select(.id == \"$STORY_ID\")" prd.json

# 4. Create first commit
jj new -m "feat(scope): start $STORY_ID"
```

### During Implementation
```bash
# Make small change
jj desc -m "feat(transcribe): add recognizer wrapper"

# Verify
swift build && swift test

# Commit or revert
swift test && jj new || jj restore
```

### Completing Story
```bash
# Final verification
swift build -c release && swift test --verbose

# === CRITICAL: Check for discoveries ===
# Did you discover anything? Update AGENTS.md §12 if yes

# Update tracking
jq '.stories[] |= if .id == "S##" then .passes = true else . end' prd.json > tmp.json && mv tmp.json prd.json

# Append to progress.txt (use your editor)

# Commit
jj desc -m "chore(ralph): complete story S##-story-id"
jj new
```

---

## Swift 6 Quick Reference

### Testing Patterns
```swift
import Testing
@testable import ApplSpeech

@Suite("Module Tests")
struct ModuleTests {
  
  @Test("Description of what's tested")
  func testSomething() {
    #expect(value == expectedValue)
  }
  
  @Test("Parameterized test", arguments: [1, 2, 3])
  func testWithParams(input: Int) {
    #expect(input > 0)
  }
  
  @Test("Error handling")
  func testError() throws {
    #expect(throws: SomeError.self) {
      try functionThatThrows()
    }
  }
}
```

### Sendable Types
```swift
// Value types are automatically Sendable if all properties are Sendable
struct TranscriptionResult: Sendable {
  let text: String
  let confidence: Double
}

// Enums with Sendable cases are Sendable
enum TranscriptionError: Error, Sendable {
  case audioFileNotFound
  case recognitionFailed
}
```

### Async Transcription
```swift
func transcribe(url: URL) async throws -> String {
  let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
  let request = SFSpeechURLRecognitionRequest(url: url)
  request.requiresOnDeviceRecognition = true
  
  return try await withCheckedThrowingContinuation { continuation in
    recognizer?.recognitionTask(with: request) { result, error in
      if let error = error {
        continuation.resume(throwing: error)
        return
      }
      guard let result = result, result.isFinal else { return }
      continuation.resume(returning: result.bestTranscription.formattedString)
    }
  }
}
```

---

## Debugging TCR Failures

### Build Fails
```bash
swift build 2>&1 | less  # Read full error output
```
Common causes:
- Missing import statement
- Type mismatch (Swift 6 is strict)
- Sendable conformance violation
- File not added to Package.swift targets

### Tests Fail
```bash
swift test --verbose     # See which test failed and why
```
Common causes:
- Test expectation wrong
- Changed behavior of existing function
- Missing test cleanup
- Async test not awaited

### Both Pass But Feature Broken
You probably didn't write enough tests. Add integration test before marking story complete.

---

## Communication Style

Be direct. No preamble. Examples:

❌ **Too verbose**: "Great! I'll start by reading the progress file to understand what's been done so far, then I'll examine the story requirements..."

✅ **Correct**: "Reading progress.txt and story S05..."

❌ **Too chatty**: "Let me first understand the codebase structure and then we can begin implementing the feature in small TCR cycles..."

✅ **Correct**: "TCR Plan for S05: 1. Add struct, 2. Test input, 3. Wire to manager..."

**IMPORTANT REMINDER**: After completing the story, don't forget Phase 5 — extract and document any discoveries to AGENTS.md §12!

Just: **Orient → Plan → Execute → Verify → Extract Discoveries → Complete**.
