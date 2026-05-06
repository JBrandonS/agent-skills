# TypeScript Build Troubleshooting

## TS5101: baseUrl deprecated — will break in TS 7.0

**Symptom:** `error TS5101: Option 'baseUrl' is deprecated...` during `tsc -b && vite build`.

**Cause:** TypeScript 5.9+ treats the deprecation as an error (not a warning). The `-b` flag requires `baseUrl` for path aliases to resolve, creating a conflict.

**Fix:**
1. Upgrade TypeScript to ^6.0: `npm install typescript@^6.0.0 --save-dev`
2. Add `"ignoreDeprecations": "6.0"` to `compilerOptions` in `tsconfig.json`
3. Keep `tsc -b` as-is (the compiler option works; the CLI flag `--ignoreDeprecations` conflicts with `-b`)

**Do NOT:** Remove `baseUrl` — path aliases (`paths`) require it. Without it, TypeScript can't resolve `@/*` imports even though Vite handles them at runtime.

## Dynamic component from object property in JSX

**Symptom:** `Cannot use <LEVEL_CONFIG[...].icon />` — JSX doesn't support dynamic tag names from property access.

**Fix:** Wrap in an IIFE or extract:
```tsx
{(level !== 'ALL') && (() => { const C = LEVEL_CONFIG[level as LogLevel].icon; return <C className="h-3 w-3" />; })()}
```
Or use a switch/if-else mapping for static components.

## .gitignore blocks source directories by name

**Symptom:** New source directory (e.g., `ui/src/modules/logs/`) is ignored because `.gitignore` has `logs/`.

**Fix:** Add an exception **after** the blocking rule in `.gitignore`:
```
logs/
!ui/src/modules/logs/
```
Exceptions must come after the pattern they negate.
