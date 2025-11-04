# supabase_storage.py
import os
from supabase import create_client

def get_supabase_client():
    SUPABASE_URL = os.getenv("SUPABASE_URL")
    SUPABASE_KEY = os.getenv("SUPABASE_KEY")
    if not SUPABASE_URL or not SUPABASE_KEY:
        raise Exception("Supabase credentials missing.")
    return create_client(SUPABASE_URL, SUPABASE_KEY)

def upload_profile_picture(file, filename):
    SUPABASE_BUCKET = os.getenv("SUPABASE_BUCKET")
    SUPABASE_URL = os.getenv("SUPABASE_URL")

    supabase = get_supabase_client()

    # Read file content
    file_bytes = file.read()
    content_type = getattr(file, "content_type", "application/octet-stream")

    # Perform upload (no bools in headers)
    res = supabase.storage.from_(SUPABASE_BUCKET).upload(
        filename,
        file_bytes,
        {"contentType": content_type},
    )

    if hasattr(res, "error") and res.error:
        raise Exception(res.error.message)

    # Construct public URL
    public_url = f"{SUPABASE_URL}/storage/v1/object/public/{SUPABASE_BUCKET}/{filename}"
    print(f"✅ Uploaded to Supabase: {public_url}")

    return public_url
