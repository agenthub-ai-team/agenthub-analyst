# Bug Analysis: Subscription Renewal Webhook Parsing Failure

**Document Version:** 1.0
**Date:** 2026-03-28
**Status:** Ready for Technical Review

---

## Executive Summary

EU region customers are experiencing silent subscription renewal failures. The payment processor sends a Stripe webhook event, but the billing service cannot parse it because the webhook handler was recently migrated to expect the `v2` event format. The EU payment processor still sends `v1`-format payloads.

The issue is not caused by the payment processor returning bad data. The processor sends a valid `v1` event, but the billing webhook handler now assumes `v2` for all regions. The immediate fix is to make the event format configurable per region and add a graceful fallback when an unrecognized format is received.

---

## Bug Details

### Steps to Reproduce

1. Log in as a customer in the EU region with an active monthly subscription
2. Wait for the next renewal cycle (or trigger a test webhook event)
3. Observe the webhook processing log for the `invoice.payment_succeeded` event
4. Check the subscription status in the billing dashboard

### Actual Result

The webhook event is received but fails to parse. The subscription renewal is not recorded. The customer's subscription shows as "past due" even though the payment succeeded on the processor side.

### Expected Result

The webhook event should be parsed successfully regardless of format version. The subscription should be renewed and the customer should see an active status.

---

## Root Cause Analysis

### What Happened

The billing team migrated all Stripe webhook handlers to the new `v2` event format in BILL-3042. The parsing function now expects the `v2` envelope structure for all incoming events. EU region customers use a regional payment processor that still sends `v1`-format payloads.

When the parser encounters a `v1` payload, it fails silently — no error is thrown, but the event data resolves to `null`. The renewal logic skips null events, so the subscription is never updated.

### Why This Happened

The migration changed a shared billing contract, but the regional processor compatibility was not verified in the same release scope. This is a coordination gap between the webhook migration and regional payment processor readiness.

The defect is amplified by a second issue: the webhook parser does not validate or fallback when it encounters an unexpected format. Even if the format mismatch had slipped through, the system should have logged a warning and attempted `v1` parsing as a fallback.

### Evidence from Documentation

- **Jira:** `BILL-3042` — webhook migration to v2 format
- **Jira:** `BILL-2987` — EU region payment processor onboarding
- **Confluence:** `Webhook Processing Architecture` — describes format versioning strategy
- **GitHub:** `[YOUR_ORG/billing-service]/src/webhooks/resolveWebhookEvent.ts`
- **GitHub:** `[YOUR_ORG/billing-service]/src/config/regionWebhookConfig.ts`
- **Swagger:** `POST /webhooks/stripe` handler documentation

---

## Code Location & Changes Needed

### Primary Code Change Location

**File**: `/src/webhooks/resolveWebhookEvent.ts`
**Repository**: `[YOUR_ORG/billing-service]`

**What needs to change:**

Before:

```ts
const event = parseStripeEvent(payload, 'v2');
return event;
```

After:

```ts
const regionConfig = REGION_WEBHOOK_CONFIG[region] ?? {};
const format = regionConfig.eventFormat ?? 'v2';
const event = parseStripeEvent(payload, format);

if (!event) {
  logger.warn(`Webhook parse failed for region=${region} format=${format}, attempting fallback`);
  const fallbackEvent = parseStripeEvent(payload, 'v1');
  if (!fallbackEvent) {
    throw new WebhookParseError(`Cannot parse webhook for region=${region}`);
  }
  return fallbackEvent;
}

return event;
```

This keeps region-specific format preferences, introduces a fallback parser, and fails explicitly instead of silently dropping the event.

### Secondary Affected Files

- `/src/config/regionWebhookConfig.ts` — add EU region configuration with `eventFormat: 'v1'`
- `/src/webhooks/resolveWebhookEvent.spec.ts` — add regression coverage for v1 fallback and unknown formats
- `/src/subscriptions/renewSubscription.ts` — add explicit handling for null/undefined webhook events

### Affected Repositories

- `[YOUR_ORG/billing-service]`
- `[YOUR_ORG/config-service]`

### Configuration Files

- `/src/config/regionWebhookConfig.ts`
- `/infrastructure/env/eu-region.env`

---

## Historical Context & Timeline

### When Was This Implemented?

The webhook migration was implemented during the billing modernization sprint. Based on ticket references and release notes, the v2 migration landed in v2.7 and the EU region was onboarded in v2.8.

### Related Jira Tickets

