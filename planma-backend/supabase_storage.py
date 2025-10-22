import os
from supabase import create_client, Client

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
SUPABASE_BUCKET = "profile_pictures"  # or your bucket name

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def upload_profile_picture(file, filename):
    """Upload a file to Supabase Storage and return the public URL."""
    file_path = f"profile_pictures/{filename}"
    supabase.storage.from_(SUPABASE_BUCKET).upload(file_path, file, {"upsert": True})
    public_url = supabase.storage.from_(SUPABASE_BUCKET).get_public_url(file_path)
    return public_url
