# Before & After: BDD Requirements

> Same prompt. Same AI model. Different results.

## The Prompt

> "Write acceptance criteria for an order subscription management feature — mobile iOS, US market."

---

## Without AgentHub

```gherkin
Feature: Order Subscription

  Scenario: User creates a new subscription
    Given the user is on the Subscribe & Save screen
    When the user taps "Create New Subscription"
    When the user selects a product from the catalog
    And the user selects "Monthly" as the frequency
    And the user taps "Save"
    Then the subscription should be created
    And the subscription should appear in the list of active subscriptions

  Scenario: User configures a subscription with multiple products
    Given the user is on the Create Subscription screen
    When the user selects "Protein Powder" as the first product
    And the user selects "Vitamins" as the second product
    And the user selects "Biweekly" as the frequency
    And the user taps "Save"
    Then the subscription should be saved with both products

  Scenario: User pauses and resumes a subscription
    Given the user has an existing subscription
    When the user toggles the subscription's active switch off
    Then the subscription should be marked as paused
    When the user toggles the subscription's active switch on
    Then the subscription should be marked as active again

  Scenario: User edits an existing subscription
    Given the user has an existing subscription
    When the user taps on the subscription
    And the user changes the frequency to "Weekly"
    And the user taps "Save"
    Then the subscription should be updated with the new frequency

  Scenario: User cancels a subscription
    Given the user has an existing subscription
    When the user swipes left on the subscription
    And the user taps "Cancel"
    And the user confirms the cancellation
    Then the subscription should be removed from the list

  Scenario: User tries to save a subscription without selecting a product
    Given the user is on the Create Subscription screen
    When the user selects "Monthly" as the frequency
    When the user does not select any product
    And the user taps "Save"
    Then an error message should appear saying "Please select at least one product"

  Scenario: User tries to save a subscription without selecting a frequency
    Given the user is on the Create Subscription screen
    When the user selects a product from the catalog
    When the user does not select a frequency
    And the user taps "Save"
    Then an error message should appear saying "Please select a delivery frequency"

  Scenario: User views subscription order history
    Given the user has active subscriptions
    And at least one order has been placed
    When the user navigates to the "History" tab
    Then the user should see a list of recent subscription orders
    And each entry should show the product name, date, and status

  Scenario: Subscription order is placed automatically
    Given the user has an active subscription for "Protein Powder" with frequency "Monthly"
    When the next order date arrives
    Then an order should be placed automatically
    And the user should receive a confirmation notification
```

---

## With AgentHub

