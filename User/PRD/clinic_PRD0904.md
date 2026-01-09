# Product Requirements Document (PRD)

## Clinic CRM & Patient Engagement Mobile Application



## Change Log

| Date       | Version | Description                                | Author      |
| ---------- | ------- | ------------------------------------------ | ----------- |
| 2025-12-18 | 0.90.1  | Initial PRD                                | Austin      |
| 2025-12-19 | 0.90.2  | Rewrite by ChatGPT                         | Bmad-Method |
| 2025-12-20 | 0.90.3  | Add pricing model & installation flow      | Bmad-Method |
| 2025-12-20 | 0.90.4  | Add pricing tier & licensing specification | Bmad-Method |



## 1. Document Information

| Item             | Description                         |
| ---------------- | ----------------------------------- |
| Product Name     | Clinic CRM & Patient Engagement App |
| Platform         | Mobile App (iOS / Android)          |
| Target Customers | Clinics (B2B)                       |
| PRD Version      | v0.90.4                             |
| Status           | Draft                               |
| Methodology      | BMad-Method                         |



## 2. Product Vision & Objectives

### 2.1 Vision

Build a **patient-centric, clinic-efficient mobile CRM platform** that becomes the primary interaction channel between clinics and customers by integrating:

* Appointment booking
* Treatment records
* Patient communication
* Payment history
* Inventory workflows

into **one unified mobile experience**.


### 2.2 Product Goals

**For Patients**

* Simple and reliable appointment booking
* Transparent access to treatment history
* Reduced waiting time and communication friction

**For Clinics**

* Lower manual scheduling workload
* Better treatment and inventory tracking
* Stronger long-term customer relationship management (CRM)

## 3. Target Users & Personas

### 3.1 User Types

#### Patient (Customer)

* Installs the app via clinic-provided QR code
* Books appointments and reviews records
* Uses Barcode as clinic ID

#### Clinic Staff

* Manages appointments and treatments
* Scans Barcodes for workflow and inventory
* Communicates with patients

#### Clinic Admin

* Manages treatment catalog and pricing
* Reviews payment and operational reports
* Controls staff roles and permissions



## 4. Commercial Model & Licensing Strategy

### 4.1 Business Model Overview

This application is sold as a **B2B SaaS product** to clinics.

Pricing and licensing are determined by **tiered plans**, based on a combination of:

* Number of registered clinic users
* Quarterly Active Users (QAU)
* Clinic’s average quarterly revenue range

Pricing tiers vary depending on:

* Clinic type (medical aesthetic, dental, pediatric, etc.)
* Clinic size and operational scale


### 4.2 Minimum Licensing Requirement

* Every clinic must subscribe to **at least one minimum tier**
* The system **cannot be activated below the minimum tier**
* Minimum tier guarantees:

  * Core CRM functionality
  * Operational stability
  * Support and maintenance baseline


## 5. Pricing Tier & Licensing Specification

> **This section is mandatory reading for Clinic Owners and Administrators**


### 5.1 Tier Dimensions

Pricing tiers are defined by **three measurable dimensions**:

1. **Clinic User Count**

   * Number of clinic-side accounts (doctors, staff, admins)

2. **Quarterly Active Users (QAU)**

   * Number of unique patient users who performed at least one meaningful action within a quarter
     (e.g. booking, check-in, record view)

3. **Clinic Quarterly Average Revenue Range**

   * Self-declared revenue range
   * Used for tier qualification and audit reference
   * Exact revenue values are **not displayed publicly**


### 5.2 Example Tier Structure (Illustrative)

> ⚠️ Exact numeric values are configurable and may differ by clinic type.

| Tier             | Intended Clinic Size | Clinic Users | QAU Range | Revenue Range |
| ---------------- | -------------------- | ------------ | --------- | ------------- |
| Tier S (Minimum) | Small / Solo Clinic  | Limited      | Low       | Entry-level   |
| Tier M           | Growing Clinic       | Medium       | Medium    | Mid-range     |
| Tier L           | Large Clinic         | High         | High      | High          |
| Tier XL          | Chain / Enterprise   | Custom       | Custom    | Custom        |


### 5.3 Licensing Rules

* Each clinic is assigned **one active tier**
* Tier limits apply **per clinic tenant**
* Tier configuration is **enforced by the system**, not manual policy


### 5.4 Tier Monitoring & Threshold Detection

The system must continuously monitor:

* Current clinic user count
* Rolling quarterly active user count
* Declared revenue tier metadata

