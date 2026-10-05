# SkillPath — Master Build Prompt

You are a senior Flutter engineer, Supabase architect, realtime voice-AI engineer, RAG engineer, UI/UX designer, and hackathon product engineer.

Build a complete, working hackathon MVP called **SkillPath**.

## Product

**Name:** SkillPath  
**Tagline:** Your Skills. Your Career. Your Path.

SkillPath is an AI-enabled career counselling and family decision-support platform for vocational education. It helps learners and parents jointly evaluate vocational careers using verified outcome data, regional-language counselling, career progression information, and human counsellor escalation.

This is NOT just a chatbot.

The central product flow is:

Learner/Parent
→ Profile
→ Career interests + concerns
→ Real-time AI counselling
→ Verified data retrieval
→ Career recommendation/comparison
→ Family decision support
→ Human counsellor escalation
→ Counsellor dashboard
→ Administrator analytics

The hackathon problem statement is from the Ministry of Skill Development and Entrepreneurship (MSDE).

---

# 1. Required Technology Stack

## Mobile app

Use:

- Flutter
- Dart
- Material 3
- Android-first
- Responsive layouts

## Backend

Use:

- Supabase
- PostgreSQL
- Supabase Auth
- Supabase Storage
- Supabase Realtime
- Row Level Security
- Edge Functions where appropriate
- pgvector where semantic retrieval is useful

## Voice AI

Use:

- LiveKit for realtime audio/agent communication
- Gemini Live API for realtime conversational AI

Use LiveKit Agents on the backend, preferably Python or Node.js.

Do NOT put the Gemini API key in the Flutter application.

Recommended flow:

Flutter
→ LiveKit room
→ LiveKit Agent
→ Gemini Live
→ SkillPath tools
→ Supabase
→ verified data
→ Gemini response
→ LiveKit
→ Flutter

The AI must be able to perform backend tool/function calls such as:

- search careers
- get trade outcome
- get provider information
- compare careers
- get career progression
- get nearby providers
- record family concern
- create counsellor escalation

---

# 2. Critical AI Safety/Data Rule

Never allow Gemini to invent:

- placement percentages
- salary figures
- training-provider information
- NSQF levels
- employment statistics
- government statistics
- career progression facts

The correct flow is:

User question
→ Gemini identifies intent
→ backend tool/function
→ Supabase verified dataset
→ structured result
→ Gemini explains result

If data does not exist, the AI must say that reliable data is unavailable.

Clearly label hackathon dummy data as:

"Demo dataset provided for hackathon evaluation."

Never present dummy data as official government statistics.

---

# 3. AI Counsellor Personality

The SkillPath AI should be:

- neutral
- respectful
- evidence-based
- family-friendly
- easy to understand
- non-judgmental
- concise in voice conversations

It must not pressure parents or learners into a specific career.

It should acknowledge both perspectives.

Example:

Parent:
"Will my child get a job after this course?"

AI:
"That is an important concern. Let me check the available SkillPath outcome data for this trade."

Then call the relevant tool.

The AI should explain:

- placement
- salary range
- career growth
- further education
- relevant providers

Only from retrieved data.

---

# 4. Languages

Support:

- English
- Tamil

Design the localization architecture so more Indian languages can be added later.

Support:

- Tamil voice
- English voice
- Tamil text
- English text
- Tanglish input where Gemini can understand it

Examples:

"இந்த course முடிச்சா வேலை கிடைக்குமா?"

"CNC course mudicha enna job kedaikum?"

Both should be understood.

---

# 5. User Roles

Implement:

- learner
- parent
- counsellor
- admin

Use Supabase Auth and RLS.

Learners can access their own information.

Parents can access only their linked learner/family information.

Counsellors can access assigned escalations.

Admins can access aggregate analytics and authorized management data.

---

# 6. Authentication

Implement:

- Email/password signup
- Login
- Logout
- Forgot password
- Session persistence
- Role-based routing

Optional:

- Google Sign-In

After login:

learner → learner home
parent → parent home
counsellor → counsellor dashboard
admin → admin dashboard

Never hardcode real passwords or API keys.

---

# 7. Onboarding

Create a polished onboarding flow.

Screen 1:

SkillPath

Your Skills.
Your Career.
Your Path.

Screen 2:

Who are you?

Student
Parent

Screen 3:

Choose language:

English
தமிழ்

Learner information:

- education level
- academic background
- interests
- skills
- preferred industry
- salary expectation
- willingness to relocate
- preferred work environment
- location

Parent information:

- salary concern
- job-security concern
- social-status concern
- safety concern
- distance concern
- course-quality concern
- career-growth concern
- higher-education concern

Store data in Supabase.

---

# 8. Database