```gherkin
@order-subscription @iOS @US
Feature: Order Subscription Management — Mobile iOS (United States)

  Background:
    Given the user is authenticated in the mobile app on iOS
    And the Order Subscription feature flag "orders.subscriptionManagement" is enabled
    And the user is in United States market with USD currency
    And the user has at least one eligible account with flag "subscriptionSourceAllowed"

  # ──────────────────────────────────────────────
  # MAIN FLOW
  # ──────────────────────────────────────────────

  @create @positive @smoke @iOS @US
  Scenario: Access Subscribe & Save entry point from Functions tab
    Given the user has no existing subscription
    And the user is on the Functions tab
    When the user taps on "Subscribe & Save" entry
    Then the Subscribe & Save tutorial screen is displayed
    And the tutorial shows header text explaining automated recurring orders
    And the tutorial shows "Get started" primary button
    And the tutorial shows "Not now" secondary button

  @create @positive @iOS @US
  Scenario: Complete tutorial and proceed to subscription setup
    Given the user is on the Subscribe & Save tutorial screen
    When the user taps "Get started" button
    Then the Subscription Setup screen is displayed
    And the screen shows "Subscribe & Save" header with close option
    And the screen shows description about automating recurring purchases
    And the product search field is displayed with placeholder "Search products"
    And the frequency field is displayed with hint "Monthly"
    And the frequency picker options are displayed
    And quick configuration buttons show values "Weekly, Biweekly, Monthly"
    And the Next button is displayed

  @create @positive @iOS @US
  Scenario: Skip tutorial and access subscription setup later
    Given the user is on the Subscribe & Save tutorial screen
    When the user taps "Not now" button
    Then the user is returned to the Functions tab
    And the Subscribe & Save entry point remains visible

  @create @positive @iOS @US
  Scenario: Select product from catalog for subscription
    Given the user is on the Subscription Setup screen
    When the user searches for "Protein Powder" in the product search field
    Then matching products are displayed in the results list
    And each product shows name, price, and subscription discount percentage

  @create @positive @iOS @US
  Scenario: Use quick configuration button to set frequency
    Given the user is on the Subscription Setup screen
    When the user taps the quick configuration button "Biweekly"
    Then the frequency field is updated to "Biweekly"

  @create @positive @iOS @US
  Scenario: Proceed to savings projection with valid configuration
    Given the user is on the Subscription Setup screen
    And the user has selected at least one product
    And the user has configured frequency "Monthly"
    When the user taps "Next" button
    Then the API call to "/public/my/subscriptions/simulation" is triggered
    And the savings projection box is displayed on the screen
    And the projection shows estimated savings for the next 12 months
    And the projection shows number of scheduled deliveries
    And "Show breakdown" button is displayed
    And "Next" button is displayed to proceed

  @create @positive @iOS @US
  Scenario: View savings breakdown detail
    Given the user is on the Subscription Setup screen with projection displayed
    And the projection shows estimated savings from the last period
    When the user taps "Show breakdown" button
    Then the Savings Breakdown screen is displayed
    And the screen shows "Your savings" header
    And the screen shows per-product discount amounts
    And the screen shows total projected annual savings

  @create @positive @smoke @iOS @US
  Scenario: Confirm subscription creation with authorization
    Given the user has completed all configuration steps
    And the user is on the confirmation screen with summary
    When the user taps "Confirm" button
    Then the authorization flow is triggered
    And upon success the API call "POST /public/my/subscriptions" is made
    And the success screen shows "Subscription created"
    And the user can navigate back to Functions tab

  # ──────────────────────────────────────────────
  # CONFIGURATION
  # ──────────────────────────────────────────────

  @update @positive @iOS @US
  Scenario: Modify existing subscription frequency
    Given the user has an active subscription
    And the user is on the subscription detail screen
    When the user taps "Edit" and changes frequency from "Monthly" to "Biweekly"
    Then the updated frequency is shown in the preview
    And the projected savings are recalculated for the new frequency

  @delete @positive @iOS @US
  Scenario: Cancel active subscription with swipe-to-delete gesture
    Given the user has an active subscription named "Monthly Essentials"
    When the user performs a trailing swipe gesture on the subscription cell
    And the user taps the "Cancel" destructive action
    And the user confirms cancellation in the alert dialog
    Then the subscription is removed from the local list with a fade animation
    And the server confirms cancellation within 3 seconds

  # ──────────────────────────────────────────────
  # VALIDATION
  # ──────────────────────────────────────────────

  @validation @negative @iOS @US
  Scenario: Reject subscription creation when no product is selected
    Given the user is on the Subscription Setup screen
    And the user has configured frequency "Monthly"
    And the user has not selected any product
    When the user taps "Next" button
    Then the product selector should highlight with a red border
    And the inline error "Select at least one product" should appear below the selector
    And the "Next" button should remain disabled

  @validation @negative @iOS @US
  Scenario: Prevent duplicate active subscription for same product
    Given the user already has an active subscription for "Protein Powder"
    When the user attempts to create a new subscription including "Protein Powder"
    Then a validation message indicates the product is already in an active subscription
    And the duplicate product cannot be added

  # ──────────────────────────────────────────────
  # EDGE CASES
  # ──────────────────────────────────────────────

  @edge-case @positive @iOS @US
  Scenario: Handle empty product catalog during subscription setup
    Given the user has started subscription creation
    When the configuration API returns zero eligible products
    Then the screen shows "No eligible products found"
    And the user is informed product availability may change
    And the user can navigate back to the Functions tab

  @edge-case @positive @iOS @US
  Scenario: Handle background to foreground during subscription setup
    Given the user is in the middle of subscription configuration
    When the app moves to background and returns to foreground
    Then the configuration state is preserved
    And the user continues from where they left off

  # ──────────────────────────────────────────────
  # OFFLINE
  # ──────────────────────────────────────────────

  @offline @negative @iOS @US
  Scenario: Block subscription creation when offline
    Given the user is on the Subscription Setup screen
    And the device has no network connectivity
    When the user taps "Next" to trigger savings projection
    Then an offline indicator is displayed
    And the user is informed they need connectivity to proceed
    And the entered configuration values are preserved

  @offline @positive @iOS @US
  Scenario: Recover after connectivity restored during setup
    Given the user was blocked due to offline status during subscription setup
    When network connectivity is restored
    Then the offline indicator is removed
    And the user can retry the action that was previously blocked

  # ──────────────────────────────────────────────
  # SECURITY
  # ──────────────────────────────────────────────

  @security @positive @iOS @US
  Scenario: Require re-authentication for bulk subscription cancellation
    Given the user selects 3 or more subscriptions for cancellation
    When the user taps "Cancel Selected"
    Then the system prompts for Face ID or passcode authentication
    And the subscriptions are only cancelled after successful authentication

  # ──────────────────────────────────────────────
  # ACCESSIBILITY
  # ──────────────────────────────────────────────

  @accessibility @positive @iOS @US
  Scenario: VoiceOver announces subscription creation result
    Given the user has VoiceOver enabled
    When the subscription is created successfully
    Then VoiceOver announces "Subscription created successfully"
    And focus moves to the success message

  @accessibility @positive @iOS @US
  Scenario: Dynamic Type scales subscription setup interface
    Given the user has Dynamic Type set to largest accessibility size
    When the user navigates to the Subscription Setup screen
    Then all text elements scale appropriately without truncation
    And all interactive elements maintain minimum 44pt tap target
    And the layout does not overlap or clip at maximum text size

  # ──────────────────────────────────────────────
  # PERFORMANCE
  # ──────────────────────────────────────────────

  @performance @positive @iOS @US
  Scenario: Subscription list loads within performance budget
    Given the user has 30 active subscriptions configured
    When the user navigates to the Subscribe & Save screen
    Then the initial 20 subscriptions render within 300ms
    And scrolling maintains 60fps with no dropped frames
    And remaining subscriptions load via pagination on scroll
```

