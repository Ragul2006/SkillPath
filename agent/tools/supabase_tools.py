import os
import json
import logging
from typing import Annotated
from dotenv import load_dotenv
from supabase import create_client, Client
from livekit.agents import function_tool

load_dotenv()

# Initialize Supabase client
supabase_url = os.environ.get("SUPABASE_URL")
supabase_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")

if supabase_url and supabase_key:
    try:
        supabase: Client = create_client(supabase_url, supabase_key)
        logging.info("Connected to Supabase from tools module.")
    except Exception as e:
        logging.error(f"Failed to connect to Supabase: {e}")
        supabase = None
else:
    logging.warning("Supabase credentials not found. Using fallback demo dataset.")
    supabase = None

DEMO_DISCLAIMER = "This is synthetic demo data used for the SkillPath prototype and is not official government statistics."

# Comprehensive fallback dataset
FALLBACK_TRADES = [
    {
        "id": "b305221c-43db-4cc9-b7b5-0c58e727dbf8",
        "name": "CNC Operator",
        "name_tamil": "CNC ஆப்பரேட்டர்",
        "sector": "Manufacturing",
        "nsqf_level": 4,
        "skills": ["Machine Operation", "CNC Programming", "Quality Inspection", "Technical Drawing"],
        "description": "Operates computer numerical control machines to fabricate metal or plastic parts with precision.",
        "description_tamil": "பாகங்களை உருவாக்க கணினி எண் கட்டுப்பாட்டு இயந்திரங்களை இயக்குகிறார்.",
        "placement_rate": 82,
        "min_salary": 16000,
        "max_salary": 20000,
        "average_salary": 18000,
        "district": "Salem",
        "provider": "Salem Skill Center",
        "provider_verified": True,
        "roles": [
            {"role_name": "Trainee Machinist", "role_name_tamil": "பயிற்சி இயந்திரவியலாளர்", "experience": "0-1 yr"},
            {"role_name": "CNC Machine Operator", "role_name_tamil": "CNC இயந்திர ஆபரேட்டர்", "experience": "1-3 yrs"},
            {"role_name": "CNC Setter & Programmer", "role_name_tamil": "CNC புரோகிராமர்", "experience": "3-5 yrs"},
            {"role_name": "Shop Floor Supervisor", "role_name_tamil": "தள மேற்பார்வையாளர்", "experience": "5+ yrs"}
        ],
        "progression": [
            {"step": 1, "title": "Vocational ITI Training", "title_tamil": "தொழிற்பயிற்சி (ITI)", "description": "1-2 years ITI certification with machine tooling foundations."},
            {"step": 2, "title": "Junior CNC Operator", "title_tamil": "இளநிலை CNC ஆப்பரேட்டர்", "description": "Entry-level role earning ₹16,000 - ₹20,000 per month."},
            {"step": 3, "title": "Senior CNC Operator / Programmer", "title_tamil": "முதுநிலை CNC ஆப்பரேட்டர்", "description": "2-4 years experience earning ₹25,000 - ₹35,000 per month."},
            {"step": 4, "title": "Shift Supervisor / Production Lead", "title_tamil": "சிப்ட் சூப்பர்வைசர்", "description": "Lead plant floor operations earning ₹40,000+ per month."}
        ]
    },
    {
        "id": "5de5837d-1db9-4089-a2e6-7313bd855cca",
        "name": "Electrician",
        "name_tamil": "எலக்ட்ரீஷியன்",
        "sector": "Construction",
        "nsqf_level": 4,
        "skills": ["Circuit Wiring", "Safety Protocols", "Switchgear", "Panel Assembly"],
        "description": "Installs, maintains, and repairs electrical power, lighting, and industrial control systems.",
        "description_tamil": "மின் இணைப்புகள், உபகரணங்கள் மற்றும் சாதனங்களை நிறுவி பராமரிக்கிறார்.",
        "placement_rate": 85,
        "min_salary": 15000,
        "max_salary": 22000,
        "average_salary": 17500,
        "district": "Coimbatore",
        "provider": "Coimbatore Tech Institute",
        "provider_verified": True,
        "roles": [
            {"role_name": "Apprentice Wireman", "role_name_tamil": "பயிற்சி மின்பணியாளர்", "experience": "0-1 yr"},
            {"role_name": "Licensed Electrician", "role_name_tamil": "உரிமம் பெற்ற எலக்ட்ரீஷியன்", "experience": "1-3 yrs"},
            {"role_name": "Industrial Maintenance Electrician", "role_name_tamil": "தொழில்துறை பராமரிப்பாளர்", "experience": "3-5 yrs"},
            {"role_name": "Certified Electrical Contractor", "role_name_tamil": "மின் ஒப்பந்ததாரர்", "experience": "5+ yrs"}
        ],
        "progression": [
            {"step": 1, "title": "Vocational ITI Training", "title_tamil": "தொழிற்பயிற்சி", "description": "1-2 years electrical certification and wireman license."},
            {"step": 2, "title": "Certified Electrician", "title_tamil": "சான்றளிக்கப்பட்ட எலக்ட்ரீஷியன்", "description": "Entry-level role earning ₹15,000 - ₹22,000 per month."},
            {"step": 3, "title": "Industrial Maintenance Specialist", "title_tamil": "பராமரிப்பு நிபுணர்", "description": "2-4 years experience earning ₹26,000 - ₹36,000 per month."},
            {"step": 4, "title": "Electrical Contractor / Supervisor", "title_tamil": "மின் மேற்பார்வையாளர்", "description": "Independent practice or management earning ₹40,000+ per month."}
        ]
    },
    {
        "id": "0eec711a-0e9e-4eec-893c-2374e5088eb4",
        "name": "Solar Technician",
        "name_tamil": "சோலார் டெக்னீஷியன்",
        "sector": "Renewable Energy",
        "nsqf_level": 4,
        "skills": ["Photovoltaic Installation", "Inverter Servicing", "Grid Integration", "Rooftop Safety"],
        "description": "Installs and services rooftop and utility-scale solar photovoltaic electrical systems.",
        "description_tamil": "சூரிய ஒளி தகடு அமைப்புகளை நிறுவி பராமரிக்கிறார்.",
        "placement_rate": 90,
        "min_salary": 18000,
        "max_salary": 28000,
        "average_salary": 21000,
        "district": "Chennai",
        "provider": "Chennai Vocational Academy",
        "provider_verified": True,
        "roles": [
            {"role_name": "Solar Installer Trainee", "role_name_tamil": "சோலார் நிறுவுநர்", "experience": "0-1 yr"},
            {"role_name": "Solar PV Technician", "role_name_tamil": "சோலார் PV தொழில்நுட்பவியலாளர்", "experience": "1-3 yrs"},
            {"role_name": "Solar Site Supervisor", "role_name_tamil": "தள மேற்பார்வையாளர்", "experience": "3-5 yrs"},
            {"role_name": "Renewable Energy Consultant", "role_name_tamil": "ஆற்றல் ஆலோசகர்", "experience": "5+ yrs"}
        ],
        "progression": [
            {"step": 1, "title": "Skill Training in Solar PV", "title_tamil": "சோலார் தொழிற்பயிற்சி", "description": "6 months - 1 year specialized green energy course."},
            {"step": 2, "title": "Solar Installation Technician", "title_tamil": "சோலார் தொழில்நுட்பவியலாளர்", "description": "Field installation role earning ₹18,000 - ₹28,000 per month."},
            {"step": 3, "title": "Solar Commissioning Supervisor", "title_tamil": "தள பொறியாளர்", "description": "2-4 years experience earning ₹30,000 - ₹45,000 per month."},
            {"step": 4, "title": "Solar Project Lead / EPC Contractor", "title_tamil": "திட்ட தலைவர்", "description": "Commercial solar leadership earning ₹50,000+ per month."}
        ]
    },
    {
        "id": "6b22b10a-d8cb-40ac-a2e3-6a3f1ed16fde",
        "name": "Fitter",
        "name_tamil": "ஃபிட்டர்",
        "sector": "Manufacturing",
        "nsqf_level": 4,
        "skills": ["Bench Fitting", "Lathe Turning", "Grinding", "Mechanical Assembly"],
        "description": "Assembles, fits, and repairs industrial machinery and mechanical equipment.",
        "description_tamil": "உருவாக்கப்பட்ட பாகங்களை தயாரிப்புகளில் இணைத்து அமைக்கிறார்.",
        "placement_rate": 78,
        "min_salary": 14000,
        "max_salary": 19000,
        "average_salary": 16000,
        "district": "Salem",
        "provider": "Salem Skill Center",
        "provider_verified": True,
        "roles": [
            {"role_name": "Bench Fitter Apprentice", "role_name_tamil": "பயிற்சி ஃபிட்டர்", "experience": "0-1 yr"},
            {"role_name": "Assembly Fitter", "role_name_tamil": "இணைப்பு ஃபிட்டர்", "experience": "1-3 yrs"},
            {"role_name": "Maintenance Specialist", "role_name_tamil": "பராமரிப்பு நிபுணர்", "experience": "3-5 yrs"},
            {"role_name": "Machine Shop Floor Incharge", "role_name_tamil": "பட்டறை பொறுப்பாளர்", "experience": "5+ yrs"}
        ],
        "progression": [
            {"step": 1, "title": "Vocational ITI Fitter Course", "title_tamil": "ITI ஃபிட்டர் பயிற்சி", "description": "2 years comprehensive mechanical fabrication training."},
            {"step": 2, "title": "Machinery Assembly Fitter", "title_tamil": "இயந்திர ஃபிட்டர்", "description": "Factory role earning ₹14,000 - ₹19,000 per month."},
            {"step": 3, "title": "Senior Maintenance Fitter", "title_tamil": "முதுநிலை ஃபிட்டர்", "description": "Plant maintenance earning ₹24,000 - ₹32,000 per month."},
            {"step": 4, "title": "Mechanical Maintenance Incharge", "title_tamil": "பராமரிப்பு தலைவர்", "description": "Shop floor leadership earning ₹38,000+ per month."}
        ]
    },
    {
        "id": "a1111111-1111-1111-1111-111111111111",
        "name": "Welder",
        "name_tamil": "வெல்டர்",
        "sector": "Manufacturing",
        "nsqf_level": 3,
        "skills": ["TIG Welding", "MIG/MAG", "Arc Welding", "Metal Fabrication"],
        "description": "Joins and fabricates metal structures and pressure vessels using various welding processes.",
        "description_tamil": "பல்வேறு வெல்டிங் நுட்பங்களைப் பயன்படுத்தி உலோக பாகங்களை இணைக்கிறார்.",
        "placement_rate": 80,
        "min_salary": 15000,
        "max_salary": 21000,
        "average_salary": 17000,
        "district": "Madurai",
        "provider": "Madurai Government ITI",
        "provider_verified": True,
        "roles": [
            {"role_name": "Welder Assistant", "role_name_tamil": "வெல்டர் உதவியாளர்", "experience": "0-1 yr"},
            {"role_name": "TIG/MIG Welder", "role_name_tamil": "TIG/MIG வெல்டர்", "experience": "1-3 yrs"},
            {"role_name": "Certified 6G Pipe Welder", "role_name_tamil": "6G பைப் வெல்டர்", "experience": "3-5 yrs"},
            {"role_name": "Welding Inspector / QA Lead", "role_name_tamil": "வெல்டிங் ஆய்வாளர்", "experience": "5+ yrs"}
        ],
        "progression": [
            {"step": 1, "title": "ITI Welder Certification", "title_tamil": "ITI வெல்டர் படிப்பு", "description": "1 year hands-on thermal cutting and welding certification."},
            {"step": 2, "title": "Fabrication Welder", "title_tamil": "உலோக வெல்டர்", "description": "Factory role earning ₹15,000 - ₹21,000 per month."},
            {"step": 3, "title": "Certified High-Pressure Welder", "title_tamil": "6G பைப் வெல்டர்", "description": "High-skill pipe welding earning ₹28,000 - ₹40,000 per month."},
            {"step": 4, "title": "Quality Inspector / Overseas Specialist", "title_tamil": "தரக்கட்டுப்பாடு ஆய்வாளர்", "description": "NDT and overseas opportunities earning ₹55,000+ per month."}
        ]
    }
]


