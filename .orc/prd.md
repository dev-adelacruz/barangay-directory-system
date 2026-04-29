---
approved: true
approved_at: 2026-04-25T00:00:00Z
orc_phase: 1
---

# Barangay Resident & Evacuation Management System — PRD v1.0

**Date:** 2026-04-25
**Repo:** dev-adelacruz/barangay-directory-system

---

## 1. Executive Summary

**Product Name:** Barangay Resident & Evacuation Management System (BREMS)

BREMS is a web-based disaster preparedness and evacuation management platform built for Philippine local government units, specifically barangay-level officials in typhoon-prone municipalities. The system enables barangay officials in municipalities like those in Catanduanes to maintain a complete household and resident registry with geolocation data, activate and monitor evacuation operations in real time, and coordinate relief efforts — all from a single unified dashboard.

**Business Problem:** Catanduanes is one of the most typhoon-exposed provinces in the Philippines, yet barangay officials currently manage evacuations using paper logbooks, verbal coordination, and ad-hoc spreadsheets. This results in missed evacuations for vulnerable residents (PWDs, elderly, infants), inability to track real-time capacity at evacuation centers, and poor post-disaster reporting for DRRMO and NDRRMC compliance.

**Target Users:** Barangay Captains, Barangay Kagawads/Staff, Municipal DRRMO Officers

**High-Level Goals:**
- Digitize and centralize the household and resident registry for all barangays in the municipality
- Enable real-time evacuation tracking and coordination during typhoon events
- Improve visibility of high-risk populations (PWD, elderly, pregnant, infants)
- Generate compliant post-disaster reports for DRRMO and NDRRMC

---

## 2. Problem Statement

**Current Pain Points:**
- Barangay officials have no reliable, up-to-date list of households and their locations during emergencies
- Vulnerable residents (PWDs, elderly, infants, pregnant) are not systematically flagged, leading to missed evacuations
- Evacuation center capacity is tracked verbally or not at all — centers fill up without officials knowing
- Post-disaster reporting to DRRMO and NDRRMC relies on manual tally sheets compiled after the fact
- Paper records are destroyed during typhoons, making post-disaster reconciliation nearly impossible
- No cross-barangay visibility means the municipal DRRMO officer cannot get a real-time situation picture

**Who Is Affected:** Barangay officials managing evacuations under extreme time pressure; vulnerable residents who depend on proactive evacuation; municipal DRRMO officers responsible for coordinating response across barangays

**Why Now:** Catanduanes experiences multiple typhoon landfalls per year. Each event without a digital system is a repeat of the same coordination failures. Post-pandemic, mobile device penetration has increased significantly even in rural municipalities, making a mobile-responsive web app viable even for field use.

---

## 3. User Personas

### Persona 1: Captain Nestor — Barangay Captain (Administrator)
- **Goals:** Know exactly how many residents are still at home during a typhoon; activate evacuation protocols quickly; see which evacuation centers still have capacity
- **Pain Points:** Relies on kagawads calling him by phone; doesn't know if vulnerable residents have been reached; can't produce accurate reports after the disaster
- **Key Tasks:** Activate evacuation mode, monitor real-time household statuses on the dashboard, assign households to evacuation centers, approve evacuation history logs

### Persona 2: Kagawad Marita — Barangay Staff (Field Worker)
- **Goals:** Update household statuses from her phone while doing door-to-door checks; flag special-needs residents for priority evacuation
- **Pain Points:** No way to log updates from the field; has to call the barangay hall and hope someone writes it down
- **Key Tasks:** Search and update individual household/resident statuses, flag special needs, view hazard map to prioritize visits, record residents at evacuation centers

### Persona 3: Engineer Dante — Municipal DRRMO Officer (Read-Only)
- **Goals:** Monitor all barangays in real time during a typhoon; generate NDRRMC-compliant damage and evacuation reports after the event
- **Pain Points:** Has to call each barangay captain individually for status updates; reports are assembled from conflicting paper sources
- **Key Tasks:** View cross-barangay dashboard, monitor evacuation center capacities, export reports for NDRRMC and DSWD submission

