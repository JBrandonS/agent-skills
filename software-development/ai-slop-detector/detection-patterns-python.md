# Python AI Slop Detection Patterns

Run each with: `ast_grep_search --lang python -p '<pattern>'`

## Over-Commenting / Echo Comments

```python
def $FUNC($$$):
    """$DOC"""
    return $$$
```
Simple functions with docstrings that likely echo what's obvious from the code.

## Empty Stub Patterns

```python
def $FUNC($$$): pass
```
Function body is just `pass` — placeholder stubs AI often leaves behind.

```python
return None
```
Top-level return in a function without any real logic (standalone, not inside a branch).

```python
= NotImplemented
```
Using `NotImplemented` sentinel — common AI placeholder.

## Unnecessary Async

```python
async def $FUNC($$$):
    $$$
```
Match all async functions, then manually check for absence of `await` in body.

## Generic Variable Names (Python)

```python
def $FUNC(data: $T, result=$$$):
    pass
```
Functions with generic parameter names like `data`, `result`.

```python
def $FUNC(temp=$$$):
    pass
```
Generic `temp` as function parameter.

## Happy Path Bias (Python)

```python
try:
    $$$
except $E:
    print($$$)
```
Generic catch-all except that just prints — no meaningful error handling.

```python
try:
    $$$
except Exception:
    pass
```
Silent exception swallowing — AI's default error handling.

## Excessive Validation (Python)

```python
def $FUNC($$$):
    if not isinstance($$$, $$$):
        raise TypeError(...)
    if $$$ is None:
        raise ValueError(...)
    if not $$$:
        raise ValueError(...)
```
Multiple validation checks at function entry — AI's default "robustness" pattern.

## Over-Engineered Error Handling (Python)

```python
try:
    try:
        try:
            $$$
        except $$$:
            pass
    except $$$:
        pass
except $$$:
    pass
```
4+ nested try/except blocks — over-engineered error handling.

## Unused Imports (Python)

Check with: `pyflakes $FILE` or manually review imports for symbols never used in body.

## Placeholder Naming (Python)

```python
$NAME = placeholder
```
Variables named `placeholder`, `dummy`, `stub` — AI leaves these when unsure about implementation.
