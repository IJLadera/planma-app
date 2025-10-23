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
    if not SUPABASE_BUCKET:
        raise Exception("SUPABASE_BUCKET not set in environment variables.")

    supabase = get_supabase_client()

    # ✅ Read file bytes
    file_bytes = file.read()

    # ✅ Upload file
    res = supabase.storage.from_(SUPABASE_BUCKET).upload(filename, file_bytes)

    if hasattr(res, "error") and res.error:
        raise Exception(res.error.message)

    # ✅ Return correctly formatted public URL
    supabase_url = os.getenv("SUPABASE_URL").rstrip("/")  # Remove trailing slash
    public_url = f"{supabase_url}/storage/v1/object/public/{SUPABASE_BUCKET}/{filename}"

    return public_url