---

## 4. Goals & Success Metrics

| Goal | KPI | Target |
|---|---|---|
| Full household coverage | % of households in municipality with a registered record | ≥ 90% within 3 months of deployment |
| Real-time evacuation tracking | Time from evacuation activation to full status dashboard update | < 5 minutes per barangay |
| Vulnerable population visibility | % of PWD/elderly/infant households flagged in the registry | 100% of known cases registered |
| Evacuation center accuracy | Discrepancy between system occupancy count and actual head count | < 5% variance during drills |
| Reporting compliance | DRRMO report generation time after an event | < 2 hours (vs. current 2–3 days) |

---

## 5. Scope

### In Scope (v1.0)
- Household registry with geotag, special needs flags, and status tracking
- Resident registry linked to households with individual-level records
- Interactive hazard map with risk zone overlays and live household pins
- Evacuation center management with real-time occupancy tracking
- Active operations dashboard with evacuation protocol activation
- Evacuation history log with export to CSV/PDF for DRRMO reporting
- Role-based access control (Admin / Staff / DRRMO read-only)
- Barangay-scoped data access (staff see only their barangay)
- Bulk CSV import for household registry
- PWA with offline support for household registry view
- Mobile-responsive UI for field use

### Out of Scope (v1.0)
- SMS/push notifications to residents during evacuations (future integration)
- GCash or payment integrations
- Integration with NDRRMC's national reporting portal (manual export only)
- Native mobile apps (iOS/Android) — web PWA covers field use
- Multi-municipality / provincial rollup dashboard
- Automated typhoon signal detection or PAGASA API integration

---

## 6. Epics & Features

---

### Epic 1: Authentication & Role-Based Access Control
**Priority:** Must Have
**Description:** Secure login system with three roles (Admin, Staff, DRRMO Read-Only), barangay-scoped data isolation, and session management.

#### Feature 1.1: User Login & Session Management
As a barangay official, I want to log in with my credentials so that I can access the system securely.

**Acceptance Criteria:**
- [ ] Users can log in with email and password
- [ ] Sessions persist across browser refreshes
- [ ] Failed login attempts are rate-limited after 5 tries
- [ ] Users can log out from any page

**Jira Labels:** auth, must-have
**Story Points:** 3

#### Feature 1.2: Role-Based Access Control
As a system administrator, I want to assign roles to users so that staff only see their barangay's data and DRRMO officers have read-only cross-barangay access.

**Acceptance Criteria:**
- [ ] Three roles supported: Admin, Staff, DRRMO
- [ ] Staff users see only records scoped to their assigned barangay
- [ ] DRRMO users can view all barangays but cannot create or edit records
- [ ] Admins can create and manage user accounts
- [ ] Role is enforced on both API and UI levels

**Jira Labels:** auth, rbac, must-have
**Story Points:** 5

#### Feature 1.3: User Management (Admin)
As a Barangay Captain (Admin), I want to create and manage staff accounts so that my kagawads can access the system with appropriate permissions.

**Acceptance Criteria:**
- [ ] Admin can create, edit, deactivate, and delete user accounts
- [ ] Admin can assign role and barangay to each user
- [ ] Deactivated users cannot log in but their records are preserved
- [ ] User list is paginated and searchable

**Jira Labels:** auth, admin, must-have
**Story Points:** 3

---

### Epic 2: Household Registry
**Priority:** Must Have
**Description:** Core data layer — a complete, geotagged household database with special needs flags and evacuation status tracking.

#### Feature 2.1: Household CRUD
As a barangay staff member, I want to add, edit, and archive household records so that the registry stays accurate over time.

