# Doseko

> Manage your medication with ease.

Doseko is a mobile health application designed to help users take control of their health. It provides a simple and intuitive interface for managing medications, logging side effects, and keeping track of medical appointments.

## Table of Contents

- [About The Project](#about-the-project)
- [Key Features](#key-features)
- [Application Flow](#application-flow)
  - [1. Onboarding & User Registration](#1-onboarding--user-registration)
  - [2. Activity & Side Effect Logging](#2-activity--side-effect-logging)
  - [3. Appointment Management](#3-appointment-management)

## About The Project

The purpose of Doseko is to provide users with a comprehensive toolset to manage their health journey. This includes introducing new users to the app's features via a simple onboarding process, allowing secure account creation, and providing core functionality for logging activities and scheduling appointments.

## Key Features

- **User Onboarding:** A multi-step visual introduction to the app's key features.
- **Authentication:** Secure account creation (Register) and sign-in (Login) for users.
- **Profile Setup:** A simple form to collect basic user bio information (Name, Age, Height, Weight, etc.).
- **Side Effect Logging:** Allows users to select a date and record side effects from a checklist (e.g., Headache, Fever, Nausea).
- **Activity Dashboard:** Displays a clean, chronological overview of all user-logged activities and side effects.
- **Appointment Scheduling:** An integrated calendar to add, view, and manage medical appointments, complete with notes, date, and time.

## Application Flow

### 1. Onboarding & User Registration

This flow introduces a new user to the app and gets their account set up.

1.  **Onboard:** A 3-screen visual guide with the following messages:
    - "Welcome to DoseKo! Manage your medication with ease."
    - "Stay on track! Never miss, stay in bliss."
    - "Get started now! Take control of your health today!"
2.  **Login/Register:** The user is presented with options to **Login** (for returning users) or **Register** (for new users).
3.  **Create Account:** The registration screen collects an email, password, and password confirmation.
4.  **Fill in Bio:** After registering, the user is prompted to "Fill in your bio to get started" with fields for Full Name, Mobile Number, Age, Height, Weight, and Gender.
5.  **Congrats:** A final screen confirms that "Your profile is ready to use," with a button to "Proceed to Home."

### 2. Activity & Side Effect Logging

This flow allows a user to record their symptoms and review them.

1.  **Empty State:** The "Log Activity" screen initially shows "No logs yet" and prompts the user to tap the `+` button to track side effects.
2.  **Add Log:** Tapping the `+` button navigates to the "Log Side Effects" screen.
3.  **Record Effects:** Here, the user can select a date and check off any symptoms they are experiencing (e.g., Headache, Fever, Nausea, Dizziness, etc.).
4.  **Save & View:** After tapping "Save," the user is returned to the "Log Activity" screen, which now displays a list of their logged entries, organized by date.

### 3. Appointment Management

This flow allows a user to manage their medical appointments.

1.  **Calendar View:** The "Appointment" screen shows a full monthly calendar and a list of appointments for the selected day.
2.  **Add Appointment:** The user taps the `+` button to navigate to the "Add Appointment" screen.
3.  **Enter Details:** The user fills in the "Appointment Name," "Notes (optional)," "Select Date," and "Select Time."
4.  **Save & View:** After tapping "Save," the user is returned to the main "Appointment" screen, where the new event (e.g., "Braces Adjustment") is visible in the list for the corresponding day.