When **any metric exceeds the upper bound of the current tier**, the system will:

1. Flag the clinic as **“Tier Threshold Exceeded”**
2. Trigger an internal tier escalation workflow


### 5.5 Alert & Notification Requirements

#### Trigger Conditions

* Clinic user count exceeds tier limit
* Quarterly active users exceed tier limit
* Manual admin override or audit flag

#### Notification Targets

When a tier threshold is crossed, the system must notify:

* Clinic Administrator / Owner
* Internal App Operator (company side)
* App Developer / Technical Team (configurable)

#### Notification Channels

* In-app admin notification (mandatory)
* Email notification (mandatory)
* Optional: internal system webhook (for billing / CRM)


### 5.6 Post-Threshold Behavior

After a threshold is crossed:

* The system **continues to operate normally**
* No immediate service disruption
* Clinic is informed that:

  * Tier upgrade is required
  * Grace period may apply (configurable)
* Final tier adjustment requires:

  * Admin confirmation
  * Updated billing agreement (outside app scope)


### 5.7 Audit & Transparency

* Admin users can view:

  * Current tier
  * Current usage metrics
  * Threshold limits
* Historical tier changes are logged
* Logs are accessible to:

  * Clinic Admin
  * App Operator (company side)


## 6. Product Distribution & Installation Flow

### 6.1 In Scope (Phase 1)

* Appointment booking & cancellation
* Treatment record management
* Barcode-based identification
* Notification system
* Payment history records
* Backend inventory control (clinic only)
* QR-code-based onboarding


### 6.2 Out of Scope (Future Phases)

* Insurance claim integration
* Deep EMR/HIS system integration
* Cross-clinic membership sharing
* Built-in app store marketing


## 7. Functional Requirements

### 7.1 Appointment & Booking System

**Overview**

* Bi-weekly rolling calendar (current week + next week only)
* Two booking modes:

  1. Specific doctor + specific time slot (queue-based)
  2. Specific doctor + time period (long treatments)

**Key Requirements**

* Doctor schedule change → patient must rebook
* Patient cancellation → slot released immediately
* Each booking generates a unique Reservation ID


### 7.2 Treatment Records

* Full patient treatment history
* Includes date, doctor, treatment type, notes
* System-generated suggestions:

  * Next treatment
  * Related treatments
  * Post-treatment cautions


### 7.3 Barcode System

* Unique Barcode (QR Code) per patient
* Used for:

  * Patient identification
  * Treatment workflow
  * Medicine and supply tracking
  * Inventory in/out control


### 7.4 Treatment Catalog (Treatment Pool)

* List of all treatments with descriptions and advantages
* Authorized staff can manage:

  * Content
  * Instructions
  * Cautions
  * Pricing


### 7.5 Notification System

* Event-driven notifications:

  * Booking updates
  * Treatment reminders
  * Promotions
* Channels:

  * App push (Phase 1)
  * Email / LINE (Phase 2)


### 7.6 Inventory Control (Backend Only)

* Clinic staff only
* Barcode-based inventory tracking
* Linked to treatment usage


### 7.7 Payment & Transaction Records

* Record all payment history
* Support discounts and special campaigns
* Viewable by patients

> Payment gateway integration planned for Phase 2


### 7.8 Authentication & Authorization

* Patient registration & login
* Staff login with role-based permissions
* Admin-level access for configuration


### 7.9 Navigation Structure (Patient App)

* Home
* My Reservations
* Book Appointment
* My Records
* More


### 7.10 Chat & Feedback

* Patient feedback on treatments
* Chat grouping:

  * By clinic department
  * By assigned doctor



## 8. Non-Functional Requirements (Updated)

* Licensing and tier checks must be:

  * Automated
  * Accurate
  * Tamper-resistant
* Tier monitoring must not impact app performance
* Multi-tenant isolation between clinics is mandatory


## 9. Success Metrics (Updated)

* Clinic retention rate by tier
* Tier upgrade conversion rate
* Number of tier threshold alerts per quarter
* Average time from threshold alert to tier upgrade


## 10. Recommended Next Steps (BMad-Method)

Strongly recommended next actions:

1. **UX Expert**

   * Admin-facing “Billing & Tier Status” dashboard
   * Threshold warning UX patterns

2. **Architect**

   * Multi-tenant licensing enforcement design
   * Usage metering & alert pipeline

3. **PO**

   * Epic & stories for:

     * Tier monitoring
     * Alerting
     * Admin visibility

