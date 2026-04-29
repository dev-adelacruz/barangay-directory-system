# Ticket Manifest
Generated: 2026-04-25T00:00:00Z
Project: BDS (Barangay Directory System)
Jira: https://snapplabs.atlassian.net/jira/software/projects/BDS/boards

## Epics
- [BDS-1] Authentication & Role-Based Access Control
- [BDS-2] Household Registry
- [BDS-3] Resident Registry
- [BDS-4] Hazard Map
- [BDS-5] Evacuation Centers
- [BDS-6] Active Operations Dashboard
- [BDS-7] Evacuation History & Reports
- [BDS-8] Offline & PWA Support
- [BDS-9] Won't Have (v1.0)

## Stories (by execution order)

### ✅ Already Implemented
- [BDS-10] User Login & Session Management — Status: Done — Depends on: none

### Must Have — Sequence #1–17
1.  [BDS-11] Role-Based Access Control — Status: To Do — Depends on: none (auth Done)
2.  [BDS-12] User Management (Admin) — Status: To Do — Depends on: BDS-11
3.  [BDS-13] Household CRUD — Status: To Do — Depends on: BDS-11
4.  [BDS-14] Household Evacuation Status — Status: To Do — Depends on: BDS-13
5.  [BDS-15] Bulk CSV Import for Household Registry — Status: To Do — Depends on: BDS-13
6.  [BDS-16] Export Household Registry to CSV/PDF — Status: To Do — Depends on: BDS-13
7.  [BDS-17] Resident CRUD — Status: To Do — Depends on: BDS-13
8.  [BDS-18] Special Needs Search & Filtering — Status: To Do — Depends on: BDS-17
9.  [BDS-19] Household Map View — Status: To Do — Depends on: BDS-11, BDS-13
10. [BDS-20] Risk Zone Overlays — Status: To Do — Depends on: BDS-19
11. [BDS-21] Typhoon Mode Toggle — Status: To Do — Depends on: BDS-19, BDS-11
12. [BDS-22] Evacuation Center CRUD — Status: To Do — Depends on: BDS-11
13. [BDS-23] Household Assignment to Evacuation Centers — Status: To Do — Depends on: BDS-22, BDS-14
14. [BDS-24] Summary Statistics Panel — Status: To Do — Depends on: BDS-13, BDS-17, BDS-22
15. [BDS-25] Activate Evacuation Protocol — Status: To Do — Depends on: BDS-11, BDS-24
16. [BDS-26] Evacuation Event Log — Status: To Do — Depends on: BDS-25
17. [BDS-27] DRRMO/NDRRMC Report Export — Status: To Do — Depends on: BDS-26

### Should Have — Sequence #18–20
18. [BDS-28] Live Status Updates on Map — Status: To Do — Depends on: BDS-19, BDS-14
19. [BDS-29] Recent Activity Feed — Status: To Do — Depends on: BDS-25, BDS-14
20. [BDS-30] Analytics Dashboard — Status: To Do — Depends on: BDS-26

### Could Have — Sequence #21
21. [BDS-31] PWA Installation & Service Worker — Status: To Do — Depends on: BDS-13

### Won't Have (v1.0) — No sequence
- [BDS-32] SMS Notifications to Residents — Status: Won't Have
- [BDS-33] NDRRMC Portal API Integration — Status: Won't Have
- [BDS-34] Native iOS/Android Apps — Status: Won't Have
- [BDS-35] Multi-Municipality / Provincial Rollup Dashboard — Status: Won't Have