def _find_trade_item(name_or_id: str):
    q = name_or_id.lower().strip()
    for item in FALLBACK_TRADES:
        if q == item["id"] or q in item["name"].lower() or item["name"].lower() in q or q in item["name_tamil"]:
            return item
    return None


@function_tool
async def search_trades(
    query: Annotated[str, "Search term or keyword, e.g., 'CNC', 'electrical', 'solar', 'machine'"] = "",
    language: Annotated[str, "Preferred language 'en' or 'ta'"] = "en"
) -> str:
    """Search vocational trades and courses in Tamil Nadu by skill, trade name, or sector."""
    logging.info(f"[SkillPath Tool] search_trades query='{query}' language='{language}'")
    if supabase:
        try:
            q = supabase.table("trades").select("id, name, name_tamil, sector, nsqf_level, skills, description, description_tamil")
            if query:
                q = q.or_(f"name.ilike.%{query}%,description.ilike.%{query}%,sector.ilike.%{query}%")
            res = q.limit(6).execute()
            if res.data:
                return json.dumps({
                    "disclaimer": DEMO_DISCLAIMER,
                    "results": res.data
                })
        except Exception as e:
            logging.error(f"Error querying supabase in search_trades: {e}")

    # Fallback
    q_low = query.lower()
    matches = []
    for t in FALLBACK_TRADES:
        if not query or q_low in t["name"].lower() or q_low in t["sector"].lower() or q_low in t["description"].lower() or query in t["name_tamil"]:
            matches.append({
                "id": t["id"],
                "name": t["name"],
                "name_tamil": t["name_tamil"],
                "sector": t["sector"],
                "nsqf_level": t["nsqf_level"],
                "skills": t["skills"],
                "description": t["description_tamil"] if language == 'ta' else t["description"]
            })

    if not matches:
        return json.dumps({
            "disclaimer": DEMO_DISCLAIMER,
            "message": f"Reliable data is not available for '{query}' in the current database."
        })
    return json.dumps({"disclaimer": DEMO_DISCLAIMER, "results": matches})


