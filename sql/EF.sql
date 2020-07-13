-- The view ef_emf_v is the main table for provision of data for the ef:EnvironmentalMonitoringFacility featureType
CREATE OR REPLACE VIEW hydrostation.ef_emf_v
AS SELECT sf.cdstationh AS id,
    sf.cdstationh AS localid,
    'https://iddata.eaufrance.fr'::text AS namespace,
    'default'::text AS version,
    sf.lbstationh AS name,
    sf.typstation AS specialtype,
    'http://inspire.ec.europa.eu/codelist/MediaValue/water'::text AS mediamonitored,
    NULL::text AS broader,
    NULL::text AS involvedin,
    'http://inspire.ec.europa.eu/codelist/MeasurementRegimeValue/continuousDataCollection'::text AS measurementregime,
    'false'::text AS mobile,
    NULL::text AS belongsto,
    -- added sameas
    'http://id.eaufrance.fr/StationHydro/'::text || sf.cdstationh::text AS sameas,
    'PT.'::text || sf.cdstationh::text AS geometryid,   
    -- note: I had the following as Geometry:
    --     st_setsrid(st_makepoint(sf.x::double precision, sf.y::double precision), 4326) AS geometry
    geom AS geometry
   FROM hydrostation.stationhydro_fxx sf
  WHERE NOT sf.cdtronconh::text ~~ ''::text AND NOT sf.dtmservice::text ~~ ''::text;



  -- As a ef:EnvironmentalMonitoringFacility featureType can be associated with multiple Operation Activity Periods, this information must be provided in an additional table.
-- FK: efid --> ef_emf_v.id

CREATE OR REPLACE VIEW hydrostation.ef_opact_v
AS SELECT sf.cdstationh AS id,
    sf.cdstationh AS efid,
    sf.cdstationh AS gmlid,
    sf.dtmservice::timestamp with time zone AS begintime,
        CASE
            WHEN sf.dtfermetur::text = ''::text THEN NULL::timestamp with time zone
            ELSE sf.dtfermetur::timestamp with time zone
        END AS endtime,
    'TP_'::text || sf.cdstationh::text AS tpid,
        CASE
            WHEN sf.dtfermetur::text = ''::text THEN 'unknown'::text
            ELSE NULL::text
        END AS endtime_status
   FROM hydrostation.stationhydro_fxx sf
  WHERE NOT sf.cdtronconh::text ~~ ''::text AND NOT sf.dtmservice::text ~~ ''::text;
  


  -- As a ef:EnvironmentalMonitoringFacility featureType can be associated with multiple ObservingCapabilities, this information must be provided in an additional table.
-- FK: efid --> ef_emf_v.id

CREATE OR REPLACE VIEW hydrostation.ef_obscaps_v
AS SELECT sf.cdstationh AS id,
    sf.cdstationh AS efid,
    sf.cdstationh AS gmlid,
    sf.dtmservice::timestamp with time zone AS begintime,
        CASE
            WHEN sf.dtfermetur::text = ''::text THEN NULL::timestamp with time zone
            ELSE sf.dtfermetur::timestamp with time zone
        END AS endtime,
    'TP_'::text || sf.cdstationh::text AS tpid,
        CASE
            WHEN sf.dtfermetur::text = ''::text THEN 'unknown'::text
            ELSE NULL::text
        END AS endtime_status,
    'https://inspire.ec.europa.eu/codelist/ProcessTypeValue/process'::text AS processtype,
    'https://inspire.ec.europa.eu/codelist/ResultNatureValue/primary'::text AS resultnature,
    'http://id.eaufrance.fr/nsa/512#0'::text AS procedure,
    'MeasuredBySensor'::text AS procedurelabel,
    'http://service.datacove.eu/geoserver/ogc/features/collections/sf-w:WaterSample/items/'::text || sf.cdstationh::text AS foi,
    'http://service.datacove.eu/geoserver/ogc/features/collections/hy-n:WatercourseLinkSequence/items/'::text || sf.cdstationh::text AS ufoi,
    'http://id.eaufrance.fr/nsa/509#H'::text AS observedproperty,
    'WaterLevel'::text AS observedpropertylabel
   FROM hydrostation.stationhydro_fxx sf
  WHERE NOT sf.cdstationh::text ~~ ''::text AND NOT sf.dtmservice::text ~~ ''::text;
  

  -- As a ef:EnvironmentalMonitoringFacility featureType can be related with multiple other features, this information must be provided in an additional table.
