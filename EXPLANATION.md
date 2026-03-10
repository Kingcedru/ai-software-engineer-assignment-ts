# Bug Fix Explanation

## What was the bug?
The `HttpClient` failed to refresh the OAuth2 token when `oauth2Token` was set to a plain object (e.g., `{ accessToken: "...", expiresAt: ... }`) instead of a proper `OAuth2Token` class instance. This caused the `Authorization` header to be missing even when a "token" (albeit the wrong type) was present.

## Why did it happen?
The original refresh condition was:
```typescript
if (!this.oauth2Token || (this.oauth2Token instanceof OAuth2Token && this.oauth2Token.expired))
```
If `oauth2Token` was a plain object, `!this.oauth2Token` was false, and `this.oauth2Token instanceof OAuth2Token` was also false. Thus, the refresh logic was skipped, but the subsequent header injection also failed because it specifically looked for an `instanceof OAuth2Token`.

## Why does your fix solve it?
The fix updates the condition to:
```typescript
if (!this.oauth2Token || !(this.oauth2Token instanceof OAuth2Token) || this.oauth2Token.expired)
```
This ensures a refresh is triggered if:
1. The token is missing (`null`/`undefined`).
2. The token is NOT an instance of `OAuth2Token` (handling plain objects).
3. The token IS an instance but has expired.

## Edge case not covered
The current implementation doesn't handle **concurrent requests**. If multiple requests are made while the token is null or invalid, each will call `refreshOAuth2()` independently, potentially resulting in multiple token network calls (if `refreshOAuth2` were real) and unnecessary overhead.
