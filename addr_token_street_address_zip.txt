/**************************************************************************************************************************************************
                        Business Purpose    -    Create Address token using two inputs; street address and zip
                        Invoke function     -    STITCH_PLACEHOLDER.util.addr_token_st_zip(address,  postal_code)
                                                 eg: select STITCH_PLACEHOLDER.util.addr_token_st_zip(address, zip) as addresstoken2
                        Dependencies        -    STITCH_PLACEHOLDER.UTIL.SUITE_FORMATTER

                        Version History     -    03/14/2024 - v_01 - Created - Alex Ennis
                                            
***************************************************************************************************************************************************/




CREATE
OR REPLACE FUNCTION STITCH_PLACEHOLDER.util.addr_token_st_zip(
    "full_address" VARCHAR(16777216),
    "postal_code" VARCHAR(16777216)
) RETURNS VARCHAR(16777216) LANGUAGE SQL AS $$

REGEXP_REPLACE(REGEXP_REPLACE((CASE WHEN (REGEXP_REPLACE(REGEXP_REPLACE(TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE((TRIM(UPPER(TRIM(REGEXP_REPLACE(UPPER(concat(STITCH_PLACEHOLDER.util.SUITE_FORMATTER(REGEXP_SUBSTR(full_address, '[0-9].*')), ' ')), ' FL ', ' FLOOR '))))), '[0-9]?[0-9](ST|ND|RD|TH) FLOOR', '', 1, 1, 'i'), 'STES? [A-Z0-9]+', '', 1, 1, 'i'), 'FLOORS? [0-9]+', '', 1, 1, 'i')),'-',' ' ),'  [ ]?[ ]?', ' ')) ILIKE '% BOX%' THEN (REGEXP_REPLACE(REGEXP_REPLACE(TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE((TRIM(UPPER(TRIM(REGEXP_REPLACE(UPPER(concat(STITCH_PLACEHOLDER.util.SUITE_FORMATTER(REGEXP_SUBSTR(full_address, '[0-9].*')), ' ')), ' FL ', ' FLOOR '))))), '[0-9]?[0-9](ST|ND|RD|TH) FLOOR', '', 1, 1, 'i'), 'STES? [A-Z0-9]+', '', 1, 1, 'i'), 'FLOORS? [0-9]+', '', 1, 1, 'i')),'-',' ' ),'  [ ]?[ ]?', ' '))||' '||COALESCE(LPAD(REPLACE(LEFT(postal_code, 5), '-', ''), 5, 0), NULL)   
                       WHEN length((TRIM(CONCAT((COALESCE(CONCAT('FLOOR ',REGEXP_SUBSTR((COALESCE(REGEXP_SUBSTR(REGEXP_REPLACE((TRIM(UPPER(TRIM(REGEXP_REPLACE(UPPER(concat(STITCH_PLACEHOLDER.util.SUITE_FORMATTER(REGEXP_SUBSTR(full_address, '[0-9].*')), ' ')), ' FL ', ' FLOOR '))))), 'FLOOR [0-9]{5}', ''), '(FLOORS? [0-9]{1,2})|([0-9]?[0-9](ST|ND|RD|TH) FLOOR)', 1, 1, 'i'), '')), '[0-9][0-9]?')), '')), ' ', (COALESCE(REGEXP_SUBSTR((TRIM(UPPER(TRIM(REGEXP_REPLACE(UPPER(concat(STITCH_PLACEHOLDER.util.SUITE_FORMATTER(REGEXP_SUBSTR(full_address, '[0-9].*')), ' ')), ' FL ', ' FLOOR '))))), 'STES?[ ]? [A-Z0-9]+', 1, 1, 'i'), '')))))) > 1
                        THEN CONCAT(REGEXP_SUBSTR(REGEXP_REPLACE((REGEXP_REPLACE(REGEXP_REPLACE(TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE((TRIM(UPPER(TRIM(REGEXP_REPLACE(UPPER(concat(STITCH_PLACEHOLDER.util.SUITE_FORMATTER(REGEXP_SUBSTR(full_address, '[0-9].*')), ' ')), ' FL ', ' FLOOR '))))), '[0-9]?[0-9](ST|ND|RD|TH) FLOOR', '', 1, 1, 'i'), 'STES? [A-Z0-9]+', '', 1, 1, 'i'), 'FLOORS? [0-9]+', '', 1, 1, 'i')),'-',' ' ),'  [ ]?[ ]?', ' '))
                            , ' N | S | E | W | NW | NE | SW | SE | US | SOUTH | NORTH | EAST | WEST ', ' '),'[0-9]* [A-Z0-9]*[ ]?[A-Z0-9]*?')
                            ,' ', (TRIM(CONCAT((COALESCE(CONCAT('FLOOR ',REGEXP_SUBSTR((COALESCE(REGEXP_SUBSTR(REGEXP_REPLACE((TRIM(UPPER(TRIM(REGEXP_REPLACE(UPPER(concat(STITCH_PLACEHOLDER.util.SUITE_FORMATTER(REGEXP_SUBSTR(full_address, '[0-9].*')), ' ')), ' FL ', ' FLOOR '))))), 'FLOOR [0-9]{5}', ''), '(FLOORS? [0-9]{1,2})|([0-9]?[0-9](ST|ND|RD|TH) FLOOR)', 1, 1, 'i'), '')), '[0-9][0-9]?')), '')), ' ', (COALESCE(REGEXP_SUBSTR((TRIM(UPPER(TRIM(REGEXP_REPLACE(UPPER(concat(STITCH_PLACEHOLDER.util.SUITE_FORMATTER(REGEXP_SUBSTR(full_address, '[0-9].*')), ' ')), ' FL ', ' FLOOR '))))), 'STES?[ ]? [A-Z0-9]+', 1, 1, 'i'), ''))))), ' | ', COALESCE(LPAD(REPLACE(LEFT(postal_code, 5), '-', ''), 5, 0), NULL))
                              
                       ELSE 
                         CONCAT(TRIM(REGEXP_SUBSTR(REGEXP_REPLACE(TRIM((REGEXP_REPLACE(REGEXP_REPLACE(TRIM(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE((TRIM(UPPER(TRIM(REGEXP_REPLACE(UPPER(concat(STITCH_PLACEHOLDER.util.SUITE_FORMATTER(REGEXP_SUBSTR(full_address, '[0-9].*')), ' ')), ' FL ', ' FLOOR '))))), '[0-9]?[0-9](ST|ND|RD|TH) FLOOR', '', 1, 1, 'i'), 'STES? [A-Z0-9]+', '', 1, 1, 'i'), 'FLOORS? [0-9]+', '', 1, 1, 'i')),'-',' ' ),'  [ ]?[ ]?', ' ')))
                            , ' N | S | E | W | NW | NE | SW | SE | US | SOUTH | NORTH | EAST | WEST ', ' ')
                            ,'[0-9]* [A-Z0-9]*[ ]?[A-Z0-9]*?')), ' | ', COALESCE(LPAD(REPLACE(LEFT(postal_code, 5), '-', ''), 5, 0), NULL))
        END), ' AVE | AVENUE | ALY | ARC | BND | BLVD | CTR | WAY | CIR | CT | XING | DRIVE | DR | EXPY | GRV | HTS | LANE | LN | PKWY | PLACE | PL | PLZ | PT | RDG | ROAD | RD | SQUARE | SQ | STREET | ST | TER | TRL | TPKE | VW | WHRF | CREEK '
, ' '), '  [ ]?', ' ')
$$
