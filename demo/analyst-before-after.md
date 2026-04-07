# Before & After: Bug Investigation

> Same prompt. Same AI model. Different results.

## The Prompt

> "Users in the DACH region are seeing a blank page when they click a promoted product. Investigate."

---

## Without AgentHub

### Investigating Blank Page on Promoted Product Click (DACH Region)

This issue likely stems from one of several common causes when region-specific rendering fails silently. Below is a breakdown of the most probable root causes and suggested debugging steps.

#### Possible Causes

**1. Localization or Internationalization Mismatch**
The DACH region (Germany, Austria, Switzerland) uses specific locale conventions -- comma as decimal separator, different date formats, and region-specific currency formatting. If the promotion rendering layer expects a US/UK-style decimal format and receives `1.499,00` instead of `1,499.00`, the parser may throw an unhandled exception, resulting in a blank page rather than a visible error.

**2. CDN or Caching Layer Serving Stale Content**
If a recent deployment updated the promotion display component but the CDN edge nodes serving DACH countries have not been invalidated, users could be receiving a cached bundle that references DOM elements or API response shapes that no longer exist. This would cause the component to mount and then silently fail during hydration.

**3. API Timeout or Region-Specific Gateway Issue**
The product detail API may route through a region-specific gateway for DACH users. If that gateway has elevated latency or is returning 5xx errors, the frontend component may be hitting an unhandled timeout. Without a proper loading or error state, this would render as a blank page.

**4. Rendering Error in Promoted Product Component**
Promoted products often use a different rendering path than standard product cards -- they may pull from a separate content management source or require additional data fields like promotional pricing, badge text, or campaign metadata. If any of these fields are null or formatted unexpectedly for DACH locales, a rendering error in React (or similar framework) would unmount the component tree, leaving a blank container.

**5. Feature Flag or A/B Test Misconfiguration**
If there is a feature flag system in place, DACH users may have been inadvertently placed in a test cohort that activates a code path with a bug. This is especially common when regional rollouts are gated by country code.

#### Suggested Debugging Steps

- Check browser console errors on a DACH-region account or via VPN to replicate the issue.
- Review the promotion rendering component for unhandled exceptions, particularly around data formatting and null checks.
- Inspect CDN cache headers for the DACH region edge nodes to verify the deployed bundle version.
- Check the product detail API response for promoted items when the request includes DACH locale headers.
- Review recent deployments and feature flag changes that may have targeted DACH countries.
- Look at application monitoring dashboards (Datadog, Sentry, etc.) filtered by region to see if error rates have spiked.

This is most likely a data formatting issue in the promotion renderer, but the CDN and feature flag angles should be ruled out early since they are quick to verify.

---

## With AgentHub

### Executive Summary

Users in the DACH region (DE, AT, CH) encounter a blank page when navigating to a promoted product. The root cause is a crash in the promotion rendering component (`renderPromotedProduct.tsx`) which calls `parseFloat()` on a pricing string that uses the DACH decimal comma format (`1.499,00`). The function returns `NaN`, the downstream price display component receives an invalid prop, and React's error boundary unmounts the entire product view. The defect was introduced in sprint 34 when promotional pricing was refactored to use raw price strings instead of pre-parsed numeric values.

### Root Cause Analysis

**What Happened:** The `formatPromotionalPrice()` function in `renderPromotedProduct.tsx` parses the `rawPrice` field using JavaScript's native `parseFloat()`, which does not handle European decimal comma notation. For DACH locales, the pricing service returns `"1.499,00"` -- `parseFloat()` produces `NaN`, which propagates into the `<PriceDisplay>` component and triggers an unhandled render error.

**Why This Happened:** The pricing refactor in DASH-2750 replaced pre-formatted price objects with raw string values to support a new discount calculation feature. The original implementation used `Intl.NumberFormat` for locale-aware parsing. The refactored version assumed all prices would arrive in `en-US` format, which holds for all regions except DACH, where the pricing microservice respects the `Accept-Language` header and returns locale-formatted strings.

### Evidence

| Source | Finding |
|---|---|
| **Jira DASH-2891** | Bug report: "Blank page on promoted product click -- DACH region only." Logged by QA on 2026-03-28. Affects DE, AT, CH locales. |
| **Jira DASH-2750** | Story: "Refactor promotional pricing to use raw price strings." Merged in sprint 34. Changed `formatPromotionalPrice()` to call `parseFloat()` directly. |
| **GitHub** `src/promotions/renderPromotedProduct.tsx` | Line 47: `const price = parseFloat(rawPrice)` -- no locale-aware parsing. No guard against `NaN`. |
| **Confluence** "Product Display Architecture" | Documents the promotion renderer as "region-agnostic" and states all pricing goes through `Intl.NumberFormat` before display. This no longer matches the implementation after DASH-2750. |
| **Swagger** `GET /api/v2/promotions/{id}` | Response schema shows `rawPrice` as `string` type. No format constraint documented. Actual responses vary by `Accept-Language` header. |
| **GitHub** `src/promotions/__tests__/renderPromotedProduct.test.ts` | All test fixtures use `en-US` formatted prices (`"1499.00"`). No test case for DACH locale format. |

### Conflicts Found

1. **Confluence vs. Implementation** -- The "Product Display Architecture" page describes the promotion renderer as region-agnostic and specifies that all pricing passes through `Intl.NumberFormat` for locale handling. The current implementation in `renderPromotedProduct.tsx` bypasses this entirely and calls `parseFloat()` on the raw string. The documentation was not updated after DASH-2750 was merged.

2. **Swagger vs. Runtime Behavior** -- The API specification for `GET /api/v2/promotions/{id}` documents `rawPrice` as a plain `string` with no format annotation. In practice, the pricing microservice formats the value according to the request's `Accept-Language` header, meaning the response format is locale-dependent -- a behavior not captured in the contract.

### To Clarify

1. **Rollback scope** -- DASH-2750 also changed discount calculation logic. Confirm with the pricing team whether reverting `formatPromotionalPrice()` to use `Intl.NumberFormat` would break the new discount feature (no test coverage found for that path).
2. **Other affected locales** -- The pricing microservice may return locale-formatted strings for non-DACH European locales (FR, IT, ES) that also use decimal commas. No bug reports exist for those regions yet, but no test coverage exists either.
3. **Error boundary gap** -- The blank page indicates the error boundary at the product view level is not rendering a fallback UI. Confirm whether this is a missing boundary or a boundary that itself fails on the `NaN` prop.
4. **Monitoring blind spot** -- No Sentry alerts were triggered for this crash. Verify whether client-side error reporting is configured for the promotions module or if it was excluded during the sprint 32 Sentry scope reduction (referenced in DASH-2680).

---

## What Makes the Difference

| Quality Marker | Without AgentHub | With AgentHub |
|---|---|---|
| **Root cause** | 5 plausible guesses, no conclusion | Single confirmed cause, traced to a specific line of code and the sprint that introduced it |
| **Evidence** | None -- no tickets, no file paths, no references | 6 cross-referenced sources: Jira, GitHub, Confluence, Swagger |
| **Contradictions surfaced** | Not detected | 2 conflicts found between documentation and implementation |
| **Open questions** | Generic debugging checklist | 4 targeted questions tied to specific gaps in source material |
| **Actionability** | Developer must still investigate from scratch | Developer can go directly to the file, line, and fix |
