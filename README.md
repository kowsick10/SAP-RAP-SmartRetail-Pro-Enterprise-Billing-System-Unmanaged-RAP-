# SAP RAP: SmartRetail Pro – Enterprise Billing System (Unmanaged RAP)

**Project Code:** ZRAP_BILL_22CS083

A modern enterprise billing application built using the **ABAP RESTful Application Programming Model (RAP)** with an **Unmanaged Implementation**.

This system manages **customer billing transactions using a Header–Item business object model**, providing full control over database operations while exposing services through **OData V4 and SAP Fiori Elements**.

---

# 🧾 Project Overview

The **SmartRetail Pro Billing System** provides a scalable solution for managing enterprise invoices.

The application supports:

* Creating billing documents
* Managing multiple billing items per invoice
* Editing invoices using **Draft Handling**
* Performing validations before final submission
* Managing transactions via **SAP Fiori Elements UI**

The system follows a **Header–Item architecture**, commonly used in enterprise ERP systems.

| Entity         | Description                   |
| -------------- | ----------------------------- |
| Billing Header | Main invoice record           |
| Billing Item   | Line items inside the invoice |

---

# 🚀 Key Features

### Unmanaged RAP Implementation

Unlike managed RAP, this project uses **Unmanaged Implementation**, giving developers **full control over database operations and business logic**.

---

### Draft Handling

Supports RAP **Draft functionality**, enabling:

* Save as Draft
* Resume editing later
* Validation before activation

---

### Header–Item Business Object Model

Each invoice contains multiple items:

Billing Header
↳ Billing Items

This ensures **structured and scalable transaction management**.

---

### SAP Fiori Elements UI

The application provides:

* List Report
* Object Page
* Smart Filter Bar
* Responsive UI

---

### OData V4 Service Exposure

The system exposes business objects using **OData V4**.

Service Binding:

```
ZUI_RAP_BILLING_O4_083
```

---

# 🛠 Technical Stack

| Layer          | Technology         |
| -------------- | ------------------ |
| Framework      | ABAP RAP           |
| Implementation | Unmanaged RAP      |
| Language       | ABAP               |
| Data Modeling  | CDS Views          |
| API Protocol   | OData V4           |
| UI             | SAP Fiori Elements |
| Database       | SAP HANA           |

---

# 📁 Project Structure

Package:

```
ZRAP_BILL_22CS083
```

---

# 1️⃣ Business Services

### Service Definition

```
ZUI_RAP_BILLING083
```

Defines the **OData service interface** exposing billing entities.

---

### Service Binding

```
ZUI_RAP_BILLING_O4_083
```

Publishes the **OData V4 service** used by the Fiori application.

---

# 2️⃣ Core Data Services (CDS)

The project contains CDS objects for **data modeling and UI consumption**.

---

## Root View Entities

```
ZI_RAP_BILLHEADER083
ZI_RAP_BILLITEM083
```

These represent the **core business objects**.

---

## Projection Views (Consumption Layer)

```
ZC_RAP_BILLHEADER083
ZC_RAP_BILLITEM083
```

These CDS views are exposed to the **UI layer**.

---

## Metadata Extensions

```
ZC_RAP_BILLHEADER083
ZC_RAP_BILLITEM083
```

Used for defining:

* UI labels
* Field groups
* Display layout
* Search filters

---

# 3️⃣ Behavior Definitions

The project includes **Behavior Definitions for the business objects**.

Entities:

```
ZI_RAP_BILLHEADER083
ZI_RAP_BILLITEM083
```

Since this is **Unmanaged RAP**, developers implement:

* Create
* Update
* Delete
* Draft handling
* Business validations

inside the **Behavior Implementation Class**.

---

# 4️⃣ Dictionary (Database Tables)

### Billing Header Table

```
ZRAP_BILL_HDR083
```

Stores invoice header information.

Draft Table:

```
ZRAP_BILL_HDR083_D
```

Used for **Draft editing**.

---

### Billing Item Table

```
ZRAP_BILL_ITM083
```

Stores invoice item details.

Draft Table:

```
ZRAP_BILL_ITM083_D
```

Used for **Draft item editing**.

---

# ⚙️ Setup & Installation

### Step 1 – Activate Database Tables

Activate the following tables:

```
ZRAP_BILL_HDR083
ZRAP_BILL_ITM083
```

---

### Step 2 – Activate CDS Views

Activate the CDS objects:

```
ZI_RAP_BILLHEADER083
ZI_RAP_BILLITEM083
ZC_RAP_BILLHEADER083
ZC_RAP_BILLITEM083
```

---

### Step 3 – Activate Behavior Definitions

Activate behavior definitions for:

```
ZI_RAP_BILLHEADER083
ZI_RAP_BILLITEM083
```

---

### Step 4 – Publish Service

Activate the service binding:

```
ZUI_RAP_BILLING_O4_083
```

---

### Step 5 – Launch Application

1. Open **Service Binding**
2. Right-click the entity
3. Select **Preview**

This launches the **SAP Fiori Billing Application**.

---

# 🔑 Key Logic Components

### Determinations

Automatically calculate:

* Invoice totals
* Item pricing
* Billing timestamps

---

### Validations

Ensures:

* Billing header contains items
* Item quantity is valid
* No duplicate billing entries

---

### Draft Lifecycle

Supported operations:

* Create Draft
* Edit Draft
* Activate Draft
* Discard Draft

---

# 📊 Application Workflow

1️⃣ User creates a **Billing Header**

2️⃣ System generates a **Draft Invoice**

3️⃣ User adds multiple **Billing Items**

4️⃣ System validates billing data

5️⃣ User activates the draft

6️⃣ Final invoice is stored in the database

---

# 🎯 Learning Outcomes

This project demonstrates:

* **SAP RAP Unmanaged Scenario**
* **Header–Item Business Object modeling**
* **Draft Handling**
* **OData V4 service development**
* **SAP Fiori Elements UI integration**

---

# 👨‍💻 Author

**Kowsick K**

Project: **SmartRetail Pro – Enterprise Billing System**
Package: **ZRAP_BILL_22CS083**
Technology: **SAP RAP (Unmanaged) + OData V4 + Draft Handling**
Year: **2026**


