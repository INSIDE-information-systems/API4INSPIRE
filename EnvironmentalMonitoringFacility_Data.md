# API4INSPIRE EnvironmentalMonitoringFacility Mapping for BRGM

In the following sections, we provide information on the source data used and transformations required for the provision of Environmental Monitoring Facilities 
under the extended INSPIRE Schema [https://schema.datacove.eu/EnvironmentalMonitoringFacilitiesFXX.xsd](https://schema.datacove.eu/EnvironmentalMonitoringFacilitiesFXX.xsd)

The following modifications where made to the INSPIRE EnvironmentalMonitoringFacilities.xsd:
* EnvironmentalMonitoringFacility
  * Added ef:relatedFeature - xlink to other related features. We couldn't use ef:relatedTo as this must point to a further EF
  * Added ef:sameAs - xlink to other representation of the same object 
* ObservingCapability
  * Added ef:ultimateFeatureOfInterest - here we finally provide the cdtronconhydrographique link

The following sections we describe the data source, mapping to the INSPIRE EnvironmentalMonitoringFacility featureType and subtypes
as well as the creation of views for App Schema Mapping.

## Data Source

### EnvironmentalMonitoringFacility

The source data for the French Environmental Monitoring Facilities was imported from the ShapeFile stationhydro_fxx. This data was imported into a PostGIS DB via QGIS. 
All further mapping is done from the resulting database table, whereby the attribute names from the Shapefile were retained.


The following database table is the basis of all views required to support the App Schema Mapping provided.
```
CREATE TABLE public.stationhydro_fxx (
	id serial NOT NULL,
	x numeric NULL,
	y numeric NULL,
	gid varchar(100) NULL,
	cdstationhydro varchar(100) NULL,
	cdstationhydroancienref varchar(100) NULL,
	lbstationhydro varchar(500) NULL,
	typstationhydro varchar(100) NULL,
	cdcommune varchar(100) NULL,
	cdzonehydro varchar(100) NULL,
	cdentitehydrographique varchar(100) NULL,
	cdtronconhydrographique varchar(100) NULL,
	dtmiseservicestationhydro varchar(100) NULL,
	dtfermeturestationhydro varchar(100) NULL,
	cdintervenant varchar(100) NULL,
	nomintervenant varchar(100) NULL,
	lbaffichagestationhydro varchar(100) NULL,
	dtmajstationhydro varchar(100) NULL,
	droitpublicationstationhydro varchar(100) NULL,
	influlocalestationhydro varchar(100) NULL,
	essaistationhydro varchar(100) NULL,
	coordxstationhydro varchar(100) NULL,
	coordystationhydro varchar(100) NULL,
	projcoordstationhydro varchar(100) NULL,
	lbterritoire varchar(100) NULL,
	CONSTRAINT stationhydro_fxx_pkey PRIMARY KEY (id)
);
```

## Mapping from Source Data to INSPIRE Models

The mapping from the source data to the INSPIRE data models was done as Google Sheets, one for each INSPIRE Type to be provided. The table has the following columns:
* DB Table: The view from which the data element is made available for GeoServer App Schema Mapping.
* DB Column: The column within the view from which the data element is made available for GeoServer App Schema Mapping.
* ef:EnvironmentalMonitoringFacility: The target XPath within the featureType for the data element.
* shp attribute: Attribute for the data element within the shapefile.
* Constant: Constant value if required. This column also contains information on prefixes applied to data taken from the DB table.

[Mapping Sheet](https://docs.google.com/spreadsheets/d/1dg-rab47WGSeiC2I__te23s-vxON0UUnzQTKCpq9MT0/edit)

## Views for App Schema Mapping

The following sections we describe the views created to transform the source data described above in accordance with the mapping.

All sql for the views is available from [https://github.com/INSIDE-information-systems/API4INSPIRE/blob/master/sql/EF.sql](https://github.com/INSIDE-information-systems/API4INSPIRE/blob/master/sql/EF.sql)


### ef_emf_v
The view ef_emf_v is the main table for provision of data for the ef:EnvironmentalMonitoringFacility featureType
```
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
```

### ef_opact_v

As a ef:EnvironmentalMonitoringFacility featureType can be associated with multiple Operation Activity Periods, this information must be provided in an additional table.
* FK: efid --> ef_emf_v.id

```
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
```

### ef_obscaps_v

As a ef:EnvironmentalMonitoringFacility featureType can be associated with multiple ObservingCapabilities, this information must be provided in an additional table.
* FK: efid --> ef_emf_v.id

```
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
```


### ef_related_v

As a ef:EnvironmentalMonitoringFacility featureType can be related with multiple other features, this information must be provided in an additional table.
* FK: id --> ef_emf_v.id

```
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
```

### ef_sample_v

The data for the samplingFeature that serves as featureOfInterest of the ef:EnvironmentalMonitoringFacility featureType of type sf-w:WaterSample.
* FK: id --> ef_emf_v.id

```
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
```

### bs2_contact_v
The view bs2_contact_v provides contact information for the RelatedParty type
* FK: conid --> ef_emf_v.id
```
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
```

