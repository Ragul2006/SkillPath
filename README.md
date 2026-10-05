# SkillPath — AI-Enabled Career Counselling Platform

**Tagline:** Your Skills. Your Career. Your Path.

SkillPath is a comprehensive hackathon MVP for vocational career counselling in Tamil Nadu. It combines:
- **AI voice counselling** powered by Gemini Live + LiveKit
- **Verified career outcome data** (placement rates, salaries, providers)
- **Family decision support** addressing parental concerns
- **Human escalation** to connect with qualified counsellors

## Quick Start

### 1. Prerequisites

- Flutter SDK (3.13+)
- Python 3.11+
- Supabase account
- LiveKit Cloud account
- Google AI Studio (Gemini API key)

### 2. Environment Setup

Copy `.env.example` to `.env`:

```bash
cp .env.example .env
```

Fill in your credentials:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key

LIVEKIT_URL=your_livekit_url
LIVEKIT_API_KEY=your_api_key
LIVEKIT_API_SECRET=your_api_secret

GOOGLE_API_KEY=your_gemini_key
```

### 3. Database Setup

**Option A: Using Supabase Dashboard**

1. Open your Supabase project
2. Go to **SQL Editor**
3. Run migrations in this order:
   - `supabase/migrations/001_profiles.sql`
   - `supabase/migrations/002_user_profiles.sql`
   - `supabase/migrations/003_career_tables.sql`
   - `supabase/migrations/004_agent_tables.sql`
4. Run `supabase/seed.sql` to load demo data

**Option B: Using Supabase CLI**

```bash
supabase db push
```

### 4. Run Flutter Mobile App

```bash
cd .
flutter pub get
flutter run
```

The app starts at the onboarding screen. Create test accounts:
- **Learner:** Any email, password "test123", select "Student" role
- **Parent:** Any email, password "test123", select "Parent" role

### 5. Run LiveKit Agent

```bash
cd agent
python -m venv .venv

# Windows
.venv\Scripts\activate

# macOS/Linux
source .venv/bin/activate

pip install -r requirements.txt
python main.py
```

The agent will listen for connections from LiveKit rooms.

### 6. Run Token Server (Optional)

For production-grade token generation:

```bash
cd agent
python token_server.py
```

The token server runs on `http://localhost:8000` and exposes:
- `GET /token?user_id=<user_id>&room=<room_name>`

## Architecture

```
Flutter App (mobile)
    ↓
Supabase Auth + Database
    ↓
LiveKit Room
    ↓
Python Agent
    ↓
Gemini Live API + SkillPath Tools
    ↓
Supabase Queries
    ↓
Verified Career Data
```

## Key Features

### 1. Career Explorer
- Search and filter 10+ vocational trades
- View verified placement rates and salary ranges
- Explore career progression paths
- Compare up to 4 careers side-by-side

### 2. AI Voice Counsellor
- Real-time voice conversation in English or Tamil
- Answers only with verified data from Supabase
- Calls backend tools for:
  - `get_trade_outcome()` — placement & salary
  - `search_careers()` — career discovery
  - `compare_careers()` — multi-career analysis
  - `get_career_path()` — progression timeline
  - `get_training_providers()` — nearby providers
  - `record_concern()` — capture family worries
  - `create_escalation()` — request human counsellor

### 3. Family Decision Support
- Learner preference + parent concerns side-by-side
- Verified evidence cards
- Decision progress tracker
- Safe escalation to human counsellor

### 4. Human Escalation
- Request counsellor with reason + priority
- Status tracking: Pending → Assigned → In Progress → Resolved
- Counsellor dashboard for managing requests
- Admin analytics on concern distribution

### 5. Localization
- English & Tamil support
- Voice input/output in both languages
- Tamil Nadu district selections
- Regional salary & placement data

## Demo Scenario

This is the primary 2-3 minute hackathon demo:

1. **Learner says:** "I want to join CNC training."
2. **Parent says:** "Will he get a good job?"
3. **SkillPath AI** retrieves verified data via `get_trade_outcome("CNC Operator")`
4. **Response:** "82% placement rate, ₹16K–₹20K starting salary, 420 sample size"
5. **Show:** Career progression timeline
6. **Offer:** "Would you like to speak with a human counsellor?"
7. **Parent says:** "Yes"
8. **Admin dashboard** receives escalation immediately

## Demo Accounts

