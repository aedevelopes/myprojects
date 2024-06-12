/**************************************************************************************************************************************************
                        Business Purpose    -    Create Address Token using 3 inputs with suite/building/floor level in a separate column
                        Invoke function     -    STITCH_PLACEHOLDER.util.addr_token_st1_st2_zip(street_address_line_1,street_address_line_2, postal_code)
                                                 eg: select STITCH_PLACEHOLDER.util.addr_token_st1_st2_zip(line1, line2, zip) as addresstoken3
                        Dependencies        -    STITCH_PLACEHOLDER.UTIL.SUITE_FORMATTER

                        Version History     -    03/14/2024 - v_01 - Created - Alex Ennis
                                            
***************************************************************************************************************************************************/



CREATE
OR REPLACE FUNCTION STITCH_PLACEHOLDER.util.addr_token_st1_st2_zip(
    "street_address_line_1" VARCHAR(16777216),
    "street_address_line_2" VARCHAR(16777216),
    "postal_code" VARCHAR(16777216)

    
) RETURNS VARCHAR(16777216) LANGUAGE SQL AS $$

REGEXP_REPLACE(
    TRIM(
        REGEXP_REPLACE(
            CONCAT(
                REGEXP_SUBSTR(
                    REGEXP_REPLACE(
                        street_address_line_1,
                        ' N | S | E | W | NW | NE | SW | SE | US | SOUTH | NORTH | EAST | WEST ',
                        ' '
                    ),
                    '[0-9]* [A-Z0-9]*[ ]?[A-Z0-9]*?'
                ),CASE
                    WHEN LENGTH(
                        (
                            TRIM(
                                REGEXP_REPLACE(
                                    CONCAT(
                                        TRIM(
                                            (
                                                CASE
                                                    WHEN (
                                                        STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                            REGEXP_REPLACE(
                                                                street_address_line_2,
                                                                'FL |LEVEL |FLR ',
                                                                'FLOOR '
                                                            )
                                                        )
                                                    ) ilike '%floor%' then COALESCE(
                                                        CONCAT(
                                                            'FLOOR ',
                                                            REGEXP_SUBSTR(
                                                                (
                                                                    STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                                        REGEXP_REPLACE(
                                                                            street_address_line_2,
                                                                            'FL |LEVEL |FLR ',
                                                                            'FLOOR '
                                                                        )
                                                                    )
                                                                ),
                                                                '[0-9][0-9]?'
                                                            )
                                                        ),
                                                        ''
                                                    )
                                                    ELSE ''
                                                END
                                            )
                                        ),
                                        ' ',
                                        trim(
                                            (
                                                CASE
                                                    WHEN (
                                                        STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                            REGEXP_REPLACE(
                                                                street_address_line_2,
                                                                'FL |LEVEL |FLR ',
                                                                'FLOOR '
                                                            )
                                                        )
                                                    ) not ilike '%FLOOR%'
                                                    and (
                                                        STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                            REGEXP_REPLACE(
                                                                street_address_line_2,
                                                                'FL |LEVEL |FLR ',
                                                                'FLOOR '
                                                            )
                                                        )
                                                    ) not ilike '%STE%'
                                                    AND (
                                                        STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                            REGEXP_REPLACE(
                                                                street_address_line_2,
                                                                'FL |LEVEL |FLR ',
                                                                'FLOOR '
                                                            )
                                                        )
                                                    ) not ilike 'SUITE'
                                                    and (
                                                        STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                            REGEXP_REPLACE(
                                                                street_address_line_2,
                                                                'FL |LEVEL |FLR ',
                                                                'FLOOR '
                                                            )
                                                        )
                                                    ) not ilike '' then CONCAT(
                                                        'STE ',
                                                        (
                                                            STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                                REGEXP_REPLACE(
                                                                    street_address_line_2,
                                                                    'FL |LEVEL |FLR ',
                                                                    'FLOOR '
                                                                )
                                                            )
                                                        )
                                                    )
                                                    ELSE COALESCE(
                                                        REGEXP_SUBSTR(
                                                            REGEXP_REPLACE(
                                                                (
                                                                    STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                                        REGEXP_REPLACE(
                                                                            street_address_line_2,
                                                                            'FL |LEVEL |FLR ',
                                                                            'FLOOR '
                                                                        )
                                                                    )
                                                                ),
                                                                'STE STE',
                                                                'STE'
                                                            ),
                                                            'STES?[ ]? [A-Z0-9]+',
                                                            1,
                                                            1,
                                                            'i'
                                                        ),
                                                        ''
                                                    )
                                                END
                                            )
                                        )
                                    ),
                                    'STE STE','')))) > 1 THEN ' '
                    ELSE ''
                END,
                (
                    TRIM(
                        REGEXP_REPLACE(
                            CONCAT(
                                TRIM(
                                    (
                                        CASE
                                            WHEN (
                                                STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                    REGEXP_REPLACE(
                                                        street_address_line_2,
                                                        'FL |LEVEL |FLR ',
                                                        'FLOOR '
                                                    )
                                                )
                                            ) ilike '%floor%' then COALESCE(
                                                CONCAT(
                                                    'FLOOR ',
                                                    REGEXP_SUBSTR(
                                                        (
                                                            STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                                REGEXP_REPLACE(
                                                                    street_address_line_2,
                                                                    'FL |LEVEL |FLR ',
                                                                    'FLOOR '
                                                                )
                                                            )
                                                        ),
                                                        '[0-9][0-9]?'
                                                    )
                                                ),
                                                ''
                                            )
                                            ELSE ''
                                        END
                                    )
                                ),
                                ' ',
                                trim(
                                    (
                                        CASE
                                            WHEN (
                                                STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                    REGEXP_REPLACE(
                                                        street_address_line_2,
                                                        'FL |LEVEL |FLR ',
                                                        'FLOOR '
                                                    )
                                                )
                                            ) not ilike '%FLOOR%'
                                            and (
                                                STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                    REGEXP_REPLACE(
                                                        street_address_line_2,
                                                        'FL |LEVEL |FLR ',
                                                        'FLOOR '
                                                    )
                                                )
                                            ) not ilike '%STE%'
                                            AND (
                                                STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                    REGEXP_REPLACE(
                                                        street_address_line_2,
                                                        'FL |LEVEL |FLR ',
                                                        'FLOOR '
                                                    )
                                                )
                                            ) not ilike 'SUITE'
                                            and (
                                                STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                    REGEXP_REPLACE(
                                                        street_address_line_2,
                                                        'FL |LEVEL |FLR ',
                                                        'FLOOR '
                                                    )
                                                )
                                            ) not ilike '' then CONCAT(
                                                'STE ',
                                                (
                                                    STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                        REGEXP_REPLACE(
                                                            street_address_line_2,
                                                            'FL |LEVEL |FLR ',
                                                            'FLOOR '
                                                        )
                                                    )
                                                )
                                            )
                                            ELSE COALESCE(
                                                REGEXP_SUBSTR(
                                                    REGEXP_REPLACE(
                                                        (
                                                            STITCH_PLACEHOLDER.util.SUITE_FORMATTER(
                                                                REGEXP_REPLACE(
                                                                    street_address_line_2,
                                                                    'FL |LEVEL |FLR ',
                                                                    'FLOOR '
                                                                )
                                                            )
                                                        ),
                                                        'STE STE',
                                                        'STE'
                                                    ),
                                                    'STES?[ ]? [A-Z0-9]+',
                                                    1,
                                                    1,
                                                    'i'
                                                ),
                                                ''
                                            )
                                        END
                                    )
                                )
                            ),
                            'STE STE',
                            ''
                        )
                    )
                ),
                ' | ',
                COALESCE(
                    LPAD(REPLACE(LEFT(postal_code, 5), '-', ''), 5, 0),
                    NULL
                )
            ),
            ' AVE | AVENUE | ALY | ARC | BND | BLVD | CTR | WAY | CIR | CT | XING | DRIVE | DR | EXPY | GRV | HTS 
                                                                | LANE | LN | PKWY | PLACE | PL | PLZ | PT | RDG | ROAD | RD | SQUARE | SQ | STREET | ST | TER 
                                                                | TRL | TPKE | VW | WHRF | CREEK ',
            ' '
        )
    ),
    '  [ ]?',
    ' '
)

$$;
