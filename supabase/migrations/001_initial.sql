create extension if not exists pgcrypto;
create extension if not exists postgis;

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  content text not null check (char_length(content) between 1 and 40),
  latitude double precision not null check (latitude between -90 and 90),
  longitude double precision not null check (longitude between -180 and 180),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '24 hours'),
  status text not null default 'active' check (status in ('active', 'hidden', 'deleted'))
);

create index if not exists posts_expires_at_idx on public.posts (expires_at);
create index if not exists posts_status_idx on public.posts (status);
create index if not exists posts_geo_idx on public.posts using gist (
  geography(st_setsrid(st_makepoint(longitude, latitude), 4326))
);

alter table public.posts enable row level security;

create policy "read active unexpired posts"
on public.posts
for select
to authenticated
using (status = 'active' and expires_at > now());

create or replace function public.create_anonymous_post(
  p_content text,
  p_latitude double precision,
  p_longitude double precision
)
returns table (
  id uuid,
  message text,
  latitude double precision,
  longitude double precision,
  created_at timestamptz,
  expires_at timestamptz
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_distance_m double precision;
  v_bearing double precision;
  v_lat_rad double precision;
  v_lon_rad double precision;
  v_new_lat double precision;
  v_new_lon double precision;
  v_earth_radius_m constant double precision := 6371000.0;
begin
  if v_user_id is null then
    raise exception 'authentication required';
  end if;

  p_content := btrim(p_content);
  if p_content = '' or char_length(p_content) > 40 then
    raise exception 'content must contain between 1 and 40 characters';
  end if;
  if p_latitude not between -90 and 90 or p_longitude not between -180 and 180 then
    raise exception 'invalid coordinates';
  end if;

  -- Store only an obfuscated point, 300-700m away from the submitted GPS point.
  v_distance_m := 300 + random() * 400;
  v_bearing := random() * 2 * pi();
  v_lat_rad := radians(p_latitude);
  v_lon_rad := radians(p_longitude);

  v_new_lat := asin(
    sin(v_lat_rad) * cos(v_distance_m / v_earth_radius_m) +
    cos(v_lat_rad) * sin(v_distance_m / v_earth_radius_m) * cos(v_bearing)
  );
  v_new_lon := v_lon_rad + atan2(
    sin(v_bearing) * sin(v_distance_m / v_earth_radius_m) * cos(v_lat_rad),
    cos(v_distance_m / v_earth_radius_m) - sin(v_lat_rad) * sin(v_new_lat)
  );

  return query
  insert into public.posts (user_id, content, latitude, longitude)
  values (v_user_id, p_content, degrees(v_new_lat), degrees(v_new_lon))
  returning posts.id, posts.content, posts.latitude, posts.longitude,
            posts.created_at, posts.expires_at;
end;
$$;

create or replace function public.get_nearby_posts(
  p_latitude double precision,
  p_longitude double precision,
  p_radius_km double precision default 3
)
returns table (
  id uuid,
  message text,
  latitude double precision,
  longitude double precision,
  created_at timestamptz,
  expires_at timestamptz
)
language sql
stable
security invoker
set search_path = public
as $$
  select
    p.id,
    p.content as message,
    p.latitude,
    p.longitude,
    p.created_at,
    p.expires_at
  from public.posts p
  where p.status = 'active'
    and p.expires_at > now()
    and st_dwithin(
      geography(st_setsrid(st_makepoint(p.longitude, p.latitude), 4326)),
      geography(st_setsrid(st_makepoint(p_longitude, p_latitude), 4326)),
      greatest(0, least(p_radius_km, 10)) * 1000
    )
  order by p.created_at desc
  limit 200;
$$;

grant execute on function public.create_anonymous_post(text, double precision, double precision) to authenticated;
grant execute on function public.get_nearby_posts(double precision, double precision, double precision) to authenticated;

revoke insert, update, delete on public.posts from anon, authenticated;
