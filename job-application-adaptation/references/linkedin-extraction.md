# LinkedIn Job Posting Extraction

LinkedIn job postings require special handling due to sign-in walls.

## Technique

1. Navigate to the job URL with `browser_navigate`.
2. Dismiss any sign-in dialog that appears (look for "Dismiss" button or overlay).
3. Use `browser_snapshot` to get a partial view — it often truncates long postings.
4. For full text, use `browser_console` with:
   ```javascript
   document.querySelector('main').innerText.substring(0, 8000)
   ```
   This extracts the raw job description text from the DOM, bypassing snapshot truncation.
5. Save the extracted text as `job_listing.md` in the application folder.

## Common Dialogs

- "Sign in to see who you already know" — click "Dismiss" button (usually ref=e1 or similar)
- "Join now" / "Continue with Google" — dismiss and proceed with raw text extraction

## Alternative Sources

If LinkedIn blocks extraction entirely, ask the user to paste the job description directly. The skill workflow works with any text source — the URL is just a convenience.
