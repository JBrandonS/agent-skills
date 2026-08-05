# The 15 System-Test Categories

From Myers, *The Art of Software Testing*, 3rd ed., Table 6.1. Walk the whole list for every
major feature change. Most projects will dismiss several categories — dismiss them
*consciously*, in writing, so the omission is a decision rather than an oversight.

The framing for every category is the same: design the case to **show the system fails to meet
its objective**, not to show that it meets it.

---

## 1. Facility

Does every capability stated in the objectives actually exist?

Procedure: read the objectives/README sentence by sentence. Every sentence containing a *what*
("users can export to CSV", "syntax is consistent with other commands") becomes a checklist item.
Verify each against the running system.

Often needs no automation at all — a mental comparison of objectives against user documentation
catches missing features fast. Keep the checklist so the same objectives get verified next time.

**Modern form:** a `facility.spec` that asserts each advertised capability is reachable from the UI/API.

---

## 2. Volume

Abnormally large *amounts* of data, over any span of time.

- Import a 500 MB CSV; a table with 10M rows; a document with 50,000 elements
- A list endpoint whose result set exceeds one page, exactly one page, and one item over
- A file large enough to cross whatever chunking/streaming threshold exists
- Log/queue growth until rotation or backpressure engages

Expensive — every project needs a few volume tests, not many.

---

## 3. Stress

Abnormally large *loads* concentrated in a short time. Distinct from volume: volume asks whether
the typist can handle a long report, stress asks whether they can type 50 wpm.

- Target concurrency (define it from a realistic audience, not "millions")
- Target + 1, to see the behavior of the case there is nothing physically preventing
- Simultaneous arrival — all clients at once rather than spread out
- Everything at once on a constrained device: background jobs + foreground request + I/O

Applies to interactive, real-time, and request-serving systems. Not applicable to batch tools.

Stress cases representing conditions that "will never occur" are still valuable: if they surface a
defect, that defect is very likely reachable in a realistic, less extreme situation.

---

## 4. Usability

Whether a real user can actually accomplish the task. Black-box, human-facing, and it finds things
no automated suite will.

Give a real user a written list of real tasks, observe silently, and document. Sample task list
shape:

- Find record X and modify it
- Create a new record, then delete one
- Produce and export a filtered list
- Import data produced by another tool
- Customize a setting and confirm it persists

Then check the human-factor questions:

1. Is the interface consistent in syntax, conventions, semantics, format, and abbreviations?
2. Are error messages actionable, or is it "An unknown error occurred"?
3. Does every input get immediate acknowledgment (state change, spinner, confirmation)?
4. Where accuracy is vital, is there enough input redundancy to catch a wrong entry?
5. Is there an excess of options that are unlikely to ever be used?
6. Can the user always get back — up one level, to the main screen?
7. Does the design reduce user error, and are errors recoverable rather than fatal?
8. Can the user repeat the action efficiently next session?
9. Did the user feel confident, or stressed, at the end?
10. Did the software behave as its own documentation promises?

**Automatable subset:** focus lands in the right field on load, the default action is selected,
keyboard navigation reaches every control, every interactive element has an accessible name.

---

## 5. Security

Attempt to subvert the system's own security checks. Design by studying known failures in
comparable systems and asking whether this one shares them.

- Authentication bypass; session fixation; token replay after logout
- Authorization: user A requests user B's object by ID (the single most common real defect)
- Injection at every boundary: SQL, shell, template, path traversal
- Secrets in logs, error pages, client bundles, or git history
- Rate limiting on auth and on expensive endpoints
- Transport: is anything sensitive sent or stored unencrypted?

Web and e-commerce systems need markedly more of this than desktop software. Technology alone
(e.g. "we use TLS") is not evidence of safety.

---

## 6. Performance

Response time and throughput against stated objectives, under stated load and configuration.

Requires a stated objective first — "p95 under 400 ms at 50 rps". Without a number there is
nothing to test. Design the case to *show the objective is missed*.

For user-facing web flows, treat perceived latency as an objective too: time to first meaningful
paint, time until the primary action is usable.

---

## 7. Storage

Whether the system controls its own resource footprint.

- Memory ceiling under sustained use; leak across N iterations of the main loop
- Temp files and logs cleaned up; nothing grows unbounded
- Behavior when the disk is full or the quota is hit (a filled disk causes real downtime)
- Cache size bounded and evicting

---

## 8. Configuration

