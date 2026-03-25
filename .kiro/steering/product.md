# Product: LittleThings (LTApp)

A daily reflection and journaling iOS app. Users answer daily questions, track their reflections over time, and receive AI-generated weekly insight reports.

## Core Features
- Daily reflection questions with answer submission
- Calendar view showing reflection history with custom icons
- Threaded question categories and a question library
- Weekly AI-generated insight reports (summary, gem moments, analytical overview)
- Report history with read/unread tracking
- Push notifications
- Apple ID sign-in authentication
- Onboarding flow
- User settings (question-of-the-day strategy)
- Feature toggle system for staged rollouts

## Backend
- REST API at `things.dvacode.tech` (HTTPS)
- JWT-based auth with refresh token flow
- API documentation lives in `app/LTApp/API/api.md`
- Responses use a universal wrapper: `{ success, msg, data }`
- Paginated lists use cursor-based pagination with `limit`, `cursor`, `hasMore`, `nextCursor`