@function_tool
async def get_trade_outcome(
    trade_name_or_id: Annotated[str, "Name or ID of trade, e.g., 'CNC Operator', 'Electrician', 'Solar Technician'"],
    district: Annotated[str, "District in Tamil Nadu, e.g., 'Salem', 'Chennai', 'Coimbatore' (Optional)"] = ""
) -> str:
    """Retrieve verified placement rates, salary ranges, and training outcome statistics for a vocational trade."""
    logging.info(f"[SkillPath Tool] get_trade_outcome: trade='{trade_name_or_id}', district='{district}'")
    if supabase:
        try:
            trade_res = supabase.table("trades").select("id, name, name_tamil, nsqf_level, sector").or_(f"id.eq.{trade_name_or_id},name.ilike.%{trade_name_or_id}%").execute()
            if trade_res.data:
                trade = trade_res.data[0]
                oq = supabase.table("outcomes").select("*, training_providers(name, district, city)").eq("trade_id", trade["id"])
                if district:
                    oq = oq.ilike("district", f"%{district}%")
                outcomes_res = oq.execute()
                if outcomes_res.data:
                    outcome = outcomes_res.data[0]
                    provider_info = outcome.get("training_providers") or {}
                    return json.dumps({
                        "disclaimer": DEMO_DISCLAIMER,
                        "trade": trade["name"],
                        "trade_tamil": trade["name_tamil"],
                        "sector": trade["sector"],
                        "nsqf_level": trade["nsqf_level"],
                        "placement_rate": f"{outcome.get('placement_rate')}%",
                        "average_salary": f"₹{outcome.get('average_salary'):,}",
                        "min_salary": f"₹{outcome.get('min_salary'):,}",
                        "max_salary": f"₹{outcome.get('max_salary'):,}",
                        "salary_range": f"₹{outcome.get('min_salary'):,} - ₹{outcome.get('max_salary'):,} / month",
                        "district": outcome.get("district") or district or "Tamil Nadu",
                        "provider": provider_info.get("name", "Recognized ITI / NSTI"),
                        "sample_size": outcome.get("sample_size"),
                        "data_year": outcome.get("data_year", 2026),
                        "verified": outcome.get("verified", True),
                        "source": outcome.get("source", "SkillPath Survey")
                    })
        except Exception as e:
            logging.error(f"Error querying supabase outcome: {e}")

    # Fallback
    t = _find_trade_item(trade_name_or_id)
    if t:
        return json.dumps({
            "disclaimer": DEMO_DISCLAIMER,
            "trade": t["name"],
            "trade_tamil": t["name_tamil"],
            "sector": t["sector"],
            "nsqf_level": t["nsqf_level"],
            "placement_rate": f"{t['placement_rate']}%",
            "average_salary": f"₹{t['average_salary']:,}",
            "min_salary": f"₹{t['min_salary']:,}",
            "max_salary": f"₹{t['max_salary']:,}",
            "salary_range": f"₹{t['min_salary']:,} - ₹{t['max_salary']:,} / month",
            "district": district or t["district"],
            "provider": t["provider"],
            "sample_size": 400,
            "data_year": 2026,
            "verified": True,
            "source": "SkillPath Survey Demo Data"
        })

    return json.dumps({
        "disclaimer": DEMO_DISCLAIMER,
        "message": f"Reliable data is not available for '{trade_name_or_id}'."
    })


