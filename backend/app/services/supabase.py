import os
from supabase import create_client, Client

# TO-DO: Member 4, you need to replace these with your actual Supabase URL and Key!
# You can get these from your Supabase project settings -> API.
SUPABASE_URL = os.environ.get("SUPABASE_URL", "https://ettwbdretjhxrjknuwlp.supabase.co")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY", "sb_publishable_HcnUObb2qrh4V7ndmYvSbQ_ZVmlC3Ua")

# This creates the connection to the database
try:
    supabase_db: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
except Exception as e:
    print("Warning: Supabase client could not be initialized. Did you set the URL and Key?")
    supabase_db = None