- `BILL-3042` — webhook handler migration to v2 format
- `BILL-2987` — EU region payment processor integration
- `BILL-2850` — billing service modernization initiative

### Pull Requests

- PR likely associated with `BILL-3042` in billing-service for webhook migration
- PR likely associated with `BILL-2987` for EU region onboarding
- Exact PR numbers require git/PR search

### Who Introduced the Change?

Unknown from current documentation. Requires repository history lookup.

### Timeline of Events

1. Webhook processing was standardized on v2 format in billing modernization
2. EU region payment processor was onboarded with v1 format
3. EU customers started experiencing silent renewal failures
4. Customer support reports revealed subscriptions going past-due despite successful payments

---

## Developer & Ownership Information

### Who Introduced the Change?

Unknown — check git log:
```bash
git log -- src/webhooks/resolveWebhookEvent.ts
```

### Was This a Bug or Process Failure?

Both. The code bug is the missing format detection/fallback. The process failure is that a shared contract change was rolled out without compatibility verification against all regional processors.

### Teams Involved

- Billing/payments team
- Platform/infrastructure team
- QA / release coordination

### Current Ownership

Primary fix owner: **billing/payments team**. The **platform team** should support validation of regional processor compatibility.

---

## How to Find Missing Details

### To Find Exact Code Changes

```bash
cd billing-service
git log --all --grep="BILL-3042"
git log --all --grep="BILL-2987"
git log -- src/webhooks/resolveWebhookEvent.ts
git blame src/webhooks/resolveWebhookEvent.ts
```

### To Find Related Tickets

```bash
# Jira search examples
project = BILL AND text ~ "webhook"
project = BILL AND text ~ "EU region"
project = BILL AND text ~ "subscription renewal" AND created >= "2025-03-01"
```

---

## System Impact

### Affected Components

- Webhook event processing pipeline
- Subscription renewal automation
- Billing status dashboard
- Customer notification system (renewal confirmations not sent)

### User Impact

EU region customers with active subscriptions experience silent renewal failures. Their subscriptions show as "past due" even though payments succeed on the processor side. This may trigger automated downgrade or suspension flows.

### Business Impact

Direct revenue impact — subscriptions that should renew are failing to update. Customer support volume increases from users confused by incorrect billing status. Trust erosion for EU region customers.

---

## Recommended Solution

### Immediate Fix (Hotfix)

1. Add EU region to webhook config with `eventFormat: 'v1'`
2. Introduce format detection/fallback logic in the webhook parser
3. Surface explicit errors when parsing fails instead of silent null
4. Release regression tests covering multi-format webhook scenarios

### Long-Term Solution

Move webhook format compatibility into a shared contract validation step so format migrations cannot break regional processors. Add a CI check that verifies all configured regions have compatible webhook format support before deployment.

---

## Testing Requirements

- Verify webhook parsing succeeds for `v1` payloads from EU processor
- Verify existing `v2` regions still process correctly
- Verify unknown formats fail gracefully with logged warnings
- Verify subscription renewal completes after successful webhook parse
- Verify no regression for non-EU regions

---

## Dependencies

- Updated region configuration deployment for EU environments
- Billing service release with format fallback logic
- QA confirmation in staging with EU-specific webhook test data

---

## Verification Steps

1. Deploy updated billing service to staging
2. Send a test `v1` webhook event for an EU subscription
3. Confirm the event is parsed and subscription is renewed
4. Confirm `v2` events from other regions still process correctly
5. Confirm failed parsing surfaces a warning log, not silent null
6. Confirm billing dashboard shows correct subscription status

---

## CONFLICTS FOUND

- Confluence describes the webhook layer as "format-agnostic", but the implementation hardcodes v2 format
- Backend considers the migration complete once v2 handlers are deployed, but regional processors have independent upgrade timelines

---

## ANALYSIS PROCESS LOG

1. Reviewed reported symptom and isolated the EU-region-specific failure path
2. Compared expected webhook flow against current parser implementation
3. Cross-checked the failure against regional processor documentation
4. Identified the format mismatch between v2 parser and v1 processor payloads
5. Determined that missing format detection turns a compatibility gap into silent renewal failures

---

## TO CLARIFY

- What exact PR introduced the v2-only parsing in the webhook handler?
- Does any region intentionally use a format other than v1 or v2?
- Should unrecognized formats trigger a retry with fallback, or reject immediately?
- Is webhook failure telemetry already implemented, or does it need to be added as part of the fix?
