import os
import logging
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from livekit.api import AccessToken, VideoGrants, LiveKitAPI, CreateAgentDispatchRequest

load_dotenv()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("skillpath-token-server")

app = FastAPI(title="SkillPath Token & Counselling Server")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

LIVEKIT_API_KEY = os.environ.get("LIVEKIT_API_KEY")
LIVEKIT_API_SECRET = os.environ.get("LIVEKIT_API_SECRET")
LIVEKIT_URL = os.environ.get("LIVEKIT_URL")
GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY") or os.environ.get("GEMINI_API_KEY")
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

# Initialize Supabase client if available
supabase_client = None
if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:
    try:
        from supabase import create_client
        supabase_client = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        logger.info("Connected to Supabase from token server.")
    except Exception as e:
        logger.warning(f"Could not connect to Supabase: {e}")


@app.get("/token")
async def get_livekit_token(
    user_id: str = "guest_user",
    identity: str = None,
    room: str = "skillpath_counselling",
):
    """Generate a short-lived LiveKit access token and dispatch the AI agent."""
    if not LIVEKIT_API_KEY or not LIVEKIT_API_SECRET:
        raise HTTPException(status_code=500, detail="LiveKit credentials not configured")

    actual_user_id = identity or user_id
    try:
        at = (
            AccessToken(LIVEKIT_API_KEY, LIVEKIT_API_SECRET)
            .with_identity(actual_user_id)
            .with_grants(VideoGrants(room_join=True, room=room, can_publish=True, can_subscribe=True))
        )
        token = at.to_jwt()

        # Explicitly dispatch the SkillPath voice agent into the room
        try:
            http_url = LIVEKIT_URL.replace("wss://", "https://").replace("ws://", "http://")
            async with LiveKitAPI(http_url, LIVEKIT_API_KEY, LIVEKIT_API_SECRET) as lk:
                await lk.agent_dispatch.create_dispatch(
                    CreateAgentDispatchRequest(room=room, agent_name="skillpath_counsellor")
                )
                logger.info(f"Dispatched skillpath_counsellor agent into room '{room}'")
        except Exception as dispatch_err:
            logger.info(f"Agent dispatch notice: {dispatch_err}")

        return {"token": token, "url": LIVEKIT_URL, "room": room}
    except Exception as e:
        logger.error(f"Error generating token: {e}")
        raise HTTPException(status_code=500, detail=str(e))


class ChatMessageRequest(BaseModel):
    conversation_id: str
    message: str
    role: str = "parent"
    language: str = "ta"
    district: str = "Tamil Nadu"