Create migrations and seed data.

Tables:

profiles
learner_profiles
parent_profiles
family_links
trades
career_roles
career_paths
training_providers
outcomes
conversations
messages
concerns
escalations
sentiment_events
recommendations

Important fields:

profiles:
- id
- name
- email
- role
- language
- state
- district
- city
- created_at

learner_profiles:
- user_id
- education_level
- academic_score
- interests
- skills
- preferred_industries
- salary_expectation
- willing_to_relocate

parent_profiles:
- user_id
- learner_id
- concerns
- expectations

trades:
- id
- name
- name_tamil
- description
- description_tamil
- nsqf_level
- sector
- skills

career_roles:
- id
- trade_id
- role_name
- role_name_tamil
- description
- experience_level

career_paths:
- id
- trade_id
- step_number
- title
- title_tamil
- description
- next_step

training_providers:
- id
- name
- district
- city
- state
- address
- latitude
- longitude
- phone
- email
- verified

outcomes:
- id
- trade_id
- provider_id
- district
- placement_rate
- min_salary
- max_salary
- average_salary
- sample_size
- data_year
- verified
- source

conversations:
- id
- user_id
- language
- status
- created_at

messages:
- id
- conversation_id
- sender
- message
- intent
- created_at

concerns:
- id
- user_id
- conversation_id
- category
- description
- severity
- status

escalations:
- id
- conversation_id
- user_id
- assigned_counsellor
- reason
- priority
- status
- resolution
- created_at
- resolved_at

sentiment_events:
- id
- conversation_id
- sentiment
- confidence
- created_at

recommendations:
- id
- learner_id
- trade_id
- match_score
- reasons
- created_at

Add indexes for common searches.

Enable RLS on every user-sensitive table.

---

# 9. Seed Dataset

Create realistic demo data for:

- Electrician
- Fitter
- CNC Operator
- Solar Technician
- Welder
- Refrigeration & Air Conditioning Technician
- Automotive Service Technician
- Computer Hardware Technician
- Plumber
- Beauty & Wellness Technician

Include:

- placement rate
- starting salary
- maximum/experienced salary
- average salary
- district
- provider
- sample size
- year
- verification status

Clearly label this as demo/hackathon data.

Seed providers across example Tamil Nadu districts, including Salem, Coimbatore, Chennai, Madurai, Tiruchirappalli, Erode, etc.

Do not claim these dummy values are official.

---

# 10. Flutter Architecture

Use a clean structure:

lib/
  main.dart
  app.dart
  core/
    theme/
    constants/
    services/
    utils/
    widgets/
  models/
  repositories/
  providers/
  screens/
    onboarding/
    auth/
    home/
    profile/
    counsellor/
    careers/
    comparison/
    family/
    escalation/
    settings/
  l10n/

Use reusable widgets.

Do not create a giant main.dart.

Use proper state management such as Riverpod or another maintainable approach.

---

# 11. Main App Screens

## Learner/Parent bottom navigation

Home
Explore
Counsellor
Family
Profile

## Counsellor

Dashboard
Requests
Clients
Profile

## Admin

Overview
Insights
Users
Escalations
Settings

---

# 12. Home Dashboard

Header:

Good morning, [Name]

"Let's find the right career path."

Cards:

Continue Counselling
Recommended Careers
Family Decision Progress
Explore Careers

Show concise, visually attractive cards.

---

# 13. AI Counsellor

This is the flagship screen.

Create a voice-first interface.

Header:

SkillPath AI Counsellor
Online

Large microphone button.

Allow:

- start voice session
- stop voice session
- mute/unmute
- show live transcript
- text fallback
- language selection
- end session

Show:

"SkillPath AI is listening..."

"SkillPath AI is thinking..."

Do not fake these states if realtime connection is not active.

The voice interface must use LiveKit.

---

# 14. LiveKit Integration

Create a backend LiveKit Agent.

Responsibilities:

- join LiveKit room
- receive user audio
- use Gemini Live
- return AI audio
- expose SkillPath backend tools
- preserve session context
- record relevant structured events
- gracefully handle disconnects

Use secure token generation.

Flutter should request a short-lived LiveKit access token from a secure backend endpoint.

Never put LiveKit API secret in Flutter.

Environment variables on backend:

LIVEKIT_URL
LIVEKIT_API_KEY
LIVEKIT_API_SECRET
GOOGLE_API_KEY
SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY

Do not expose service-role keys to Flutter.

---

# 15. Gemini Live

Use Gemini Live/realtime model through LiveKit.

Keep model configuration isolated.

Create a service/agent configuration so the model can be changed without rewriting the app.

Configure:

- voice
- language
- system instructions
- interruption handling
- turn detection
- tool/function calling
- session context

