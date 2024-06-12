/**************************************************************************************************************************************************
                        Business Purpose    -    Cleanse Street in Address
                        Invoke function     -    STITCH_PLACEHOLDER.UTIL.SUITE_FORMATTER(street as parameter)
                                                 eg: select STITCH_PLACEHOLDER.UTIL.SUITE_FORMATTER('1750 El Camino Real # 206') as street
                        Dependencies        -    Dependent on source table's street field only

                        Version History     -    01/02/2024 - V_01 - Created - Parker | Senthil
                                            -    03/14/2024 - v_02 - Created - Alex Ennis
***************************************************************************************************************************************************/

CREATE OR REPLACE 
FUNCTION STITCH_PLACEHOLDER.UTIL.SUITE_FORMATTER("STREET" VARCHAR(16777216))
RETURNS VARCHAR(16777216)
LANGUAGE SQL
AS $$

    REGEXP_REPLACE(TRIM(REGEXP_REPLACE(UPPER(REGEXP_REPLACE(UPPER(CONCAT(' ',STREET)), '[.]', '')), ' SUITE #| UNIT #| STE #| SUITES? | UNITS? |# |#| NUMBER | STE[.] | APTS? | RMS? | ROOMS?', ' STE ')),'  [ ]?', ' ')
    
$$;