-- FK: id --> ef_emf_v.id

CREATE OR REPLACE VIEW hydrostation.ef_related_v
AS 
SELECT sf.cdstationh AS id,
    'http://id.insee.fr/geo/commune/'::text || sf.cdcommune::text AS related
   FROM hydrostation.stationhydro_fxx sf
  WHERE NOT sf.cdtronconh::text ~~ ''::text AND NOT sf.dtmservice::text ~~ ''::text AND NOT sf.cdstationh::text ~~ ''::text
UNION
 SELECT sf.cdstationh AS id,
    'https://iddata.eaufrance.fr/id/Watershed/'::text || sf.cdzonehyd::text AS related
   FROM hydrostation.stationhydro_fxx sf
  WHERE NOT sf.cdtronconh::text ~~ ''::text AND NOT sf.dtmservice::text ~~ ''::text AND NOT sf.cdzonehyd::text ~~ ''::text
UNION
 SELECT sf.cdstationh AS id,
    'https://iddata.eaufrance.fr/id/Watercourse/'::text || sf.cdentitehy::text AS related
   FROM hydrostation.stationhydro_fxx sf
  WHERE NOT sf.cdtronconh::text ~~ ''::text AND NOT sf.dtmservice::text ~~ ''::text AND NOT sf.cdentitehy::text ~~ ''::text
UNION
 SELECT sf.cdstationh AS id,
    'https://iddata.eaufrance.fr/id/WatercourseLinkSequence/'::text || sf.cdtronconh::text AS related
   FROM hydrostation.stationhydro_fxx sf
  WHERE NOT sf.cdtronconh::text ~~ ''::text AND NOT sf.dtmservice::text ~~ ''::text AND NOT sf.cdtronconh::text ~~ ''::text;

-- The data for the samplingFeature that serves as featureOfInterest of the ef:EnvironmentalMonitoringFacility featureType of type sf-w:WaterSample.
-- FK: id --> ef_emf_v.id

CREATE OR REPLACE VIEW hydrostation.ef_sample_v
AS SELECT sf.cdstationh::text AS id,
    sf.cdstationh AS localid,
    'http://some.thing.fr/namespace/tbd'::text AS namespace,
    '1'::text AS version,
    sf.lbstationh AS name,
    sf.cdtronconh AS sampledfeature,
    'SF_PT.'::text || sf.cdstationh::text AS geometryid,
    st_setsrid(st_makepoint(sf.coordxstat::double precision, sf.coordystat::double precision), 4326) AS geometry
   FROM hydrostation.stationhydro_fxx sf
  WHERE NOT sf.cdtronconh::text ~~ ''::text AND NOT sf.dtmservice::text ~~ ''::text;

  -- The view bs2_contact_v provides contact information for the RelatedParty type
-- FK: conid --> ef_emf_v.id

CREATE OR REPLACE VIEW hydrostation.bs2_contact_v
AS 
SELECT NULL::text AS city,
    NULL::text AS address,
    NULL::text AS postcode,
    NULL::text AS email,
    NULL::text AS tel,
    'http://id.eaufrance.fr/int/'::text || replace(sf.cdint::text, ' '::text, ''::text) AS web,
    sf.cdstationh AS conid,
    sf.cdstationh AS id,
    'fr'::text AS lang,
    NULL::text AS individualname,
    sf.nomint AS organisationname,
    NULL::text AS positionname,
    'https://inspire.ec.europa.eu/codelist/RelatedPartyRoleValue/authority'::text AS role
   FROM hydrostation.stationhydro_fxx sf
  WHERE NOT sf.cdtronconh::text ~~ ''::text AND NOT sf.dtmservice::text ~~ ''::text;

GRANT SELECT ON ALL TABLES IN SCHEMA hydrostation TO sie_features_reader
