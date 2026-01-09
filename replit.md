# Clinext - 醫美診所 CRM & 客戶管理系統

## Overview
Clinext is a Clinic CRM & Patient Engagement Mobile Application designed for medical beauty (aesthetic) clinics. This Sprint 1 prototype focuses on:
- Authentication & Authorization (Section 7.8)
- Financial Analytics & Catalog Management
- Staff/Admin inventory and sales management

## Current State
Sprint 1 prototype with mock data demonstrating:
- Patient, Staff, and Admin login flows
- Hidden staff/admin login (tap logo 5-7 times on home page)
- Inventory management for medical beauty treatments
- Sales order creation and customer management
- Financial reports and analytics

## Authentication (Section 7.8)
Three user types with mock identities:
- **Patient**: Regular customer registration & login
- **Staff**: Role-based permissions (Doctor, Nurse, Beauty Therapist)
- **Admin**: Full configuration access

### Test Accounts
| Role | Username | Password |
|------|----------|----------|
| Patient | patient1 | 123456 |
| Staff | nurse1 | staff123 |
| Admin | admin | admin123 |

### Hidden Staff/Admin Login
Tap the app logo 5-7 times rapidly on the home page to reveal the staff/admin login page.

## Project Structure
```
public/
├── index.html              # Landing page with navigation
├── img/                    # Logo and image assets
│   ├── logo_dark.png
│   └── logo_light.png
└── pages/
    ├── home.html           # Patient home page (with secret login)
    ├── login.html          # Login page (patient/staff/admin)
    ├── reservation.html    # Appointment booking
    ├── chat.html           # Chat interface
    ├── dept_list.html      # Department list
    ├── med_service.html    # Medical services
    ├── service_fee.html    # Service fees
    ├── admin/
    │   └── dashboard.html  # System admin control panel (tenant management)
    ├── staff/
    │   └── dashboard.html  # Staff dashboard with navigation
    ├── invcontrol/
    │   ├── inventory.html      # Inventory management with expiration tracking
    │   └── incoming_materials.html # Purchase/procurement management
    ├── inventory/
    │   ├── inventory.html      # Legacy inventory overview
    │   └── drug_materials.html # Treatment-material mapping
    ├── accounting/
    │   ├── dashboard_accounting.html  # Accounting dashboard
    │   ├── voucher.html               # Voucher management
    │   └── new_voucher.html           # Create new voucher
    └── sales/
        ├── new_order.html      # Create treatment order
        ├── treatment_catalog.html  # Treatment catalog management
        ├── treatment_order.html    # Treatment order management
        ├── customers.html      # Customer management
        └── reports.html        # Financial reports

User/                       # Documentation
├── Architecture/           # System architecture
├── Development/            # Development plans
│   └── erd.md              # Entity Relationship Diagram
├── PRD/                    # Product requirements
└── UI/                     # Original mockups

database/
└── schema.sql              # PostgreSQL database schema

api/
└── openapi.yaml            # OpenAPI 3.0 API specification
```

## Tech Stack
- Static HTML with Tailwind CSS (via CDN)
- Vanilla JavaScript for interactivity
- Node.js serve package for static file hosting
- PostgreSQL database schema (ready for backend integration)
- OpenAPI 3.0 API specification

## Database Schema
Located at `database/schema.sql`, includes:
- Core tables: patients, doctors, staff, visits
- Treatment management: treatments, devices, drugs
- Clinical records: treatment_sessions, treatment_drug_usage
- Follow-up & scheduling: follow_ups
- Orders & billing: orders, order_items, vouchers
- Inventory: drugs, inventory_transactions, purchase_orders
- Authentication: users, user_permissions
- Audit: audit_logs, system_settings

## API Specification
Located at `api/openapi.yaml` (OpenAPI 3.0 format), includes:
- Authentication endpoints (login, logout, current user)
- Patient management (CRUD, history)
- Visit management
- Treatment catalog
- Treatment sessions (clinical records)
- Follow-up management
- Order management
- Inventory management
- Dashboard & analytics APIs

## Treatment Data (Medical Beauty)
Based on treatment_data_management.md, includes:
- Injectable treatments (Botox, Hyaluronic Acid, PRP)
- Energy-based devices (HIFU, Thermage, Pico Laser)
- Bundle promotions

## Running the Project
Static file server on port 5000: `npx serve public -l 5000`

## Sprint 1 Features
1. **Authentication System**: Mock login for patient/staff/admin
2. **Inventory Control**: Medical beauty specific inventory with drug/material tracking
3. **Sales Management**: Treatment order creation, customer management
4. **Financial Reports**: Revenue analytics, profit/loss tracking
5. **Treatment Catalog**: Drug-material mapping for all treatments

## Mock Data (new_order.html)
The treatment order creation page includes comprehensive mock data:

### Doctors (4 records)
| ID | Name | Specialty | License |
|----|------|-----------|---------|
| DOC001 | 張醫師 | 微整形注射 | DOC-2015-001 |
| DOC002 | 李醫師 | 雷射光療 | DOC-2018-002 |
| DOC003 | 王醫師 | 音波電波 | DOC-2020-003 |
| DOC004 | 陳醫師 | 皮膚科 | DOC-2019-004 |

### Nurses/Staff (5 records)
| ID | Name | Role | Specialty/License |
|----|------|------|-------------------|
| STF001 | 張護理師 | Nurse | NUR-2016-001 |
| STF002 | 林美容師 | Therapist | 臉部保養 |
| STF003 | 陳顧問 | Consultant | 療程諮詢 |
| STF004 | 王護理師 | Nurse | NUR-2018-002 |
| STF005 | 黃美容師 | Therapist | 身體療程 |

### Patients (6 records)
| ID | Name | Gender | Skin Type | Phone |
|----|------|--------|-----------|-------|
| PAT001 | 陳美玲 | 女性 | III型 | 0912-345-678 |
| PAT002 | 林志明 | 男性 | IV型 | 0933-456-789 |
| PAT003 | 王小美 | 女性 | II型 | 0988-777-666 |
| PAT004 | 張雅婷 | 女性 | III型 | 0955-123-456 |
| PAT005 | 李大偉 | 男性 | V型 | 0922-888-999 |
| PAT006 | 黃佳琪 | 女性 | II型 | 0966-555-444 |

### Features Added
- Flatpickr date picker with Traditional Chinese locale
- Doctor selection modal with specialty display
- Nurse/staff selection modal with role icons
- Patient search functionality
- Treatment order submission with all fields

## User Preferences
- Language: Traditional Chinese (zh-TW)
- Target users: Medical beauty clinic staff and patients
