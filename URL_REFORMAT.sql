create or replace function stitch_placeholder.util.url_reformat(website varchar)
returns varchar
language sql
as 
$$

CASE WHEN lower(website) ILIKE '%linkedin.com' THEN null
     WHEN lower(website) ILIKE '%linkedin%' THEN  regexp_replace(
          (
          CASE WHEN lower(website) ILIKE '%?trk%' THEN split_part(lower(website), '?trk',1)
               WHEN lower(website) ILIKE '%/?original%' THEN split_part(lower(website), '/?original', 1)
               WHEN lower(website) ILIKE '%/' THEN SUBSTRING (lower(website),1, length(lower(website)) -1)                      
          ELSE lower(website) 
          END
          ) 
          ,'(https?://)?(www\.)?'
          ,''
    )
                                                                 
                                           
    WHEN lower(website) ILIKE '%instagram.com' THEN null
    WHEN lower(website) ILIKE '%instagram.com/' THEN null
    WHEN lower(website) ILIKE 'winecoutryaest%' THEN 'instagram.com/Winecountryaestheticnurse'
    WHEN lower(website) ILIKE '%instagram%' THEN regexp_replace(
          (
           CASE WHEN lower(website) ILIKE '%/reels/?hl=en' THEN SUBSTRING(lower(website),1, length(lower(website)) - 13)
                WHEN lower(website) ILIKE '%/?hl=en' THEN SUBSTRING(lower(website),1, length(lower(website)) - 7)
                WHEN lower(website) ILIKE '%/?hl=bg' THEN SUBSTRING(lower(website),1, length(lower(website)) - 7)
                WHEN lower(website) ILIKE '%/reels%' THEN SUBSTRING (lower(website),1, length(lower(website)) - 6)
                WHEN lower(website) ILIKE '%/' THEN SUBSTRING (lower(website),1, length(lower(website)) -1)
                WHEN lower(website) ILIKE '%/?igshid=%' THEN split_part(lower(website), '/?', 1)
                WHEN lower(website) ILIKE '%?igshid=%' THEN split_part(lower(website), '?', 1)
                WHEN lower(website) ILIKE '%?igsh=%' THEN split_part(lower(website), '?', 1)
                WHEN lower(website) ILIKE '%?utm_%' THEN split_part(lower(website), '?utm_', 1)
                WHEN lower(website) ILIKE '%?ref=page%' THEN split_part(lower(website),'?ref=page',1)
          ELSE lower(website) 
          END
          )
          ,'(https?://)?(www\.)?'
          , ''
    )

    WHEN lower(website) ILIKE '%facebook.com' THEN null
    WHEN lower(website) ILIKE '%facebook%' THEN regexp_replace(
         (
         CASE WHEN lower(website) ILIKE '%/reels/?hl=en' THEN SUBSTRING(lower(website),1, length(lower(website)) - 13)
              WHEN lower(website) ILIKE '%/?hl=en' THEN SUBSTRING(lower(website),1, length(lower(website)) - 7)
              WHEN lower(website) ILIKE '%/?hl=bg' THEN SUBSTRING(lower(website),1, length(lower(website)) - 7)
              WHEN lower(website) ILIKE '%/reels%' THEN SUBSTRING (lower(website),1, length(lower(website)) - 6)
              WHEN lower(website) ILIKE '%/services%' THEN split_part(lower(website),'/services',1)
              WHEN lower(website) ILIKE '%/?igshid=%' THEN split_part(lower(website), '/?', 1)
              WHEN lower(website) ILIKE '%?igshid=%' THEN split_part(lower(website), '?', 1)
              WHEN lower(website) ILIKE '%?utm_%' THEN split_part(lower(website), '?utm_', 1)
              WHEN lower(website) ILIKE '%?mibex%' THEN split_part(lower(website),'?mibex', 1)
              WHEN lower(website) ILIKE '%&mibex%' THEN split_part(lower(website),'&mibex', 1)
              WHEN lower(website) ILIKE '%/about%' THEN split_part(lower(website), '/about',1)
              WHEN lower(website) ILIKE '%/?paipv%' THEN split_part(lower(website),'/?paipv',1)
              WHEN lower(website) ILIKE '%?fref%' THEN split_part(lower(website),'?fref',1)
              WHEN lower(website) ILIKE '%/mentions' THEN split_part(lower(website),'/mentions',1)
              WHEN lower(website) ILIKE '%&paipv%' THEN split_part(lower(website),'&paipv',1)
              WHEN lower(website) ILIKE '%/?locale%' THEN split_part(lower(website), '/?locale', 1)
              WHEN lower(website) ILIKE '%/photos_by' THEN split_part(lower(website), '/photos_by',1)
              WHEN lower(website) ILIKE '%&sk=abo%' THEN split_part(lower(website), '&sk=about',1)
              WHEN lower(website) ILIKE '%/' THEN SUBSTRING (lower(website),1, length(lower(website)) -1)
              WHEN lower(website) ILIKE '%?ref=page%' THEN split_part(lower(website),'/?ref=page',1)
              ELSE lower(website) 
              END
         )
         ,'(https?://)?(www\.)?(m[.])?(ms-my\.)?(hi-in\.)?(en-gb\.)?(ne-np\.)?(pt-br\.)?'
         ,'' 
   )
                                                                                                          
ELSE TRIM(REGEXP_REPLACE(lower(website), '[a-zA-Z]+://|[a-zA-Z]+:/|www\\.|/[^)]*|https?:', ''))                                                                                                          
END

$$;