@app.post("/chat")
async def process_chat_message(req: ChatMessageRequest):
    """Process a chat message with conversation memory and database grounding."""
    logger.info(f"[SkillPath] conversation_id: {req.conversation_id}")
    logger.info(f"[SkillPath] user message: {req.message}")

    # 1. Fetch conversation history from Supabase
    history = []
    if supabase_client and not req.conversation_id.startswith("local_conv_"):
        try:
            res = (
                supabase_client.table("messages")
                .select("sender, message, created_at")
                .eq("conversation_id", req.conversation_id)
                .order("created_at")
                .limit(20)
                .execute()
            )
            history = res.data or []
        except Exception as e:
            logger.error(f"Error reading history: {e}")

    logger.info(f"[SkillPath] history count: {len(history)}")

    # 2. Database search in public.trades
    clean_q = req.message.lower().strip()
    search_q = clean_q
    if "automotive" in clean_q or "repair" in clean_q or "mechanic" in clean_q or "car" in clean_q:
        search_q = "Automotive"
    elif "cnc" in clean_q:
        search_q = "CNC"
    elif "electri" in clean_q:
        search_q = "Electrician"
    elif "solar" in clean_q:
        search_q = "Solar"

    logger.info(f"[SkillPath] database search: {search_q}")
    matching_trades = []
    if supabase_client:
        try:
            t_res = (
                supabase_client.table("trades")
                .select("*")
                .ilike("name", f"%{search_q}%")
                .limit(2)
                .execute()
            )
            matching_trades = t_res.data or []
        except Exception as e:
            logger.error(f"Error searching trades: {e}")

    trade_names = [t.get("name") for t in matching_trades]
    logger.info(f"[SkillPath] matching trades: {', '.join(trade_names) if trade_names else 'None'}")

    # 3. Save user message to Supabase
    if supabase_client and not req.conversation_id.startswith("local_conv_"):
        try:
            supabase_client.table("messages").insert({
                "conversation_id": req.conversation_id,
                "sender": req.role,
                "message": req.message,
                "intent": "trade_search" if matching_trades else "general_counselling",
            }).execute()
        except Exception as e:
            logger.error(f"Error saving user message: {e}")

    # 4. Generate response with Gemini
    ai_reply = ""
    if GOOGLE_API_KEY:
        try:
            from google import genai
            client = genai.Client(api_key=GOOGLE_API_KEY)

            hist_text = "\n".join([f"{h['sender'].capitalize()}: {h['message']}" for h in history])
            grounding_text = ""
            for t in matching_trades:
                grounding_text += f"\nTrade: {t.get('name')} ({t.get('name_tamil')})\nSector: {t.get('sector')} | NSQF: {t.get('nsqf_level')}\nSkills: {t.get('skills')}"

            prompt = f"""You are SkillPath, an AI career counsellor for vocational education in Tamil Nadu.
SYSTEM INSTRUCTIONS:
- You help learners and parents make informed career decisions.
- Communicate in simple conversational Tamil if user speaks Tamil, or English if user speaks English.
- Be respectful, patient, non-judgmental, and easy to understand.
- Never invent salary, placement rates, provider info, or career progression.
- If data is demo data, mention: 'குறிப்பு: இது SkillPath prototype-க்காக உருவாக்கப்பட்ட synthetic/demo data. இது அதிகாரப்பூர்வ அரசு புள்ளிவிவரம் அல்ல.'
- Act as an empathetic counsellor, not a salesperson. When a parent gives a short follow-up answer like 'automotive repair', acknowledge it warmly, state a brief high-level point about the sector, and ask a relevant follow-up question (e.g. 10th or 12th pass, practical interest in engine/vehicle servicing).
- DO NOT restart with 'Hello! I am SkillPath AI Career Counsellor...'. Continue the conversation based on history.

ROLE: {req.role}
LANGUAGE: {'Tamil' if req.language == 'ta' else 'English'}

CONVERSATION HISTORY:
{hist_text if hist_text else '[First message]'}

DATABASE GROUNDING:
{grounding_text if grounding_text else 'No specific trade records found.'}

LATEST USER MESSAGE (Respond to this in light of the history above):
{req.message}
"""
            logger.info("[SkillPath] Gemini request created: (model: gemini-flash-latest)")
            res = client.models.generate_content(
                model="gemini-flash-latest",
                contents=prompt,
            )
            ai_reply = res.text.strip() if res.text else ""
        except Exception as e:
            logger.error(f"Gemini call error: {e}")

    if not ai_reply:
        if "automotive" in clean_q or "repair" in clean_q or "mechanic" in clean_q:
            ai_reply = (
                "சரி. உங்கள் மகனுக்கு Automotive Repair (வாகன பழுதுபார்ப்பு & மெக்கானிக்) துறையில் ஆர்வம் இருக்கிறது என்று புரிகிறது.\n\n"
                "அவருக்கு vehicle maintenance, engine work போன்ற practical வேலைகளில் ஆர்வம் இருக்கிறதா? மேலும், அவர் 10ஆம் வகுப்பு அல்லது 12ஆம் வகுப்பு முடித்திருக்கிறாரா?"
                if req.language == "ta"
                else "Understood. Automotive Repair is a crucial vocational discipline with strong regional workshops and dealership demand. Does your child enjoy hands-on vehicle maintenance and diagnostics? Has he completed 10th or 12th standard?"
            )
        else:
            ai_reply = (
                "உங்கள் பதிலை கவனித்தேன். உங்கள் மகனுக்கு பொருத்தமான தொழிற்பயிற்சி மற்றும் வேலை வாய்ப்புகளை அறிய, அவர் 10ஆம் அல்லது 12ஆம் வகுப்பு முடித்திருக்கிறாரா?"
                if req.language == "ta"
                else "Thank you for sharing. Could you let me know if your child has completed 10th or 12th standard so we can explore suitable pathways?"
            )

    logger.info(f"[SkillPath] Gemini response: {ai_reply}")

    # 5. Save AI response to Supabase
    if supabase_client and not req.conversation_id.startswith("local_conv_"):
        try:
            supabase_client.table("messages").insert({
                "conversation_id": req.conversation_id,
                "sender": "ai",
                "message": ai_reply,
            }).execute()
            logger.info(f"[SkillPath] AI message saved: {req.conversation_id}")
        except Exception as e:
            logger.error(f"Error saving AI response: {e}")

    return {"response": ai_reply, "conversation_id": req.conversation_id}


if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