Use current LiveKit/Gemini APIs rather than obsolete APIs.

---

# 16. SkillPath AI Tools

Implement backend tools/functions:

get_trade_outcome(trade_id or trade_name, location)
search_careers(query, filters)
compare_careers(trade_ids)
get_career_path(trade_id)
get_training_providers(trade_id, location)
get_family_concerns(family_id)
record_concern(category, details)
create_escalation(reason, priority)
get_learner_profile(user_id)

Tool responses must be structured JSON.

Example:

{
  "trade": "CNC Operator",
  "placement_rate": 82,
  "starting_salary_min": 16000,
  "starting_salary_max": 20000,
  "average_salary": 18000,
  "data_year": 2026,
  "sample_size": 420,
  "verified": true,
  "source": "Hackathon demo dataset"
}

Gemini must only use these returned values for factual claims.

---

# 17. Verified Data Card

When factual outcome data is used, display a card in the app.

Example:

VERIFIED OUTCOME DATA

CNC Operator

Placement
82%

Starting salary
₹16K–₹20K

Average salary
₹18K

Data year
2026

Sample size
420

✓ Verified demo dataset

Include a small "Data source" indicator.

---

# 18. Career Explorer

Search and filter careers.

Filters:

- industry
- education
- NSQF level
- district
- salary
- placement
- relocation

Career card:

CNC Operator
NSQF Level 4
82% placement
₹16K–₹20K starting salary
High growth

[View Career]

---

# 19. Career Details

Sections:

Overview
Skills Required
Salary
Placement
Job Roles
Career Growth
Education Path
Nearby Providers
Ask AI

Show source metadata.

---

# 20. Career Progression

Create a visual timeline:

10th / 12th
↓
Vocational Training
↓
CNC Operator
↓
Senior CNC Operator
↓
Production Technician
↓
Supervisor
↓
Advanced Certification

Make every step tappable.

---

# 21. Career Comparison

Allow 2–4 careers.

Example:

CNC Operator vs Electrician vs Solar Technician

Compare:

- placement
- salary
- career growth
- local availability
- further study
- relocation

Do not automatically declare one career universally "best."

Instead show:

"Best match for your stated preferences"

with reasons.

---

# 22. Recommendation Engine

Calculate a transparent match score from:

- interest match
- skill match
- education eligibility
- location
- salary preference
- relocation preference
- placement
- career growth

Example:

CNC Operator — 92%
Electrician — 84%
Solar Technician — 79%

Label:

"SkillPath match score based on your stated preferences and available dataset."

Show reasons.

---

# 23. Family Decision Mode

Create a signature feature.

Show:

Learner preference
Parent concerns
Verified evidence
AI discussion
Decision progress

Example:

Learner:
Interested in CNC Operator

Parent:
Concerned about job security

AI:
"Your concern about job security is understandable. Based on the available SkillPath demo dataset, the placement rate for this trade is 82%."

Then:

"Would you like to see the career progression?"

Use a neutral counselling approach.

---

# 24. Family Progress

Show:

✓ Career explored
✓ Salary discussed
✓ Job security discussed
○ Training provider selected
○ Final decision

Use a progress bar.

---

# 25. Human Counsellor Escalation

If AI cannot answer reliably, show:

"Still have questions?"

"Talk to a SkillPath Counsellor"

Reasons:

- career selection
- salary
- provider
- family concern
- other

Create escalation.

Statuses:

Pending
Assigned
In Progress
Resolved

---

# 26. Counsellor Dashboard

Show:

Pending requests
In progress
Resolved today

Counsellor can:

- view conversation
- view learner profile
- view parent concerns
- view verified career data
- add notes
- respond
- resolve

Do not expose unrelated users.

---

# 27. Admin Dashboard

Create a polished analytics dashboard.

Top cards:

Total Users
Families Engaged
AI Sessions
Human Escalations

Charts:

Concern Distribution
Regional Resistance
Career Interest
AI Resolution Rate

Example demo:

Salary — 38%
Job Security — 26%
Social Status — 18%
Safety — 10%
Distance — 8%

Label all demo analytics appropriately.

---

# 28. Admin AI Insights

Generate summaries from aggregate database queries.

Example:

"Job security is currently the largest parental concern in the demo dataset."

Never generate insights from private individual conversations unless explicitly authorized and privacy-safe.

---

# 29. Low-Literacy Mode

Add Simple Mode.

When enabled:

- larger text
- icons
- fewer words
- voice-first UI
- one question at a time
- Tamil-first explanations
- visual career paths

Example:

🎓 Training
↓
🔧 Job
↓
💰 Income
↓
📈 Growth

---

# 30. Voice Experience