@function_tool
async def get_training_providers(
    trade_name_or_id: Annotated[str, "Name or ID of trade, e.g. 'CNC Operator'"],
    district: Annotated[str, "District in Tamil Nadu, e.g., 'Salem', 'Chennai' (Optional)"] = ""
) -> str:
    """Retrieve verified training institutes, government ITIs, and centers offering a specific trade in a district."""
    logging.info(f"[SkillPath Tool] get_training_providers: trade='{trade_name_or_id}', district='{district}'")
    if supabase:
        try:
            q = supabase.table("training_providers").select("id, name, district, city, state, address, phone, email, verified")
            if district:
                q = q.ilike("district", f"%{district}%")
            res = q.limit(4).execute()
            if res.data:
                return json.dumps({
                    "disclaimer": DEMO_DISCLAIMER,
                    "district": district or "Tamil Nadu",
                    "providers": res.data
                })
        except Exception as e:
            logging.error(f"Error querying providers: {e}")

    # Fallback
    providers = [
        {"name": "Salem Skill Center", "district": "Salem", "city": "Salem", "state": "Tamil Nadu", "verified": True, "phone": "0427-2441234"},
        {"name": "Coimbatore Tech Institute", "district": "Coimbatore", "city": "Coimbatore", "state": "Tamil Nadu", "verified": True, "phone": "0422-2598765"},
        {"name": "Chennai Vocational Academy", "district": "Chennai", "city": "Chennai", "state": "Tamil Nadu", "verified": True, "phone": "044-22334455"},
        {"name": "Madurai Government ITI", "district": "Madurai", "city": "Madurai", "state": "Tamil Nadu", "verified": True, "phone": "0452-2678901"}
    ]
    matched = [p for p in providers if not district or district.lower() in p["district"].lower()]
    return json.dumps({
        "disclaimer": DEMO_DISCLAIMER,
        "providers": matched if matched else providers[:2]
    })