Every supported configuration, and the min/max of each.

- Each supported OS, runtime version, and architecture
- Each supported browser — and the same browser on different operating systems, which do not
  behave identically
- Minimum and maximum supported hardware/resources
- Optional components omitted, and the feature-flag matrix
- Default configuration with nothing set

Combinations explode; at minimum cover each dimension once plus the extremes.

---

## 9. Compatibility / Conversion

Most software replaces something, including its own previous version.

- Migration runs against a database populated by the *previous* release, not an empty one
- Rollback: does the previous version still work after the migration?
- Old file/document/export formats still open
- API versioning: old clients still succeed against the new server
- Persisted state — sessions, caches, queued jobs — survives the upgrade

Try to *generate* errors while moving data across the boundary.

---

## 10. Installation

The user's first experience. A broken install means they never reach the product.

- Clean-machine install following only the written instructions, with nothing preinstalled
- Every option combination the installer offers
- Files, directories, and permissions created correctly; required services reachable
- Network-dependent steps when the network is unavailable
- Reinstall over an existing install; uninstall leaves nothing behind

The team that built the system should ship the installation tests, to be run *after* installation.

---

## 11. Reliability

Only testable against a stated objective. High uptime targets (99.97%) cannot be verified in a test
window — but modest MTBF or defect-count objectives can.

- Soak: run the main flow for hours and watch for degradation
- Fault injection: kill a dependency mid-request; drop the connection mid-write
- Retry and idempotency: does a retried request produce one effect or two?

---

## 12. Recovery

Whether the recovery machinery works — and how fast.

- Restore from the actual backup, into a fresh environment, and verify the data
- Kill the process mid-transaction; confirm no partial write survives
- Failover to the replica, then fail back
- Corrupt/inject a bad record or a bad pointer and observe the reaction
- Measure mean time to recovery against the service-level objective, and test both its bounds

Inject faults deliberately. A recovery path that has never been executed does not work.

---

## 13. Serviceability / Maintenance

Can an operator diagnose a problem from what the system emits?

- Logs carry enough context (request ID, user, inputs) to reconstruct a failure
- Health/readiness endpoints tell the truth when a dependency is down
- Errors reaching users carry a reference an operator can trace
- Documented maintenance procedures actually work

---

## 14. Documentation

The user documentation is under test, not exempt from it.

- Every example in the README/docs is executed as a test case, verbatim
- Quickstart followed literally, on a clean machine, produces the promised result
- Documented flags, endpoints, and options exist and behave as documented
- The documentation is inspected for accuracy and clarity the way code is reviewed

Derive the *representation* of your system test cases from the documentation. This
simultaneously tests the system against its objectives and the documentation against both.

---

## 15. Procedure

Human procedures the system depends on but does not automate.

- Backup and restore runbook, executed by someone who did not write it
- Key/credential rotation
- Deploy and rollback runbook
- On-call escalation and incident procedure

If a human step is required for the system to work, it is in scope.

---

## Web/API Tier Checklist

For internet-facing applications, segment by tier so failures localize.

| Presentation tier | Business tier | Data tier |
|---|---|---|
| Rendering consistent across supported browsers | Calculations correct (tax, shipping, totals, currency) | Query performance meets objectives |
| No broken links or missing assets | Documented response-time and throughput rates met | Data stored accurately and completely |
| Correct initial focus and default action on load | Transactions complete atomically | Restore from current backup verified |
| Every interaction acknowledged to the user | **Failed transactions roll back cleanly** | Failover / redundancy exercised |
| Copy spell-checked and consistent in terminology | Input validation strong enough for security *and* accuracy | Sensitive fields encrypted at rest |
| Localization: language, timezone, currency, character sets | Data collected completely and in the right shape | Admin/back-office data routines usable and accurate |

Additional internet-specific concerns: a large and varied user base on unknown devices and
bandwidth; third-party dependencies (payment, shipping, auth) that must be tested independently
of your application before integration; a test environment that mirrors production including
network topology; graceful behavior during connectivity loss.

Third-party components get their own black-box system tests **before** integration. Do not rely on
the vendor's QA, and do not integrate an unverified component — it makes every later failure
ambiguous.

## Mobile-Specific

Interruption (incoming call, notification), background/foreground transitions, permission
grant and denial, offline and flaky-network behavior, low battery and low memory, screen sizes
and orientation, OS version matrix, install/upgrade/uninstall from the store build.
