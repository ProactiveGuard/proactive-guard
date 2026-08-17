import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

export const supabase = supabaseUrl && supabaseAnonKey 
  ? createClient(supabaseUrl, supabaseAnonKey) 
  : null;

export const subscribeToIncidents = (callback: (incident: any) => void) => {
  if (!supabase) {
    console.warn('[Supabase] Not configured, skipping realtime subscription');
    return () => {};
  }

  const channel = supabase
    .channel('incidents_changes')
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'incidents',
      },
      (payload) => {
        callback(payload.new);
      }
    )
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'incidents',
      },
      (payload) => {
        callback(payload.new);
      }
    )
    .on(
      'postgres_changes',
      {
        event: 'DELETE',
        schema: 'public',
        table: 'incidents',
      },
      (payload) => {
        callback({ ...payload.old, deleted: true });
      }
    )
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
};