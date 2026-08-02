# BCI Integrated Management System - Flutter MVP

This starter application covers the MVP checklist from the project proposal:

1. Login, password management and role-based access (mock/demo accounts)
2. Student management, including attendance by module and date
3. Employee management with structured salary components (allowances/deductions)
4. Employee attendance and leave requests (apply, approve/reject)
5. Monthly payroll periods: generation, approval and payslip view

It uses only the Flutter SDK, so there are no third-party package dependencies.
Data is currently stored in memory for demonstration and teaching. Closing the
application clears newly entered records, and role checks are enforced only on
the client. The next production step is to connect this UI to a Spring Boot
REST API and PostgreSQL database, which is where authentication, permissions
and payroll calculations should ultimately live.

## Features

- Responsive dashboard for mobile and desktop/web widths, with role-aware navigation
- Login with demo accounts for each role (admin, registrar, HR officer, finance officer,
  payroll approver, lecturer, employee, student)
- Student search, registration, editing and deletion
- Student attendance marking by module and date, with attendance percentage
- Employee search, registration and editing with dynamic allowance/deduction line items
- Employee daily attendance log (check-in/check-out)
- Employee leave requests with HR/admin approval and leave balance tracking
- Payroll periods: create, generate, approve and view individual payslips
- Sample data for classroom demonstrations
- Form validation
- Material 3 interface

## Demo accounts

All demo accounts use the password shown in the login screen's "Demo accounts" panel
(also visible directly in `lib/state/bci_store.dart`). Each role sees only the
navigation destinations relevant to it, e.g. the `employee` account only sees its own
attendance, leave and payslips, and the `student` account only sees its own attendance.

## Project setup on macOS

### Option A: Create platform folders inside this project

1. Extract the ZIP file.
2. Open Terminal in the extracted folder.
3. Run:

```bash
flutter create --project-name bci_management_system .
flutter pub get
flutter run
```

`flutter create --project-name bci_management_system .` generates the Android, iOS, web and desktop folders while
keeping the supplied `lib` source code.

### Option B: Create a new Flutter project

```bash
flutter create bci_management_system
cd bci_management_system
```

Replace its `lib` folder and `pubspec.yaml` with the files from this starter.
Then run:

```bash
flutter pub get
flutter run
```

## Run targets

List devices:

```bash
flutter devices
```

Run Android emulator or phone:

```bash
flutter run
```

Run in Chrome:

```bash
flutter run -d chrome
```

## Payroll formula

- Gross Salary = Basic Salary + Allowances + Overtime
- Total Deductions = Other Deductions + Tax + No-Pay Leave deduction (pro-rated on basic salary)
- Net Salary = Gross Salary - Total Deductions

No-pay leave deductions are calculated automatically during payroll generation from
any approved no-pay leave requests that overlap the payroll period's date range.

## Recommended production improvements

- Spring Boot REST API
- PostgreSQL database
- JWT authentication and server-enforced role permissions
- Student results and fees
- PDF payslip generation and email delivery
- Audit logs and database backups
