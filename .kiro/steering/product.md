# Product Overview

LittleThings (LTApp) is an iOS journaling/reflection app. Users answer daily questions ("reflections"), and the app generates weekly AI-powered insight reports with summaries, analytical overviews, and personalized icons.

## Core Features
- Daily reflection prompts with question-of-the-day
- Threaded question browsing and category-based question library
- Calendar view of past reflections
- AI-generated weekly reports with structured insights (summary, gem, analytical overview)
- Weekly report history with read/unread tracking
- Onboarding flow with Apple Sign-In
- Push notification support
- Icon generation tied to reflections

## Backend
- REST API hosted at `things.dvacode.tech`
- API docs located at `app/LTApp/API/api.md`
- Auth via Bearer token with refresh token flow
- Responses wrapped in `UniversalResponse<T>` envelope
