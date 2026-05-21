# JavaScript/TypeScript AI Slop Detection Patterns

Run each with: `ast_grep_search --lang typescript -p '<pattern>'` or `--lang javascript`

## Generic Variable Names (TS/JS)

```typescript
let data: any;
const result = $$$;
```
Generic variable names — scan files for high frequency.

```typescript
const [data, setData] = useState(null);
```
AI's default useState pattern with `data`/`setData`.

## Empty / Generic Catch Blocks

```typescript
} catch ($ERR) { console.log($ERR); }
```
Generic catch that just logs — no meaningful error handling.

```typescript
} catch ($$$) { }
```
Silent catch — AI's default error swallowing pattern.

```typescript
.catch(() => {})
```
Empty promise error handler.

## Unnecessary Async (JS/TS)

```typescript
async function $FUNC($$$): $$$
```
Match all async functions, check body for absence of `await`.

```typescript
const $NAME = async ($$$): $$$
```
Arrow function async without await in body.

## Over-Engineered Error Handling (JS/TS)

```typescript
try {
    try {
        try {
            $$$
        } catch ($$$) { $$$ }
    } catch ($$$) { $$$ }
} catch ($$$) { $$$ }
```
3+ nested try/catch — over-engineered error handling.

## Excessive Parameter Validation (JS/TS)

```typescript
if (!$$$) throw new Error('...');
if (!$$$.property) throw new Error('...');
```
Multiple nullish checks with thrown errors at function entry.

## Missing Promise Error Handling (JS/TS)

```typescript
await $$$
```
Match all await expressions that lack surrounding try/catch or .catch() — AI often forgets error handling around async calls.

```typescript
fetch($$$)
    .then($$RES => $$$\n$$$.json())
```
Promise chain without `.catch()` — missing error handler.

## Hallucinated Method Calls (JS/TS)

Check for these common hallucinations manually or with grep:
- `Array.prototype.flatten()` → doesn't exist in older Node versions
- `Object.hasOwn($$$)` → only in Node 16+
- `.toJSON()` on custom types when it shouldn't be used
- Non-existent method chains like `$obj.deep.nested.method().then().finally().json()`

## Perfect Consistency Patterns (JS/TS)

These require manual review but are strong signals:
```typescript
interface $NAMEProps {
    prop1: string;
    prop2: string;
    prop3: string;
}
```
Perfectly alphabetically ordered object properties — AI tends to sort everything.

## Placeholder Comments (JS/TS)

```typescript
// TODO: implement
// FIXME: 
// HACK:
/// <reference path=.../>
```
AI often leaves TODOs, FIXMEs, and placeholder comments.

## Over-Engineered Components (React/TSX)

```tsx
export const $NAME = React.memo(React.forwardRef(($$$)) => {
    const [state1, setState1] = useState($$$);
    const [state2, setState2] = useState($$$);
    // ... many hooks and abstractions
});
```
Component with excessive state management for simple rendering — over-engineering signal.

## Excessive Default Props / TypeScript Defaults

```typescript
const $NAME: $TYPE = {
    prop1: 'default value',
    prop2: 'another default',
    prop3: 'yet another',
};
```
Objects with defaults for every property — AI over-defends against null.