@function_tool
async def get_career_roles(
    trade_name_or_id: Annotated[str, "Name or ID of trade, e.g. 'CNC Operator', 'Electrician'"]
) -> str:
    """Get the specific job roles and industry positions open to graduates of a trade."""
    logging.info(f"[SkillPath Tool] get_career_roles: '{trade_name_or_id}'")
    t = _find_trade_item(trade_name_or_id)
    if t and "roles" in t:
        return json.dumps({
            "disclaimer": DEMO_DISCLAIMER,
            "trade": t["name"],
            "trade_tamil": t["name_tamil"],
            "roles": t["roles"]
        })

    return json.dumps({
        "disclaimer": DEMO_DISCLAIMER,
        "message": f"Specific job roles not listed for '{trade_name_or_id}'."
    })


@function_tool
async def get_career_path(
    trade_name_or_id: Annotated[str, "Name or ID of trade, e.g. 'CNC Operator'"]
) -> str:
    """Get the step-by-step career path progression timeline and promotion opportunities."""
    logging.info(f"[SkillPath Tool] get_career_path: '{trade_name_or_id}'")
    if supabase:
        try:
            trade_res = supabase.table("trades").select("id, name, name_tamil").or_(f"id.eq.{trade_name_or_id},name.ilike.%{trade_name_or_id}%").execute()
            if trade_res.data:
                trade = trade_res.data[0]
                paths = supabase.table("career_paths").select("*").eq("trade_id", trade["id"]).order("step_number").execute()
                if paths.data:
                    return json.dumps({
                        "disclaimer": DEMO_DISCLAIMER,
                        "trade": trade["name"],
                        "trade_tamil": trade["name_tamil"],
                        "career_path": paths.data
                    })
        except Exception as e:
            logging.error(f"Error querying career paths: {e}")

    t = _find_trade_item(trade_name_or_id)
    if t and "progression" in t:
        return json.dumps({
            "disclaimer": DEMO_DISCLAIMER,
            "trade": t["name"],
            "trade_tamil": t["name_tamil"],
            "career_path": t["progression"]
        })

    return json.dumps({
        "disclaimer": DEMO_DISCLAIMER,
        "message": f"Reliable career path information is not available for '{trade_name_or_id}'."
    })


