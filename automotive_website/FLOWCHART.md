# JA Noble Enterprise INC - System Flowchart
## Automotive Service Management System

---

## SYSTEM OVERVIEW

```
[User Opens System (index.html)]
        |
        v
[Login Screen - 3 Tabs: Customer | Staff | Admin]
        |
   _____|_____________________
  |           |               |
  v           v               v
[Customer] [Staff]         [Admin]
  Login      Login          Login
```

---

## 1. CUSTOMER FLOW

```
[Customer Opens index.html]
        |
        v
[Clicks "Customer" Tab]
        |
        v
[Enters Username & Password]
  (Demo: customer / customer123)
        |
        v
[Credentials Validated?]
   |           |
  NO          YES
   |           |
   v           v
[Error]   [Redirected to customerportal.html]
                |
                v
        [Customer Dashboard]
                |
        ________|________
       |                 |
       v                 v
[My Vehicles]     [Smart Reports]
       |                 |
       v                 v
[View all owned    [AI Chatbot Interface]
 registered             |
 vehicles]         [Type or click
       |            suggested queries]
       v                 |
[Each Vehicle Card] [Examples:]
  - Asset Number    - "Show all my vehicles"
  - Plate Number    - "Which assets are under maintenance?"
  - Asset Type      - "Which assets have PMS overdue?"
  - Owner           - "Show maintenance history"
  - Odometer              |
  - Last Service          v
  - Next PMS Due    [AI generates response
  - Status           based on vehicle data]
       |
       v
[View Maintenance History Button]
       |
       v
[Modal: Full Service History of Vehicle]
  - Date of Service
  - Service Type
  - Mechanic
  - Cost
  - Status
       |
       v
[Logout → Back to index.html]
```

---

## 2. STAFF FLOW

```
[Staff Opens index.html]
        |
        v
[Clicks "Staff" Tab]
        |
        v
[Enters Username & Password]
  (Demo: staff / staff123)
        |
        v
[Credentials Validated?]
   |           |
  NO          YES
   |           |
   v           v
[Error]   [Redirected to staff.html]
                |
                v
        [Staff Dashboard]
                |
    ____________|_______________________________
   |            |              |               |
   v            v              v               v
[Dashboard] [Inventory    [Asset          [Asset
             Management]   Management]    Issuance]
   |            |              |               |
   v            v              v               v
[Today's    [Stock         [Asset          [View Items
 Service     Inventory]    Maintenance]     Used per
 Schedule]      |              |            Service]
   - Plate      v              v               |
   - Owner  [View all      [View all       [Filter by
   - Type    parts w/       service         asset,
   - Status  qty, min,      records]        date,
             max levels]        |            item type]
                |           [New Service]
                v               |
           [Receive Items]      v
                |           [Fill in:]
                v            - Asset Number
           [Receive          - Date Serviced
            Delivery         - Mechanic Name
            Modal]           - Parts Used
                |            - Labor Cost
                v            - Status
           [Select Item,         |
            Enter Qty,           v
            Confirm]        [Save → Updates
                |            inventory stock
                v            automatically]
           [Stock updated]
                |
                v
           [Inventory
            Transactions]
            - View history
              of all stock
              in/out movements

[Logout → Back to index.html]
```

---

## 3. ADMIN FLOW

```
[Admin Opens index.html]
        |
        v
[Clicks "Admin" Tab]
        |
        v
[Enters Username & Password]
  (Demo: admin / admin123)
        |
        v
[Credentials Validated?]
   |           |
  NO          YES
   |           |
   v           v
[Error]   [Redirected to admin.html]
                |
                v
        [Admin Control Panel]
                |
    ____________|_____________________________________________
   |        |         |          |          |        |       |
   v        v         v          v          v        v       v
[Dashboard][Inventory][Asset   ][Decision][User   ][Reports][Smart
            Mgmt]      Mgmt]    Support]   Mgmt]            Reports]
   |        |         |          |          |        |       |
   v        v         v          v          v        v       v
[Stats:  [Item      [Asset     [Stock     [Add/    [Standard [AI
 Assets,  Master]   Mainten-   Replenish- Edit/    Reports]  Chatbot
 PMS Due,    |      ance]      ment DSS]  Delete      |      for
 Low Stock,  v         |          |       Users]      v      deeper
 Services] [Add/    [View/     [AI-based     |    [Mainten-  analysis]
            Edit/   Add/Edit   reorder       v    ance
            Delete  Services]  suggestions] [Assign Summary,
            Items]     |          |         Role:  Cost,
               |       v          v         Admin/ Parts
               v   [Assign    [PMS          Staff/ Used,
           [Stock   Mechanic,  Scheduling   Cust]  Low Stock
           Inventory Parts,    DSS]             |  Alerts]
               |    Cost,          |            v
               v    Status]    [AI-based   [Set Status:
           [Receive     |       PMS         Active /
            Items]      v       schedule    Inactive]
               |    [Complete   suggestions]
               v    Service →
           [Inventory  Updates
           Transactions odometer,
               |       PMS date]
               v
           [Full audit
            trail of
            stock in/out]

[Notifications Bell]
  - PMS Overdue alerts
  - Low stock alerts
  - New user registrations

[Logout → Back to index.html]
```

---

## FULL SYSTEM FLOW (End-to-End)

```
START
  |
  v
[index.html - Login Page]
  |
  |--[Customer Login]---> customerportal.html
  |                           |
  |                     [View Vehicles]
  |                     [View PMS Status]
  |                     [View Maintenance History]
  |                     [Ask Smart Reports AI]
  |                           |
  |                       [Logout]
  |
  |--[Staff Login]-----> staff.html
  |                           |
  |                     [View Dashboard]
  |                     [Manage Inventory]
  |                       - Receive deliveries
  |                       - View stock levels
  |                     [Record Asset Maintenance]
  |                       - Log service done
  |                       - Use parts (auto-deducts stock)
  |                     [View Issuances]
  |                     [View Transactions]
  |                           |
  |                       [Logout]
  |
  |--[Admin Login]-----> admin.html
                              |
                        [Full Dashboard]
                        [Item Master - CRUD]
                        [Stock Inventory - CRUD]
                        [Inventory Transactions]
                        [Asset Management - CRUD]
                        [Asset Maintenance - CRUD]
                        [Asset Issuance - View]
                        [DSS - Stock Replenishment]
                        [DSS - PMS Scheduling]
                        [User Management - CRUD]
                        [Standard Reports]
                        [Smart Reports AI]
                        [Notifications]
                              |
                          [Logout]
END
```

---

## KEY BUSINESS RULES

- Stock is automatically deducted when staff records a service and uses parts
- PMS (Preventive Maintenance Schedule) is tracked per vehicle by odometer/date
- Customers can only see their own vehicles and history
- Staff can record services and receive inventory but cannot manage users or items
- Admin has full access to all modules including reports and decision support
- Smart Reports AI is available to both Admin and Customer (scoped to their data)
- Notifications alert admin of low stock and overdue PMS automatically
