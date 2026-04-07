# Feature Analysis: E-Commerce Order Management — Subscription & Auto-Reorder Implementation Options

**Document Version:** 1.0
**Date:** 2025-10-29
**Status:** Ready for Technical Review

---

## Business Requirement

Enable users to automate recurring purchases and manage subscription orders:

1. **Simulation (before creating subscription):** Show projected costs and delivery schedule based on past order history
2. **Management (after subscription is active):** Track actual spend, modify frequency, and manage items

**Scope:** Auto-Reorder and Subscribe & Save
**Additional Requirement:** Must be consumable by other microservices (not just frontend)

---

## Current State

### Subscribe & Save

**Simulation:**
- Static values returned in `GET /public/my/subscriptions/configurations`
- Response includes hardcoded `projections[]` array:
  ```json
  {
    "frequency": "MONTHLY",
    "eligibleProducts": [...],
    "projections": [
      {
        "discountTier": 1,
        "monthlySpend": {"value": 4500, "precision": 2, "currency": "USD"},
        "savings": {"value": 225, "precision": 2, "currency": "USD"},
        "annualSavings": {"value": 2700, "precision": 2, "currency": "USD"}
      }
    ]
  }
  ```
- **Decision:** Static projection values will remain in `/configurations` for marketing purposes

**Statistics:**
- No endpoint exists
- Actual subscription transactions use type: `SUBSCRIPTION_ORDER`

---

### Auto-Reorder

**Simulation:**
- Dynamic endpoint exists: `POST /public/my/subscriptions/auto-reorder/simulation`
- Request body:
  ```json
  {
    "from": "2024-12-01T00:00:00.000Z",
    "to": "2024-12-31T00:00:00.000Z",
    "minimumQuantity": 1,
    "productIds": ["a1b2c3d4-e5f6-7890-abcd-ef1234567890"]
  }
  ```
- Response:
  ```json
  {
    "numberOfOrders": 4,
    "totalSpend": {
      "value": 15000,
      "precision": 2,
      "currency": "USD"
    },
    "projectedSavings": {
      "value": 750,
      "precision": 2,
      "currency": "USD"
    },
    "from": "2024-12-01T00:00:00.000Z",
    "to": "2024-12-31T00:00:00.000Z"
  }
  ```

**Statistics:**
- No endpoint exists
- Actual auto-reorder transactions use type: `AUTO_REORDER`

---

### Backend Infrastructure

**Order Query Service:**
- `OrderHistoryLoader` fetches order data from search index
- `OrderSearchApi` provides order search with filters
- Max 2000 orders per API call
- Supports filtering by date range, product IDs, order types

**Auto-Reorder Simulation Implementation Reference:**
```java
// AutoReorderSimulationService.java
public SimulationResponse calculateSimulation(String userId, SimulationRequest request) {
    SearchCriteria search = converter.convert(userId, request);
    List<Order> orders = orderHistoryLoader.fetchOrders(userId, search);
    return orders.toSimulationResponse(request, tenantCurrency);
}
```

**Order Types:**
- Subscribe & Save: `SUBSCRIPTION_ORDER`
- Auto-Reorder: `AUTO_REORDER`

---

## Implementation Options

### **OPTION 1: Dedicated Endpoints**

Create separate, purpose-built endpoints for simulation and statistics.

#### New Endpoints

```
POST /public/my/subscriptions/subscribe-save/simulation
POST /public/my/subscriptions/subscribe-save/{id}/statistics

POST /public/my/subscriptions/auto-reorder/{id}/statistics
(Auto-Reorder simulation already exists, no changes needed)
```

#### Subscribe & Save Simulation Endpoint

**Request:**
```
POST /public/my/subscriptions/subscribe-save/simulation
```

```json
{
  "from": "2024-07-01T00:00:00.000Z",
  "to": "2024-10-29T00:00:00.000Z",
  "productIds": ["a1b2c3d4-e5f6-7890-abcd-ef1234567890"],
  "discountTier": 2
}
```

**Response:**
```json
{
  "numberOfOrders": 12,
  "totalSpend": {
    "value": 54000,
    "precision": 2,
    "currency": "USD"
  },
  "from": "2024-07-01T00:00:00.000Z",
  "to": "2024-10-29T00:00:00.000Z"
}
```

**Backend Implementation:**
- Query historical order data via `OrderHistoryLoader`
- Filter eligible orders (exclude cancelled, refunded, internal)
- For each order, calculate subscription price with discount tier
- Sum all projected costs → `totalSpend`
- Return order count for transparency

---

#### Statistics Endpoints (Both Subscribe & Save and Auto-Reorder)

**Request:**
```
POST /public/my/subscriptions/subscribe-save/{id}/statistics
POST /public/my/subscriptions/auto-reorder/{id}/statistics
```

*(No request body needed — subscription ID provided as path parameter)*

**Response:**
```json
{
  "subscriptionId": "abc-123",
  "createdAt": "2024-01-15T10:30:00Z",
  "items": [
    {
      "yearMonth": "2024-01",
      "amountSpent": {
        "value": 4500,
        "precision": 2,
        "currency": "USD"
      },
      "orderCount": 3
    },
    {
      "yearMonth": "2024-02",
      "amountSpent": {
        "value": 0,
        "precision": 2,
        "currency": "USD"
      },
      "orderCount": 0
    }
  ]
}
```

---

#### Pros & Cons

**Pros:**
- Clear separation: simulation (projected) vs statistics (actual)
- Follows existing Auto-Reorder `/simulation` pattern (consistency)
- Each endpoint optimized for its specific use case
- Easy for other microservices to consume (dedicated, predictable endpoints)
- Can evolve independently (add filters to simulation without affecting statistics)
- No breaking changes to existing APIs

**Cons:**
- 3 new endpoints to implement and maintain
- Client makes separate calls for simulation vs statistics

---

### **OPTION 2: Combined Calculation Endpoint**

Single endpoint handles both simulation and statistics based on a mode parameter.

#### New Endpoints

```
POST /public/my/subscriptions/subscribe-save/calculation
POST /public/my/subscriptions/auto-reorder/calculation
```

---

## Comparison Matrix

| Criterion | Option 1: Dedicated | Option 2: Combined |
|-----------|---------------------|-------------------|
| **API Clarity** | Very clear purpose | Mode-dependent |
| **Consistency** | Matches existing pattern | New pattern |
| **Maintainability** | Easy to evolve | Coupled logic |
| **Performance** | Optimized per use case | Conditional overhead |
| **Client Complexity** | Multiple endpoints | Single endpoint |
| **Microservice Access** | Direct, predictable | Mode parameter required |
| **Backward Compatibility** | No breaking changes | No breaking changes |
| **Caching Strategy** | Endpoint-specific | Mode-dependent |
| **Number of Endpoints** | 3 new | 2 new |

---

## Recommendation

**Option 1 (Dedicated Endpoints)** is recommended based on:

1. **Consistency:** Follows existing Auto-Reorder simulation pattern
2. **Clarity:** Each endpoint has a single, clear purpose
3. **Maintainability:** Simulation and statistics can evolve independently
4. **Performance:** Each endpoint optimized for its use case (simulation doesn't need subscription lookup)
5. **No Breaking Changes:** All existing APIs remain unchanged
6. **Microservice Consumption:** Predictable, self-documenting endpoints

However, final decision should be made collaboratively based on team preferences and long-term architectural vision.