**Acceptance Criteria:**
- [ ] Create household with: household head name, barangay, sitio/purok, number of members, lat/lng geotag, special needs flags (PWD, elderly, infants, pregnant, bedridden)
- [ ] Edit any field on an existing household record
- [ ] Archive households (soft delete — not shown in active registry but retained in history)
- [ ] Household list is paginated, sortable, and filterable by barangay, status, and special needs flags
- [ ] Each household has a unique system-generated ID

**Jira Labels:** household, registry, must-have
**Story Points:** 5

#### Feature 2.2: Household Evacuation Status
As a barangay staff member, I want to update a household's evacuation status from the field so that the dashboard reflects real-time conditions.

**Acceptance Criteria:**
- [ ] Status options: At home, Pre-emptively evacuated, Evacuated, Unaccounted, Returned
- [ ] Status changes are timestamped and attributed to the user who made the change
- [ ] Status history is visible on the household detail page
- [ ] Staff can bulk-update statuses for multiple households at once

**Jira Labels:** household, evacuation, must-have
**Story Points:** 3

#### Feature 2.3: Bulk CSV Import
As a barangay staff member, I want to import household records from a CSV file so that I can onboard existing data without manual entry.

**Acceptance Criteria:**
- [ ] Upload CSV with a defined column schema (provided as a downloadable template)
- [ ] System validates CSV before import and reports row-level errors
- [ ] Duplicate household IDs are flagged and skipped (not overwritten)
- [ ] Successful import shows a summary (N imported, M skipped, K errors)

**Jira Labels:** household, import, must-have
**Story Points:** 5

#### Feature 2.4: Export Registry
As a barangay captain, I want to export the household registry to CSV or PDF so that I have an offline backup and can share it with the DRRMO.

**Acceptance Criteria:**
- [ ] Export all households to CSV with all fields
- [ ] Export filtered view (e.g., evacuated households only) to PDF
- [ ] Export is timestamped in the filename

**Jira Labels:** household, export, must-have
**Story Points:** 2

---

### Epic 3: Resident Registry
**Priority:** Must Have
**Description:** Individual resident records linked to households, enabling person-level tracking of vulnerable populations.

#### Feature 3.1: Resident CRUD
As a barangay staff member, I want to add and manage individual resident records linked to a household so that I can track vulnerable individuals.

**Acceptance Criteria:**
- [ ] Create resident with: full name, age, sex, relationship to household head, special needs category
- [ ] Resident is linked to exactly one household
- [ ] Edit and archive resident records
- [ ] Resident list is searchable by name, barangay, special needs tag, and evacuation status (inherited from household)

**Jira Labels:** resident, registry, must-have
**Story Points:** 5

#### Feature 3.2: Special Needs Search & Filtering
As a barangay staff member during an evacuation, I want to filter residents by special needs category so that I can prioritize who needs assistance first.

**Acceptance Criteria:**
- [ ] Filter residents by: PWD, Elderly (age ≥ 60), Infant (age ≤ 2), Pregnant, Bedridden
- [ ] Results show household head name, barangay, sitio, evacuation status, and assigned evacuation center
- [ ] Filterable results are exportable

**Jira Labels:** resident, special-needs, must-have
**Story Points:** 2

---

### Epic 4: Hazard Map
**Priority:** Must Have
**Description:** Interactive map visualizing household locations, risk zones, and evacuation center locations — the situational awareness layer for officials.

#### Feature 4.1: Household Map View
As a barangay official, I want to see all households plotted on a map so that I can understand the geographic distribution of residents.

**Acceptance Criteria:**
- [ ] Map displays all geotagged households as pins
- [ ] Pin color reflects evacuation status (green = at home, yellow = pre-emptive, red = evacuated, grey = unaccounted, blue = returned)
- [ ] Clicking a pin shows household summary (head name, members, special needs, status)
- [ ] Map is responsive and usable on mobile

**Jira Labels:** map, household, must-have
**Story Points:** 5

