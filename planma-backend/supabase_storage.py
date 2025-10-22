from supabase import create_client
import os

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def upload_profile_picture(file, filename):
    # Upload the file to Supabase bucket
    res = supabase.storage.from_("profile_pictures").upload(filename, file)
    
    # Check for upload error
    if hasattr(res, "error") and res.error:
        raise Exception(res.error.message)

    # ✅ Return the public Supabase URL
    public_url = f"{SUPABASE_URL}/storage/v1/object/public/profile_pictures/{filename}"
    return public_url
