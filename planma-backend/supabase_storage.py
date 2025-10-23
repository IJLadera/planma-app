# supabase_storage.py
import os
from supabase import create_client

def get_supabase_client():
    SUPABASE_URL = os.getenv("SUPABASE_URL")
    SUPABASE_KEY = os.getenv("SUPABASE_KEY")
    if not SUPABASE_URL or not SUPABASE_KEY:
        raise Exception("Supabase credentials missing. Check environment variables.")
    return create_client(SUPABASE_URL, SUPABASE_KEY)

def upload_profile_picture(file, filename):
    SUPABASE_BUCKET = os.getenv("SUPABASE_BUCKET")
    SUPABASE_URL = os.getenv("SUPABASE_URL")

    if not SUPABASE_BUCKET or not SUPABASE_URL:
        raise Exception("Supabase environment variables missing.")

    supabase = get_supabase_client()

    # Read bytes
    file_bytes = file.read()

    # Upload the file (allow overwrite)
    res = supabase.storage.from_(SUPABASE_BUCKET).upload(filename, file_bytes, {"upsert": True})

    if hasattr(res, "error") and res.error:
        raise Exception(res.error.message)

    # ✅ Force full Supabase public URL (instead of relative)
    supabase_url = SUPABASE_URL.rstrip("/")
    public_url = f"{supabase_url}/storage/v1/object/public/{SUPABASE_BUCKET}/{filename}"

    print(f"✅ Uploaded to Supabase: {public_url}")
    return public_url