The voice UI should feel like a real assistant.

Requirements:

- realtime audio
- interruption support if supported
- live transcript
- speaking/listening state
- connection status
- microphone permissions
- fallback to text
- graceful disconnect

Never fake AI speech with prerecorded audio.

---

# 31. Privacy and Security

Implement:

- Supabase RLS
- secure backend keys
- no API secrets in Flutter
- short-lived LiveKit tokens
- minimal PII
- secure counsellor access
- aggregate admin analytics
- privacy notice
- delete-account flow

Use the Supabase publishable/anon client key only on the client. Service-role keys must remain server-side.

---

# 32. Demo Scenario

Create a complete demo family.

Learner:

12th standard
Salem
Interested in mechanical work

Parent concern:

Job security

Selected career:

CNC Operator

Demo outcome:

82% placement
₹16K–₹20K starting salary

Demo conversation:

Student:
"I want to join CNC training."

Parent:
"But will he get a good job?"

SkillPath:
"That's an important concern. Let me check the verified outcome data."

Then show the data card.

Then show:

career progression
training providers
comparison

Then:

"Would you like to speak with a human counsellor?"

Parent chooses Yes.

Admin dashboard receives:

New escalation
Concern: Job Security
Trade: CNC Operator
District: Salem

This should be the primary 2–3 minute hackathon demonstration.

---

# 33. UI Design

Visual style:

- trustworthy
- modern
- accessible
- professional
- friendly
- government/public-service appropriate

Suggested palette:

deep blue
teal/green
warm yellow/orange
light neutral background

Use:

- rounded cards
- strong typography
- large data numbers
- clear icons
- subtle animations
- progress indicators
- charts
- bottom navigation

Do not overcrowd screens.

---

# 34. Error Handling

Handle:

- no internet
- Supabase unavailable
- LiveKit connection failure
- Gemini failure
- microphone permission denied
- AI timeout
- no matching careers
- missing outcome data
- no counsellor available

Example:

"AI counselling is temporarily unavailable. You can still explore verified career information."

Do not display raw stack traces.

---

# 35. Environment Variables

Create `.env.example`.

Backend:

LIVEKIT_URL=
LIVEKIT_API_KEY=
LIVEKIT_API_SECRET=
GOOGLE_API_KEY=
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=

Flutter:

SUPABASE_URL=
SUPABASE_PUBLISHABLE_KEY=

Never commit `.env`.

Add secrets to `.gitignore`.

---

# 36. Project Structure

Create:

skillpath/
  mobile/
  admin/
  agent/
  supabase/
    migrations/
    functions/
    seed.sql
  docs/
  .env.example
  .gitignore
  README.md

Agent:

agent/
  main.py
  tools/
  prompts/
  services/
  config/
  requirements.txt

Keep AI logic out of Flutter.

---

# 37. Testing

Test:

- auth
- role routing
- RLS
- career search
- career comparison
- recommendation
- concern creation
- escalation
- LiveKit connection
- Gemini tool calls
- missing data
- AI fallback

---

# 38. README

Document:

- project overview
- architecture
- stack
- local setup
- environment variables
- Supabase setup
- LiveKit setup
- Gemini setup
- database migration
- seed data
- agent startup
- Flutter startup
- admin startup
- demo credentials
- troubleshooting

---

# 39. Development Order

Build in this order:

Phase 1:
Flutter + Supabase + Auth + navigation

Phase 2:
Database + migrations + RLS + seed data

Phase 3:
Career explorer + details + comparison + career path

Phase 4:
Family profile + concerns + decision progress

Phase 5:
LiveKit Agent + Gemini Live

Phase 6:
SkillPath tool/function calling

Phase 7:
Human escalation + counsellor dashboard

Phase 8:
Admin dashboard + analytics

Phase 9:
Tamil + accessibility + low-literacy mode

Phase 10:
Testing + polish + demo

Do not attempt everything in one file or one step.

---

# 40. Final Acceptance Criteria

The project is complete only when:

- Flutter app runs
- Supabase works
- Auth works
- RLS works
- Learner profile works
- Parent profile works
- Career data works
- Career search works
- Career comparison works
- Career paths work
- Family decision works
- LiveKit voice works
- Gemini Live works
- Gemini can call SkillPath tools
- Verified data is retrieved from Supabase
- AI does not fabricate statistics
- Tamil works
- English works
- Human escalation works
- Counsellor dashboard works
- Admin dashboard works
- Demo dataset works
- Error handling works
- README is complete
- Secrets are not committed

The final result must feel like a real MSDE-oriented public-service platform rather than a generic chatbot.

Start by creating the project structure, then implement each phase sequentially. After each phase, verify that the application builds before moving to the next phase.