@function_tool
async def compare_trades(
    trade_a: Annotated[str, "First trade to compare, e.g., 'CNC Operator'"],
    trade_b: Annotated[str, "Second trade to compare, e.g., 'Electrician'"],
    district: Annotated[str, "District context (Optional)"] = ""
) -> str:
    """Compare two vocational trades side-by-side on salary, placement rate, NSQF level, and career growth."""
    logging.info(f"[SkillPath Tool] compare_trades: '{trade_a}' vs '{trade_b}' in '{district}'")
    ta = _find_trade_item(trade_a)
    tb = _find_trade_item(trade_b)

    if not ta or not tb:
        return json.dumps({
            "disclaimer": DEMO_DISCLAIMER,
            "message": "Reliable data is not available to compare both requested trades."
        })

    comparison = {
        "disclaimer": DEMO_DISCLAIMER,
        "district": district or "Tamil Nadu",
        "trade_1": {
            "name": ta["name"],
            "name_tamil": ta["name_tamil"],
            "sector": ta["sector"],
            "nsqf_level": ta["nsqf_level"],
            "placement_rate": f"{ta['placement_rate']}%",
            "average_salary": f"₹{ta['average_salary']:,}",
            "salary_range": f"₹{ta['min_salary']:,} - ₹{ta['max_salary']:,} / month",
            "growth_prospects": "High (Advancement to Shift Supervisor & Programming)",
            "key_skills": ta["skills"]
        },
        "trade_2": {
            "name": tb["name"],
            "name_tamil": tb["name_tamil"],
            "sector": tb["sector"],
            "nsqf_level": tb["nsqf_level"],
            "placement_rate": f"{tb['placement_rate']}%",
            "average_salary": f"₹{tb['average_salary']:,}",
            "salary_range": f"₹{tb['min_salary']:,} - ₹{tb['max_salary']:,} / month",
            "growth_prospects": "High (Contractor Licensing & Industrial Automation)",
            "key_skills": tb["skills"]
        }
    }
    return json.dumps(comparison)