Pre-created test users (run seed.sql):

| Role | Email | Password |
|------|-------|----------|
| Learner | learner@test.com | test123 |
| Parent | parent@test.com | test123 |
| Counsellor | counsellor@test.com | test123 |
| Admin | admin@test.com | test123 |

## Project Structure

```
skillpath/
├── lib/                          # Flutter app
│   ├── main.dart
│   ├── core/                     # Theme, services, router
│   ├── providers/                # Riverpod state
│   ├── screens/                  # UI screens
│   │   ├── onboarding/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── careers/
│   │   ├── comparison/
│   │   ├── counsellor/           # AI voice UI
│   │   ├── family/
│   │   ├── escalation/
│   │   ├── profile/
│   │   └── settings/
│   └── models/                   # Data structures
│
├── agent/                        # Python LiveKit Agent
│   ├── main.py                   # Entry point
│   ├── token_server.py           # JWT generation
│   ├── requirements.txt
│   ├── tools/                    # Backend functions
│   │   └── supabase_tools.py
│   ├── prompts/
│   ├── services/
│   └── .env
│
├── supabase/                     # Database
│   ├── migrations/               # SQL schemas
│   │   ├── 001_profiles.sql
│   │   ├── 002_user_profiles.sql
│   │   ├── 003_career_tables.sql
│   │   └── 004_agent_tables.sql
│   ├── functions/                # Edge functions
│   ├── seed.sql                  # Demo data
│   └── config.toml
│
├── .env.example
├── .gitignore
├── pubspec.yaml
└── README.md
```

## Security & Data Privacy

### What We Do NOT Store
- Real user PII beyond email
- Audio recordings of conversations
- Payment or sensitive financial data
- Children's detailed personal information

### What We DO Protect
- Role-based access via Supabase RLS
- API secrets never in Flutter app
- LiveKit API secret server-side only
- Gemini API key server-side only
- Short-lived access tokens (15 min)

### Demo Data Labeling
All demo datasets are explicitly labeled:
> "Demo dataset provided for hackathon evaluation."

We never claim fake salary/placement data as official government statistics.

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Manual Testing Checklist
- [ ] Auth flow (signup, login, logout, forgot password)
- [ ] Career search & filters
- [ ] Career details & progression
- [ ] Career comparison
- [ ] Family decision UI
- [ ] Voice connection to AI
- [ ] Voice conversation (English & Tamil)
- [ ] AI tool calling (verify data retrieval)
- [ ] Escalation creation
- [ ] Counsellor dashboard
- [ ] Admin analytics
- [ ] Offline fallback

## Troubleshooting

### "Database connection failed"
- Check Supabase credentials in `.env`
- Verify migrations were run
- Check RLS policies are enabled

### "LiveKit connection failed"
- Verify `LIVEKIT_URL` is correct
- Check token generation endpoint
- Ensure agent is running

### "AI is not responding"
- Verify `GOOGLE_API_KEY` in agent `.env`
- Check agent logs for errors
- Verify Gemini API is not rate-limited

### "Agent crashes on startup"
- Ensure Python 3.11+
- Run `pip install -r requirements.txt` again
- Check for missing LiveKit/Gemini package versions

## Production Roadmap

For post-hackathon production:

1. **Authentication:** Add Google Sign-In, phone OTP
2. **Data:** Replace demo data with official government sources
3. **Scaling:** Deploy agent to cloud (Render, Railway, AWS Lambda)
4. **Analytics:** Add comprehensive logging & audit trails
5. **Accessibility:** Full WCAG 2.1 AA compliance testing
6. **Multilingual:** Add more Indian languages (Telugu, Kannada, Marathi)
7. **Admin Web:** Build React/Next.js dashboard for counsellors & admins
8. **Offline Mode:** Enable offline exploration of careers
9. **Notifications:** Push notifications for escalation updates
10. **Testing:** Comprehensive test coverage (unit, integration, E2E)

## References

- [Flutter](https://flutter.dev)
- [Supabase](https://supabase.com)
- [LiveKit](https://livekit.io)
- [Gemini Live API](https://ai.google.dev/docs/gemini-api/realtime/start)
- [Material Design 3](https://m3.material.io)

## License

This is a hackathon project. Use for educational purposes.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review logs (Flutter console, agent terminal)
3. Consult LiveKit/Supabase documentation
4. Ask a human 🙂
