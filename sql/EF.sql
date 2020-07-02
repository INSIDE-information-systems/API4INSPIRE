-- The view ef_emf_v is the main table for provision of data for the ef:EnvironmentalMonitoringFacility featureType

CREATE OR REPLACE VIEW public.ef_emf_v
AS SELECT sf.cdstationhydro AS id,
    sf.cdstationhydro AS localid,
    'http://some.thing.fr/namespace/tbd'::text AS namespace,
    'default'::text AS version,
    sf.lbstationhydro AS name,
    sf.typstationhydro AS specialtype,
    'http://inspire.ec.europa.eu/codelist/MediaValue/water'::text AS mediamonitored,
    NULL::text AS broader,
    NULL::text AS involvedin,
    'http://inspire.ec.europa.eu/codelist/MeasurementRegimeValue/continuousDataCollection'::text AS measurementregime,
    'false'::text AS mobile,
    NULL::text AS belongsto,
    'PT.'::text || sf.cdstationhydro::text AS geometryid,
    st_setsrid(st_makepoint(sf.x::double precision, sf.y::double precision), 4326) AS geometry
   FROM stationhydro_fxx sf
  WHERE NOT sf.cdtronconhydrographique::text ~~ ''::text AND NOT sf.dtmiseservicestationhydro::text ~~ ''::text;
  
  
-- As a ef:EnvironmentalMonitoringFacility featureType can be associated with multiple Operation Activity Periods, this information must be provided in an additional table.
-- FK: efid --> ef_emf_v.id

CREATE OR REPLACE VIEW public.ef_opact_v
AS SELECT sf.cdstationhydro AS id,
    sf.cdstationhydro AS efid,
    sf.cdstationhydro AS gmlid,
    sf.dtmiseservicestationhydro::timestamp with time zone AS begintime,
        CASE
            WHEN sf.dtfermeturestationhydro::text = ''::text THEN NULL::timestamp with time zone
            ELSE sf.dtfermeturestationhydro::timestamp with time zone
        END AS endtime,
    'TP_'::text || sf.cdstationhydro::text AS tpid,
        CASE
            WHEN sf.dtfermeturestationhydro::text = ''::text THEN 'unknown'::text
            ELSE NULL::text
        END AS endtime_status
   FROM stationhydro_fxx sf
  WHERE NOT sf.cdtronconhydrographique::text ~~ ''::text AND NOT sf.dtmiseservicestationhydro::text ~~ ''::text;
  
-- As a ef:EnvironmentalMonitoringFacility featureType can be associated with multiple ObservingCapabilities, this information must be provided in an additional table.
-- FK: efid --> ef_emf_v.id

CREATE OR REPLACE VIEW public.ef_obscaps_v
AS SELECT sf.cdstationhydro AS id,
    sf.cdstationhydro AS efid,
    sf.cdstationhydro AS gmlid,
    sf.dtmiseservicestationhydro::timestamp with time zone AS begintime,
        CASE
            WHEN sf.dtfermeturestationhydro::text = ''::text THEN NULL::timestamp with time zone
            ELSE sf.dtfermeturestationhydro::timestamp with time zone
        END AS endtime,
    'TP_'::text || sf.cdstationhydro::text AS tpid,
        CASE
            WHEN sf.dtfermeturestationhydro::text = ''::text THEN 'unknown'::text
            ELSE NULL::text
        END AS endtime_status,
    'https://inspire.ec.europa.eu/codelist/ProcessTypeValue/process'::text AS processtype,
    'https://inspire.ec.europa.eu/codelist/ResultNatureValue/primary'::text AS resultnature,
    'http://id.eaufrance.fr/nsa/512#0'::text AS procedure,
    'MeasuredBySensor'::text AS procedurelabel,
    'http://service.datacove.eu/geoserver/ogc/features/collections/sf-w:WaterSample/items/'::text || sf.cdstationhydro::text AS foi,
    'http://service.datacove.eu/geoserver/ogc/features/collections/hy-n:WatercourseLinkSequence/items/'::text || sf.cdtronconhydrographique::text AS ufoi,
    'http://id.eaufrance.fr/nsa/509#H'::text AS observedproperty,
    'WaterLevel'::text AS observedpropertylabel
   FROM stationhydro_fxx sf
  WHERE NOT sf.cdtronconhydrographique::text ~~ ''::text AND NOT sf.dtmiseservicestationhydro::text ~~ ''::text;
  