#### Feature 4.2: Risk Zone Overlays
As a barangay captain, I want to see flood and risk zones overlaid on the map so that I can identify which households are in danger during a typhoon.

**Acceptance Criteria:**
- [ ] Risk zones displayed as color-coded polygon layers: Low (green), Medium (orange), High (red)
- [ ] Risk zone data is uploaded/configured by admins as GeoJSON
- [ ] Layers can be toggled on/off individually
- [ ] Evacuation center markers are shown as a distinct layer

**Jira Labels:** map, risk-zones, must-have
**Story Points:** 8

#### Feature 4.3: Typhoon Mode Toggle
As a barangay captain during a typhoon, I want to activate typhoon mode on the map so that pre-emptive evacuation barangays are highlighted and the interface signals emergency state.

**Acceptance Criteria:**
- [ ] Typhoon mode can be toggled from the map toolbar
- [ ] When active: red alert banner appears at the top of all pages, sidebar accent changes to red, pre-emptive evacuation barangays are highlighted on the map
- [ ] Typhoon mode state is shared in real time — if Admin activates it, all logged-in users see it immediately
- [ ] Typhoon mode can only be activated by Admin role

**Jira Labels:** map, typhoon-mode, must-have
**Story Points:** 5

#### Feature 4.4: Live Status Updates on Map
As a barangay staff member, I want the map pins to update in real time as household statuses change so that I have a live situational picture.

**Acceptance Criteria:**
- [ ] Map pin colors update within 30 seconds of a status change without requiring a full page reload
- [ ] Update mechanism: WebSocket or polling interval (≤ 30s)
- [ ] No full page reload required for map updates

**Jira Labels:** map, realtime, should-have
**Story Points:** 5

---

### Epic 5: Evacuation Centers
**Priority:** Must Have
**Description:** Registry and real-time occupancy tracking for all designated evacuation centers in the municipality.

#### Feature 5.1: Evacuation Center CRUD
As an admin, I want to register and manage evacuation centers so that their locations, capacities, and statuses are tracked in the system.

**Acceptance Criteria:**
- [ ] Create evacuation center with: name, barangay, address, max capacity, geolocation
- [ ] Edit and deactivate evacuation centers
- [ ] Centers listed with current occupancy, max capacity, and occupancy percentage
- [ ] Status auto-calculated: Open (< 75%), At Capacity (75–99%), Full (100%)

**Jira Labels:** evacuation-center, must-have
**Story Points:** 3

#### Feature 5.2: Household Assignment to Centers
As a barangay staff member, I want to assign evacuated households to a specific evacuation center so that occupancy is accurately tracked.

**Acceptance Criteria:**
- [ ] From household detail or registry list, staff can assign household to an evacuation center
- [ ] Assignment updates the center's current occupancy count (by number of members in household)
- [ ] Assignment is logged with timestamp and user
- [ ] Staff can re-assign or unassign a household from a center

**Jira Labels:** evacuation-center, assignment, must-have
**Story Points:** 3

---

### Epic 6: Active Operations Dashboard
**Priority:** Must Have
**Description:** The central command view for barangay captains during an active evacuation event.

#### Feature 6.1: Summary Statistics Panel
As a barangay captain during an evacuation, I want to see live summary stats on the dashboard so that I have immediate situational awareness.

**Acceptance Criteria:**
- [ ] Stats displayed: total residents, currently evacuated (residents + households), high-risk residents (PWD/elderly/infants), open evacuation centers
- [ ] Stats update within 30 seconds of underlying data changes
- [ ] Stats are barangay-scoped for Staff; municipality-wide for Admin and DRRMO

**Jira Labels:** dashboard, must-have
**Story Points:** 3

#### Feature 6.2: Activate Evacuation Protocol
As a Barangay Captain, I want to activate an evacuation protocol so that all staff are notified and the system enters emergency mode.

