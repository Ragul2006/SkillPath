import os
import json
import asyncio
import logging
from dotenv import load_dotenv

load_dotenv()

from livekit.agents import Agent, AgentServer, AgentSession, JobContext, cli
from livekit.plugins.google.beta import realtime

from tools.supabase_tools import all_tools

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("skillpath-agent")

SYSTEM_INSTRUCTIONS = """You are SkillPath, an AI career counsellor for vocational education.

You help learners and parents make informed career decisions.

You communicate in Tamil when the user speaks Tamil and English when the user speaks English. You effortlessly understand Tanglish (colloquial Tamil in English script or mixed Tamil-English).

You must be respectful, patient, non-judgmental, and easy to understand.

You are especially designed for parents who may have concerns about vocational education.

Common concerns include:
- Salary
- Job security
- Career growth
- Social perception
- Safety
- Training quality
- Distance from home
- Relocation
- Further education
- Whether a degree would be better

Never insult or discourage degree education.
Never claim that vocational education is automatically better.
Never pressure a parent or learner into selecting a particular career.

Your job is to explain the available options and help the family make an informed decision.

IMPORTANT DATA RULE:
Never invent salary information, placement rates, provider information, government statistics, or career progression information.
Use SkillPath database tools whenever factual career information is needed (search_trades, get_trade_outcome, get_training_providers, get_career_roles, get_career_path, compare_trades).
If information is unavailable, clearly say that the information is not available.

If a database record is synthetic/demo data, clearly tell the user:
"This is synthetic demo data used for the SkillPath prototype and is not official government statistics."

Use simple Tamil for parents with low digital familiarity.
Do not overload the user with technical terminology.
Keep voice replies natural, conversational, and concise (typically 2-4 sentences) so that real-time voice feels fluent.

If the user's concern cannot be adequately resolved, offer escalation to a human counsellor using create_escalation.

Always detect the user's concern category and sentiment during the conversation:
- Call record_concern when parent/learner raises concerns regarding income, job security, social perception, relocation, safety, etc.
- Call record_sentiment when notable sentiment is expressed (positive, neutral, concerned, negative, confused, hopeful, uncertain).
"""

server = AgentServer()


@server.rtc_session(agent_name="skillpath_counsellor")
async def entrypoint(ctx: JobContext):
    logger.info(f"[SkillPath Agent] New RTC session requested. Connecting to room: {ctx.room.name}")
    await ctx.connect()
    logger.info(f"[SkillPath Agent] Successfully connected to room: {ctx.room.name}")

    api_key = os.environ.get("GOOGLE_API_KEY") or os.environ.get("GEMINI_API_KEY")
    if not api_key:
        logger.error("[SkillPath Agent] GOOGLE_API_KEY / GEMINI_API_KEY is not set in environment!")

    # Load recent conversation messages from Supabase to preserve TEXT <-> VOICE context
    recent_history = ""
    supabase_url = os.environ.get("SUPABASE_URL")
    supabase_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")
    if supabase_url and supabase_key:
        try:
            from supabase import create_client
            sb = create_client(supabase_url, supabase_key)
            res = (
                sb.table("messages")
                .select("sender, message, created_at")
                .order("created_at", desc=True)
                .limit(10)
                .execute()
            )
            if res.data:
                rows = list(reversed(res.data))
                recent_history = "\n".join([f"{r['sender'].capitalize()}: {r['message']}" for r in rows])
                logger.info(f"[SkillPath Agent] Loaded {len(rows)} recent messages for voice session context.")
        except Exception as e:
            logger.info(f"[SkillPath Agent] Notice loading conversation history: {e}")

    session_instructions = SYSTEM_INSTRUCTIONS
    if recent_history:
        session_instructions += f"\n\nRECENT CONVERSATION HISTORY (Continue naturally from this context; do NOT introduce yourself again):\n{recent_history}"

    # Gemini Multimodal Live API model: gemini-2.5-flash-native-audio-preview-12-2025
    llm_model = realtime.RealtimeModel(
        api_key=api_key,
        model="gemini-2.5-flash-native-audio-preview-12-2025",
        instructions=session_instructions,
        voice="Puck",
        temperature=0.7,
    )

    agent = Agent(
        instructions=session_instructions,
        llm=llm_model,
        tools=all_tools,
    )

    logger.info("[VOICE] Gemini Live session starting")
    session = AgentSession(llm=llm_model)
    logger.info("[VOICE] Gemini Live connected")

    @session.on("user_state_changed")
    def on_user_state_changed(event):
        try:
            state = getattr(event, "new_state", str(event))
            logger.info(f"[VOICE] User state changed: {state}")
            if state == "speaking":
                logger.info("[VOICE] User speech detected")
                logger.info("[VOICE] User audio detected")
                asyncio.create_task(
                    ctx.room.local_participant.publish_data(
                        json.dumps({"type": "user_speaking"}).encode("utf-8")
                    )
                )
            elif state == "listening":
                logger.info("[VOICE] User speech ended")
                logger.info("[VOICE] Sending end-of-turn")
                logger.info("[VOICE] Gemini response started")
                asyncio.create_task(
                    ctx.room.local_participant.publish_data(
                        json.dumps({"type": "processing"}).encode("utf-8")
                    )
                )
        except Exception as e:
            logger.error(f"Error in on_user_state_changed: {e}")

    @session.on("agent_state_changed")
    def on_agent_state_changed(event):
        try:
            state = getattr(event, "new_state", str(event))
            logger.info(f"[VOICE] Agent state changed: {state}")
            if state == "speaking":
                logger.info("[VOICE] Gemini audio chunk received")
                logger.info("[VOICE] Playing AI audio")
                asyncio.create_task(
                    ctx.room.local_participant.publish_data(
                        json.dumps({"type": "ai_speaking"}).encode("utf-8")
                    )
                )
            elif state == "listening":
                logger.info("[VOICE] Gemini response completed")
                logger.info("[VOICE] AI turn completed")
                asyncio.create_task(
                    ctx.room.local_participant.publish_data(
                        json.dumps({"type": "turn_complete"}).encode("utf-8")
                    )
                )
        except Exception as e:
            logger.error(f"Error in on_agent_state_changed: {e}")

    @session.on("user_input_transcribed")
    def on_user_input_transcribed(event):
        try:
            transcript = getattr(event, "transcript", "")
            if transcript:
                logger.info(f"[VOICE] User speech transcribed: {transcript}")
                asyncio.create_task(
                    ctx.room.local_participant.publish_data(
                        json.dumps({"type": "user_transcript", "text": transcript}).encode("utf-8")
                    )
                )
        except Exception as e:
            logger.error(f"Error in on_user_input_transcribed: {e}")

    @ctx.room.on("participant_joined")
    def on_participant_joined(participant):
        logger.info(f"[VOICE] Participant joined room: {participant.identity}")

    logger.info("Starting Voice Agent Session with Gemini Realtime LLM...")
    await session.start(agent, room=ctx.room)
    logger.info("SkillPath AI Counsellor Agent is running and listening.")


if __name__ == "__main__":
    cli.run_app(server)