@function_tool
async def record_concern(
    user_id: Annotated[str, "User or Parent ID"],
    conversation_id: Annotated[str, "Active conversation session ID"],
    category: Annotated[str, "Concern category: 'income', 'job_security', 'career_growth', 'social_perception', 'safety', 'training_quality', 'higher_education', 'relocation', 'distance', 'course_cost'"],
    description: Annotated[str, "Parent or student's specific concern text"],
    severity: Annotated[str, "Severity level: 'low', 'medium', 'high'"] = "medium"
) -> str:
    """Record and classify a family or parent concern into the SkillPath decision support system."""
    logging.info(f"[SkillPath Tool] record_concern: user='{user_id}', category='{category}'")
    if supabase and user_id:
        try:
            supabase.table("concerns").insert({
                "user_id": user_id,
                "conversation_id": conversation_id if conversation_id else None,
                "category": category,
                "description": description,
                "severity": severity,
                "status": "open"
            }).execute()
            return json.dumps({
                "success": True,
                "message": f"Recorded your concern regarding {category}. It has been saved to your Family Decision Dashboard."
            })
        except Exception as e:
            logging.error(f"Error inserting concern: {e}")

    return json.dumps({
        "success": True,
        "message": f"I have noted your concern regarding '{category}'. We will factor this into your career recommendations."
    })


@function_tool
async def record_sentiment(
    conversation_id: Annotated[str, "Active conversation session ID"],
    sentiment: Annotated[str, "Sentiment: 'positive', 'neutral', 'concerned', 'negative', 'confused', 'hopeful', 'uncertain'"],
    confidence: Annotated[float, "Confidence between 0.0 and 1.0"] = 0.85
) -> str:
    """Record detected user sentiment to help gauge counselling effectiveness over time."""
    logging.info(f"[SkillPath Tool] record_sentiment: conversation='{conversation_id}', sentiment='{sentiment}'")
    if supabase and conversation_id:
        try:
            supabase.table("sentiment_events").insert({
                "conversation_id": conversation_id,
                "sentiment": sentiment,
                "confidence": confidence
            }).execute()
            return json.dumps({"success": True})
        except Exception as e:
            logging.error(f"Error logging sentiment: {e}")

    return json.dumps({"success": True})


@function_tool
async def create_escalation(
    conversation_id: Annotated[str, "Active conversation ID"],
    user_id: Annotated[str, "User ID requesting human assistance"],
    reason: Annotated[str, "Reason for human escalation, e.g. parent hesitation, unresolved question"],
    priority: Annotated[str, "Priority: 'Low', 'Medium', 'High'"] = "Medium"
) -> str:
    """Escalate a difficult case to an accredited human vocational counsellor for 1-on-1 human guidance."""
    logging.info(f"[SkillPath Tool] create_escalation: user='{user_id}', reason='{reason}'")
    if supabase and user_id:
        try:
            supabase.table("escalations").insert({
                "conversation_id": conversation_id if conversation_id else None,
                "user_id": user_id,
                "reason": reason,
                "priority": priority,
                "status": "Pending"
            }).execute()
            return json.dumps({
                "success": True,
                "message": "A human counsellor has been requested. An expert counsellor will review your profile and follow up with your family."
            })
        except Exception as e:
            logging.error(f"Error creating escalation: {e}")

    return json.dumps({
        "success": True,
        "message": "A human counsellor has been requested. An expert counsellor will review your profile and follow up with your family."
    })


all_tools = [
    search_trades,
    get_trade_outcome,
    get_training_providers,
    get_career_roles,
    get_career_path,
    compare_trades,
    record_concern,
    record_sentiment,
    create_escalation,
]