**Acceptance Criteria:**
- [ ] "Activate Evacuation" button is visible on the dashboard (Admin only)
- [ ] Activation creates a new evacuation event record with timestamp, triggering event name, and scope (barangay or municipality-wide)
- [ ] All logged-in users see a real-time alert banner when evacuation is activated
- [ ] Admin can deactivate/close the evacuation event when the crisis ends
- [ ] Active operations counter badge increments in the sidebar when an event is active

**Jira Labels:** dashboard, evacuation-protocol, must-have
**Story Points:** 5

#### Feature 6.3: Recent Activity Feed
As a barangay staff member, I want to see a feed of recent household status changes on the dashboard so that I know what actions have been taken.

**Acceptance Criteria:**
- [ ] Activity feed shows the last 20 actions: who changed what household to what status, and when
- [ ] Feed updates in near-real-time (≤ 30s polling or WebSocket)
- [ ] Clicking an activity item navigates to the relevant household

**Jira Labels:** dashboard, activity-feed, should-have
**Story Points:** 3

---

### Epic 7: Evacuation History & Reports
**Priority:** Must Have
**Description:** Audit trail of all evacuation events and exportable reports for DRRMO/NDRRMC compliance.

#### Feature 7.1: Evacuation Event Log
As a barangay captain, I want to view a history of all past evacuation events so that I can review what happened and when.

**Acceptance Criteria:**
- [ ] Each event record includes: event name/typhoon, date activated, date closed, scope, total households evacuated, total residents evacuated, special needs count
- [ ] Events list is paginated and filterable by date range and barangay
- [ ] Clicking an event shows its full detail including all household statuses at time of closure

**Jira Labels:** reports, history, must-have
**Story Points:** 3

#### Feature 7.2: Analytics Dashboard
As a DRRMO officer, I want to view analytics on evacuation patterns so that I can identify high-risk barangays and plan resources better.

**Acceptance Criteria:**
- [ ] Charts: evacuation frequency per barangay, special-needs population breakdown, evacuation center utilization history
- [ ] Date range filter
- [ ] Charts are exportable as PNG

**Jira Labels:** reports, analytics, should-have
**Story Points:** 5

#### Feature 7.3: DRRMO/NDRRMC Report Export
As a DRRMO officer, I want to export an evacuation event report to PDF so that I can submit it to the NDRRMC within compliance deadlines.

**Acceptance Criteria:**
- [ ] PDF report includes: event summary, per-barangay breakdown, evacuation center usage, special-needs tally
- [ ] Report is generated within 30 seconds for events with up to 10,000 household records
- [ ] CSV export of raw event data is also available

**Jira Labels:** reports, export, ndrrmc, must-have
**Story Points:** 3

---

### Epic 8: Offline & PWA Support
**Priority:** Should Have
**Description:** Service worker caching so field staff can access the household registry and update statuses on low-bandwidth or offline connections.

#### Feature 8.1: PWA Installation & Service Worker
As a barangay kagawad in the field, I want to install the app on my phone and use it offline so that intermittent connectivity in Catanduanes doesn't interrupt my work.

**Acceptance Criteria:**
- [ ] App is installable as a PWA on Android and iOS (add to home screen)
- [ ] Household registry view is cached and accessible offline
- [ ] Status updates made offline are queued and synced when connectivity resumes
- [ ] User sees a clear indicator when they are in offline mode

**Jira Labels:** pwa, offline, should-have
**Story Points:** 8

---

### Epic 9: Won't Have (v1.0)
**Priority:** Won't Have
**Description:** Features explicitly deferred from v1.0 to avoid scope creep. These should not be started without explicit PM approval.

#### Feature 9.1: SMS Notifications to Residents
Automated SMS alerts sent directly to residents' phones during evacuations.
**Rationale:** Requires Telco API integration (Vonage, Globe Labs), additional cost per SMS, and phone number registry — deferred to v2.

