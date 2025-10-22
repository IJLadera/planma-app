# supabase_storage.py
import os
from supabase import create_client

def get_supabase_client():
    SUPABASE_URL = os.getenv("SUPABASE_URL")
    SUPABASE_KEY = os.getenv("SUPABASE_KEY")
    return create_client(SUPABASE_URL, SUPABASE_KEY)

def upload_profile_picture(file, filename):
    SUPABASE_BUCKET = os.getenv("SUPABASE_BUCKET")

    # ✅ Create the client only when needed
    supabase = get_supabase_client()

    # Upload the file to Supabase bucket
    res = supabase.storage.from_(SUPABASE_BUCKET).upload(filename, file)

    # Check for upload error
    if hasattr(res, "error") and res.error:
        raise Exception(res.error.message)

    # ✅ Return the public Supabase URL
    public_url = f"{os.getenv('SUPABASE_URL')}/storage/v1/object/public/{SUPABASE_BUCKET}/{filename}"
    return public_url