-- As a ef:EnvironmentalMonitoringFacility featureType can be related with multiple other features, this information must be provided in an additional table.
-- FK: id --> ef_emf_v.id

CREATE OR REPLACE VIEW public.ef_related_v
AS SELECT sf.cdstationhydro AS id,
    'http://id.insee.fr/geo/commune/'::text || sf.cdcommune::text AS related
   FROM stationhydro_fxx sf
  WHERE NOT sf.cdtronconhydrographique::text ~~ ''::text AND NOT sf.dtmiseservicestationhydro::text ~~ ''::text AND NOT sf.cdstationhydro::text ~~ ''::text
UNION
 SELECT sf.cdstationhydro AS id,
    'http://data.water.fr/watershed/'::text || sf.cdzonehydro::text AS related
   FROM stationhydro_fxx sf
  WHERE NOT sf.cdtronconhydrographique::text ~~ ''::text AND NOT sf.dtmiseservicestationhydro::text ~~ ''::text AND NOT sf.cdzonehydro::text ~~ ''::text
UNION
 SELECT sf.cdstationhydro AS id,
    'http://data.water.fr/watercourse/'::text || sf.cdentitehydrographique::text AS related
   FROM stationhydro_fxx sf
  WHERE NOT sf.cdtronconhydrographique::text ~~ ''::text AND NOT sf.dtmiseservicestationhydro::text ~~ ''::text AND NOT sf.cdentitehydrographique::text ~~ ''::text
UNION
 SELECT sf.cdstationhydro AS id,
    'http://service.datacove.eu/geoserver/ogc/features/collections/hy-n:WatercourseLinkSequence/items/'::text || sf.cdtronconhydrographique::text AS related
   FROM stationhydro_fxx sf
  WHERE NOT sf.cdtronconhydrographique::text ~~ ''::text AND NOT sf.dtmiseservicestationhydro::text ~~ ''::text AND NOT sf.cdtronconhydrographique::text ~~ ''::text;

-- The data for the samplingFeature that serves as featureOfInterest of the ef:EnvironmentalMonitoringFacility featureType of type sf-w:WaterSample.
-- FK: id --> ef_emf_v.id

CREATE OR REPLACE VIEW public.ef_sample_v
AS SELECT sf.cdstationhydro::text AS id,
    sf.cdstationhydro AS localid,
    'http://some.thing.fr/namespace/tbd'::text AS namespace,
    '1'::text AS version,
    sf.lbstationhydro AS name,
    sf.cdtronconhydrographique AS sampledfeature,
    'SF_PT.'::text || sf.cdstationhydro::text AS geometryid,
    st_setsrid(st_makepoint(sf.x::double precision, sf.y::double precision), 4326) AS geometry
   FROM stationhydro_fxx sf
  WHERE NOT sf.cdtronconhydrographique::text ~~ ''::text AND NOT sf.dtmiseservicestationhydro::text ~~ ''::text;
  
-- The view bs2_contact_v provides contact information for the RelatedParty type
-- FK: conid --> ef_emf_v.id

CREATE OR REPLACE VIEW public.bs2_contact_v
AS SELECT NULL::text AS city,
    NULL::text AS address,
    NULL::text AS postcode,
    NULL::text AS email,
    NULL::text AS tel,
    'http://id.eaufrance.fr/int/'::text || replace(sf.cdintervenant::text, ' '::text, ''::text) AS web,
    sf.cdstationhydro AS conid,
    sf.cdstationhydro AS id,
    'fr'::text AS lang,
    NULL::text AS individualname,
    sf.nomintervenant AS organisationname,
    NULL::text AS positionname,
    'https://inspire.ec.europa.eu/codelist/RelatedPartyRoleValue/authority'::text AS role
   FROM stationhydro_fxx sf
  WHERE NOT sf.cdtronconhydrographique::text ~~ ''::text AND NOT sf.dtmiseservicestationhydro::text ~~ ''::text;

 
  
  
  