#### Feature 9.2: NDRRMC Portal API Integration
Direct API submission to the national NDRRMC reporting portal.
**Rationale:** NDRRMC API access requires formal accreditation from DILG — use manual PDF export for v1.

#### Feature 9.3: Native iOS/Android Apps
Native mobile applications built in React Native or Flutter.
**Rationale:** PWA covers field use on mobile; native apps add build/release overhead that isn't justified for v1.

#### Feature 9.4: Multi-Municipality / Provincial Rollup
A provincial-level dashboard aggregating data across multiple municipalities.
**Rationale:** Single-municipality scope for v1; multi-tenancy architecture can be introduced in v2.

---

## 7. Technical Constraints & Assumptions

| Constraint | Detail |
|---|---|
| **Frontend** | Next.js (App Router) + Tailwind CSS + shadcn/ui |
| **Backend** | Next.js API routes (primary); Express/Fastify as alternative if API complexity warrants separation |
| **Database** | PostgreSQL with PostGIS extension for geospatial queries |
| **Map** | Leaflet.js — open source, works with cached tiles, offline-friendly |
| **Auth** | NextAuth.js with role-based access control; JWT or database sessions |
| **Hosting** | Must run on local LAN server (primary) or cloud (Render, Railway, or VPS); assume no managed Kubernetes |
| **Connectivity** | Must degrade gracefully on 3G/unstable connections; PWA offline cache for household registry |
| **Device targets** | Android and iOS mobile browsers; desktop browsers for Admin use |
| **Data scoping** | All queries must include barangay_id filter; enforced at API middleware level |
| **GeoJSON** | Risk zone polygons are admin-uploaded; no live PAGASA integration in v1 |
| **Real-time** | WebSocket (Socket.io or native WS) preferred; polling (≤ 30s interval) acceptable fallback |

---

## 8. Open Questions

1. **Geotag collection:** Will field staff collect lat/lng via the device GPS while on-site, or will coordinates be entered manually / imported via CSV? The UX for geotag capture needs to be decided before Feature 2.1 is built.

2. **GeoJSON source for risk zones:** Who provides the flood/risk zone GeoJSON files — PHIVOLCS, LGU engineering office, or NAMRIA? This determines the format and update cadence for Feature 4.2.

3. **Evacuation center occupancy counting:** Should occupancy be counted by number of household members (sum of `members` field) or by individual resident records? Both approaches have tradeoffs — member sum is faster but less accurate if households arrive partially.

4. **Offline sync conflict resolution:** If two staff members update the same household status while offline, what is the merge strategy — last-write-wins or flag for review?

5. **Typhoon mode authorization:** Should the Municipal DRRMO Officer be able to activate Typhoon Mode across all barangays, or only the Barangay Captain within their own barangay?

6. **Data retention policy:** How long should evacuation event records and status histories be retained? Is there a mandated retention period from DILG or NDRRMC?

---

## 9. Appendix

### Glossary

| Term | Definition |
|---|---|
| Barangay | Smallest administrative division in the Philippines; similar to a village or district |
| Kagawad | Elected barangay councilor; acts as field staff in this system |
| DRRMO | Disaster Risk Reduction and Management Office — municipal-level coordinating body |
| NDRRMC | National Disaster Risk Reduction and Management Council — national reporting body |
| 4Ps | Pantawid Pamilyang Pilipino Program — national conditional cash transfer program |
| PWD | Person with Disability |
| Sitio/Purok | Sub-barangay geographic subdivision |
| PostGIS | PostgreSQL extension for storing and querying geographic data |
| GeoJSON | Open standard format for encoding geographic data structures |
| PWA | Progressive Web App — web app installable on mobile with offline support |

### Reference Documents
- Catanduanes PDRRMP (Provincial Disaster Risk Reduction and Management Plan)
- NDRRMC Memorandum Circular on Disaster Reporting Requirements
- DILG Memorandum on Barangay Disaster Risk Reduction and Management Committees
