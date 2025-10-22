import os
from supabase import create_client, Client

def get_supabase_client() -> Client:
    SUPABASE_URL = os.getenv("SUPABASE_URL")
    SUPABASE_KEY = os.getenv("SUPABASE_KEY")

    if not SUPABASE_URL or not SUPABASE_KEY:
        raise ValueError("Missing Supabase credentials. Check your environment variables.")

    return create_client(SUPABASE_URL, SUPABASE_KEY)

def upload_profile_picture(file_path: str, file_name: str, bucket_name: str = "profile_pictures"):
    supabase = get_supabase_client()  # ✅ Create client when function runs
    with open(file_path, "rb") as f:
        res = supabase.storage.from_(bucket_name).upload(file_name, f, {"upsert": True})
    return res
