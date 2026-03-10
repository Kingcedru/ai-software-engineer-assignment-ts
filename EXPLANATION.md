# Bug Fix Explanation

## What was the bug?
The `HttpClient` didn't add the `Authorization` header when it received a "plain-object" token (like `{ accessToken: "...", ... }`). This made API requests fail because the token wasn't correctly processed or refreshed.

## Why did it happen?
The code was only checking for two things: if the token was missing (`null`) or if it was an *expired* `OAuth2Token` class instance. 

If the token was a simple object, the code thought everything was fine and skipped the refresh. However, when it came time to use the token, the client only knew how to read from a proper `OAuth2Token` instance. Since it had a simple object instead, it just ignored it, leaving the request without a header.

## Why does this fix solve it?
I updated the logic to be more thorough. Now, the client will refresh the token if:
```typescript
if (!this.oauth2Token || !(this.oauth2Token instanceof OAuth2Token) || this.oauth2Token.expired)
```
1.  The token is missing.
2.  The token is **not** a proper `OAuth2Token` instance (this catches the simple object case).
3.  The token has expired.

This ensures we always have a valid class instance before we try to use it.

## Edge case not covered
This fix doesn't handle **multiple requests happening at once**. If 10 requests start while the token is invalid, they will all try to refresh the token at the same time. In a real app, this would be wasteful and could cause issues with your auth server.
