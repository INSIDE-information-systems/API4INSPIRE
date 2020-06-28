# API4INSPIRE Hydrography Network Mapping for BRGM

In the following sections, we provide information on the source data used and transformations required for the provision of Hydrography Networks under the INSPIRE Schema [https://inspire.ec.europa.eu/schemas/hy-n/4.0/HydroNetwork.xsd](https://inspire.ec.europa.eu/schemas/hy-n/4.0/HydroNetwork.xsd)

## Data Sources

### Segments

The source data for the French River Segments was imported from the ShapeFile TronconHydrograElt_02_Rhin-Meuse. This data was imported into a PostGIS DB via QGIS. 
All further mapping is done from the resulting database table.

*Note: in this dataset, there are too many segments, many could be merged. This data cleaning process was NOT performed on the available data. 
However, the further mapping steps are still applicable once the data has been cleaned.*

The following database table is the basis of all views required to support the App Schema Mapping provided.
```
CREATE TABLE public.tronconhydrograelt_02_rhin_meuse (
	ogc_fid serial NOT NULL,
	wkb_geometry geometry(MULTILINESTRING) NULL,
	gid numeric(10) NULL,
	idtronconh float8 NULL,
	numerotron numeric(10) NULL,
	etat varchar(26) NULL,
	sens varchar(26) NULL,
	largeur varchar(26) NULL,
	nature varchar(26) NULL,
	navigable varchar(26) NULL,
	gabarit varchar(25) NULL,
	possol varchar(26) NULL,
	cdtronconh varchar(8) NULL,
	cdsousmili varchar(2) NULL,
	cdentitehy varchar(8) NULL,
	cdentite_1 varchar(8) NULL,
	nomentiteh varchar(127) NULL,
	candidat1 varchar(127) NULL,
	toponyme2 varchar(127) NULL,
	candidat2 varchar(127) NULL,
	pkamonttro numeric(10) NULL,
	pkavaltron numeric(10) NULL,
	idnoeudhyd float8 NULL,
	idnoeudh_1 float8 NULL,
	geom geometry(LINESTRING, 4326) NULL,
	CONSTRAINT tronconhydrograelt_02_rhin_meuse_pk PRIMARY KEY (ogc_fid)
);
```

### Nodes

The source data for the French River Segments was imported from the ShapeFile NoeudHydrographique_02_Rhin-Meuse. This data was imported into a PostGIS DB via QGIS. 
All further mapping is done from the resulting database table.

```
CREATE TABLE public.noeudhydrographique_02_rhin_meuse (
	ogc_fid serial NOT NULL,
	wkb_geometry geometry(MULTIPOINT) NULL,
	gid numeric(10) NULL,
	idnoeudhyd float8 NULL,
	nature varchar(36) NULL,
	nomnoeudhy varchar(38) NULL,
	candidat varchar(27) NULL,
	cotenoeudh numeric(10) NULL,
	geom geometry(POINT, 4326) NULL,
	CONSTRAINT noeudhydrographique_02_rhin_meuse_pk PRIMARY KEY (ogc_fid)
);
```

## Views for App Schema Mapping

The following views have been created to transform the source data described above as required to provide data for the following INSPIRE Feature Types:
* hy-n:WatercourseLink: A segment within the Hydrography Network
* hy-n:HydroNode: A node within the Hydrography Network
* hy-n:WatercourseLinkSequence: A set of WatercourseLink feature types comprising a Watercourse Sequence

### hy-n:WatercourseLink

The following views provide the segment data in the structure required for provision under the INSPIRE Hydrography Network Data Specification.

#### hyn_watercourselink_v
The view hyn_watercourselink_v is the main table for provision of data for the hy-n:WatercourseLink Feature Type
```
CREATE OR REPLACE VIEW public.hyn_watercourselink_v
AS SELECT '_'::text || trm.idtronconh::text AS id,
    trm.cdtronconh,
    'http://services.sandre.eaufrance.fr/telechargement/geo/ETH/BDCarthage/FXX/2017/Bassins/TronconHydrograElt/'::text AS metadata,
    trm.idtronconh::text AS localid,
    'http://services.sandre.eaufrance.fr/telechargement/geo/ETH/BDCarthage/FXX/2017/Bassins/TronconHydrograElt/'::text AS namespace,
    1::text AS version,
    'http://service.datacove.eu/geoserver/ogc/features/collections/hy-n:HydroNode/items/_'::text AS ndurl,
    'http://service.datacove.eu/geoserver/ogc/features/collections/hy-n:WatercourseLink/items/_'::text AS segurl,
    'http://guid.datacove.eu/hyn/node/'::text AS genndurl,
    'http://guid.datacove.eu/hyn/link/'::text AS gensegurl,
        CASE
            WHEN trm.sens::text ~~ 'Sens du%'::text THEN 'http://inspire.ec.europa.eu/codelist/LinkDirectionValue/inDirection'::text
            ELSE NULL::text
        END AS flowdirection,
        CASE
            WHEN trm.sens::text ~~ 'Sens du%'::text THEN NULL::text
            ELSE 'true'::text
        END AS flowdirectionnil,
        CASE
            WHEN trm.sens::text ~~ 'Sens du%'::text THEN NULL::text
            ELSE 'missing'::text
        END AS flowdirectionnilvalue,
    st_length(trm.geom) AS lengthval,
    'm'::text AS lengthuom,
    NULL::text AS lengthnil,
    NULL::text AS lengthnilvalue,
    '2020-03-17 21:00:00'::text AS beginlsv,
    NULL::timestamp without time zone AS endlsv,
        CASE
            WHEN NOT trm.nomentiteh::text IS NULL THEN trm.nomentiteh::text
            WHEN NOT trm.candidat1::text IS NULL THEN trm.candidat1::text
            WHEN NOT trm.toponyme2::text IS NULL THEN trm.toponyme2::text
            ELSE NULL::text
        END AS geographicalname,
    trm.idnoeudhyd::text AS startnode,
    trm.idnoeudh_1::text AS endnode,
        CASE
            WHEN trm.sens::text ~~ 'Fict%'::text THEN 'true'::text
            ELSE 'false'::text
        END AS fict,
    'PT.'::text || trm.idtronconh AS geomid,
    trm.geom AS centreline
   FROM tronconhydrograelt_02_rhin_meuse trm;
```

#### hyn_link_hydroid_v

As a hy-n:WatercourseLink Feature Type can be associated with multiple Hydro Identifiers, this informtion must be provided in an additional table.
* FK: hyn_object --> hyn_watercourselink.id

```
CREATE OR REPLACE VIEW public.hyn_link_hydroid_v
AS SELECT '_'::text || trm.idtronconh::text AS hyn_object,
    trm.cdtronconh::text AS hydroid,
    'French Hydro codification circulaire n° 91-50 15th February 1991'::text AS hydroidclass,
    'http://French.Hydro.Namespace'::text AS hydroidns
   FROM tronconhydrograelt_02_rhin_meuse trm
  WHERE NOT trm.cdtronconh IS NULL;
```

### hy-n:HydroNode
The following views provide the node data in the structure required for provision under the INSPIRE Hydrography Network Data Specification.

#### hyn_hydronode_v
The view hyn_hydronode_v is the main table for provision of data for the hy-n:HydroNode Feature Type
```
CREATE OR REPLACE VIEW public.hyn_hydronode_v
AS SELECT '_'::text || nrm.idnoeudhyd::text AS id,
    'http://services.sandre.eaufrance.fr/telechargement/geo/ETH/BDCarthage/FXX/2017/Bassins/NoeudHydrographique/'::text AS metadata,
    nrm.idnoeudhyd::text AS localid,
    1::text AS version,
    'http://services.sandre.eaufrance.fr/telechargement/geo/ETH/BDCarthage/FXX/2017/Bassins/NoeudHydrographique/'::text AS namespace,
    '2020-03-17 21:00:00'::text AS beginlsv,
    NULL::timestamp without time zone AS endlsv,
    nrm.nomnoeudhy AS geographicalname,
        CASE
            WHEN nrm.nature::text ~~ 'Ouvrage %'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/junction'::text
            WHEN nrm.nature::text ~~ 'Source simple'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/source'::text
            WHEN nrm.nature::text ~~ 'Franchissement'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/junction'::text
            WHEN nrm.nature::text ~~ 'Barrage au fil%'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/flowRegulation'::text
            WHEN nrm.nature::text ~~ 'Barrage de retenue5'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/flowRegulation'::text
            WHEN nrm.nature::text ~~ 'Sans nature'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/boundary'::text
            WHEN nrm.nature::text ~~ 'Source d%'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/source'::text
            WHEN nrm.nature::text ~~ 'Chute d%'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/flowConstriction'::text
            WHEN nrm.nature::text ~~ 'Changement d%'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/boundary'::text
            WHEN nrm.nature::text ~~ 'Barrage au fil %'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/flowRegulation'::text
            WHEN nrm.nature::text ~~ 'Perte'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/outlet'::text
            WHEN nrm.nature::text ~~ 'Embouchure'::text THEN 'http://inspire.ec.europa.eu/codelist/HydroNodeCategoryValue/source'::text
            WHEN nrm.nature::text ~~ 'En attente de mise %'::text THEN '???'::text
            ELSE '?????'::text
        END AS nodecategory,
    false AS fictitious,
    'false'::text AS fict,
    'PT.'::text || nrm.idnoeudhyd::text AS geomid,
    'http://service.datacove.eu/geoserver/ogc/features/collections/hy-n:HydroNode/items/_'::text AS ndurl,
    'http://service.datacove.eu/geoserver/ogc/features/collections/hy-n:WatercourseLink/items/_'::text AS segurl,
    'http://guid.datacove.eu/hyn/node/'::text AS genndurl,
    'http://guid.datacove.eu/hyn/link/'::text AS gensegurl,
    nrm.geom
   FROM noeudhydrographique_02_rhin_meuse nrm;
```

#### hyn_node_hydroid_v

As a hy-n:HydroNode Feature Type can be associated with multiple Hydro Identifiers, this informtion must be provided in an additional table.
* FK: hyn_object --> hyn_watercourselink.id

```
CREATE OR REPLACE VIEW public.hyn_node_hydroid_v
AS WITH seg_hyd AS (
         SELECT nrm.idnoeudhyd,
            seg.cdtronconh
           FROM noeudhydrographique_02_rhin_meuse nrm
             LEFT JOIN tronconhydrograelt_02_rhin_meuse seg ON nrm.idnoeudhyd = seg.idnoeudhyd
          WHERE NOT seg.cdtronconh IS NULL
        UNION
         SELECT nrm.idnoeudhyd,
            seg.cdtronconh
           FROM noeudhydrographique_02_rhin_meuse nrm
             LEFT JOIN tronconhydrograelt_02_rhin_meuse seg ON nrm.idnoeudhyd = seg.idnoeudh_1
          WHERE NOT seg.cdtronconh IS NULL
        )
 SELECT DISTINCT ON (seg_hyd.idnoeudhyd) '_'::text || seg_hyd.idnoeudhyd AS hyn_object,
    seg_hyd.cdtronconh AS hydroid,
    'French Hydro codification circulaire n° 91-50 15th February 1991'::text AS hydroidclass,
    'http://French.Hydro.Namespace'::text AS hydroidns
   FROM seg_hyd;
```

### hy-n:WatercourseLinkSequence

### ID Function

The following function is used to generate an identifier by concatenating the localId with the version. 
This function can also be expanded to add a ```'_'``` prefix as required for provision of a gml:id from a numeric identifier.

```
CREATE OR REPLACE FUNCTION public.set_id_tnw()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$

	BEGIN
		NEW.id := NEW.localid || '-' || NEW.version;
	RETURN NEW;
END 

$function$
;
```