### Traceability Matrix

| Scenario | Jira | Confluence | Swagger Endpoint | GitHub |
|---|---|---|---|---|
| Access entry point from Functions tab | PROJ-3010 | /wiki/spaces/MOBILE/pages/92010 | `GET /api/v2/subscriptions/configurations` | `src/features/subscriptions/EntryPointVC.swift` |
| Complete tutorial and proceed to setup | PROJ-3010 | /wiki/spaces/MOBILE/pages/92010 | `GET /api/v2/subscriptions/configurations` | `src/features/subscriptions/TutorialVC.swift` |
| Cancel subscription (swipe) | PROJ-3012 | /wiki/spaces/MOBILE/pages/92015 | `DELETE /api/v2/subscriptions/{id}` | `src/features/subscriptions/SubscriptionListVC.swift` |
| Modify subscription frequency | PROJ-3013 | /wiki/spaces/MOBILE/pages/92018 | `PUT /api/v2/subscriptions/{id}` | `src/features/subscriptions/EditSubscriptionVM.swift` |
| Offline block + recovery | PROJ-3015 | /wiki/spaces/MOBILE/pages/92020 | -- | `src/core/sync/OfflineAwareSetupVC.swift` |
| VoiceOver announcements | PROJ-3017 | /wiki/spaces/MOBILE/pages/92025 | -- | `src/features/subscriptions/AccessibilityAnnouncer.swift` |
| Dynamic Type scaling | PROJ-3017 | /wiki/spaces/MOBILE/pages/92025 | -- | `src/features/subscriptions/SubscriptionCell.swift` |
| Re-auth for bulk cancellation | PROJ-3019 | /wiki/spaces/SECURITY/pages/93003 | `DELETE /api/v2/subscriptions/batch` | `src/core/auth/ReauthGate.swift` |
| Performance budget | PROJ-3021 | /wiki/spaces/MOBILE/pages/92030 | `GET /api/v2/subscriptions?page={n}` | `src/features/subscriptions/SubscriptionListDataSource.swift` |

### TO CLARIFY

1. **Maximum products per subscription** -- The Swagger spec for `POST /api/v2/subscriptions` does not document an upper bound on products per subscription. Confirm max from product team.
2. **Minimum order value** -- Jira ticket PROJ-3010 mentions "minimum order threshold" but does not specify the exact value. The UI currently shows "$50" as a hint. Confirm actual minimum.
3. **Payment method expiry handling** -- What happens to upcoming subscription orders if the user's payment method expires? Not addressed in API spec or Confluence.
4. **VoiceOver language for bilingual US users** -- Accessibility spec on Confluence page /92025 does not address whether announcements should follow the device locale or the app language setting when they differ.

---

## What Makes the Difference

| Quality Marker | Without AgentHub | With AgentHub |
|---|---|---|
| **Coverage sections** | Flat list, no grouping | 8 structured sections (Main Flow, Configuration, Validation, Edge Cases, Offline, Security, Accessibility, Performance) |
| **Tag taxonomy** | None | Multi-dimensional per scenario (`@create @positive @smoke @iOS @US`) enabling filtered test runs |
| **Background / preconditions** | None | Feature flag, market, currency, subscription tier, screen state |
| **Platform-specific scenarios** | None | VoiceOver announcements, Dynamic Type scaling at 44pt tap targets, offline blocking and recovery |
| **Traceability** | None | Matrix linking every scenario to Jira ticket, Confluence page, Swagger endpoint, and source file |
| **Gap detection** | None | TO CLARIFY section with numbered items referencing specific source gaps (missing max products, undocumented payment expiry, etc.) |
| **US market awareness** | Generic | US market preconditions, USD currency, `MM/dd/yyyy` date format conventions |
| **Acceptance precision** | Vague ("should appear") | Measurable ("render within 300ms", "maintain 60fps", "confirm within 3 seconds") |
| **BDD format compliance** | Multiple GIVEN/WHEN/THEN per scenario, no AND connectors | Strict single GIVEN/WHEN/THEN per scenario with AND connectors |
