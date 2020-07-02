# API4INSPIRE Hydrography Network Mapping for BRGM

In the following sections, we provide information on the source data used and transformations required for the provision of Hydrography Networks under the INSPIRE Schema [https://inspire.ec.europa.eu/schemas/hy-n/4.0/HydroNetwork.xsd](https://inspire.ec.europa.eu/schemas/hy-n/4.0/HydroNetwork.xsd)

The following sections we describe the data sources, mapping to INSPIRE featureTypes and creation of views for App Schema Mapping for the following featureTypes:
* hy-n:WatercourseLink: A segment within the Hydrography Network
* hy-n:HydroNode: A node within the Hydrography Network
* hy-n:WatercourseLinkSequence: A set of WatercourseLink feature types comprising a Watercourse Sequence. Corresponds to cdtronconh

## Data Sources

### Segments

The source data for the French River Segments was imported from the ShapeFile TronconHydrograElt_02_Rhin-Meuse. This data was imported into a PostGIS DB via QGIS. 
All further mapping is done from the resulting database table, whereby the attribute names from the Shapefile were retained.

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

## Mapping from Source Data to INSPIRE Models

The mapping from the source data to the INSPIRE data models was done as Google Sheets, one for each INSPIRE Type to be provided. The table has the following columns:
* DB Table: The view from which the data element is made available for GeoServer App Schema Mapping.
* DB Column: The column within the view from which the data element is made available for GeoServer App Schema Mapping.
* {featureTypeName}: The target DataType, alternatively ```hy-n:WatercourseLink```, ```hy-n:WatercourseLinkSequence``` or ```Hy-n:HydroNode```
* shp attribute: Attribute for the data element within the shapefile.
* Constant: Constant value if required. This column also contains information on prefixes applied to data taken from the DB table.

The tab "Hydro Node Category" provides the mapping from values in the Shapefile attribute nature to corresponding values from the INSPIRE HydroNodeCategory Codelist for the element ```hy-n:hydroNodeCategory``` under ```Hy-n:HydroNode```.

[Mapping Sheet](https://docs.google.com/spreadsheets/d/1ckKaNaxTmWQz6kWyLpMuLVvU62plQWxv_oEYB3pIUcw/edit)

## Views for App Schema Mapping

The following sections we describe the views created to transform the source data described above in accordance with the mapping.

All sql for the views is available from [https://github.com/INSIDE-information-systems/API4INSPIRE/blob/master/sql/Hydrography.sql](https://github.com/INSIDE-information-systems/API4INSPIRE/blob/master/sql/Hydrography.sql)

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
The following views provide data on sequences of segments to be provided as a WatercourseLinkSequence in the structure required for provision under the INSPIRE Hydrography Network Data Specification.

#### hyn_linksequence_v
The view hyn_linksequence_v is the main table for provision of data for the hy-n:WatercourseLinkSequence Feature Type
```
CREATE OR REPLACE VIEW public.hyn_linksequence_v
AS SELECT DISTINCT trm.cdtronconh AS id,
    'http://services.sandre.eaufrance.fr/telechargement/geo/ETH/BDCarthage/FXX/2017/Bassins/TronconHydrograElt/????'::text AS metadata,
    trm.cdtronconh::text AS localid,
    'http://services.sandre.eaufrance.fr/telechargement/geo/ETH/BDCarthage/FXX/2017/Bassins/TronconHydrograElt/????'::text AS namespace,
    '1'::text AS version,
    '2020-03-17 21:00:00'::text AS beginlsv,
    NULL::timestamp without time zone AS endlsv,
    'http://service.datacove.eu/geoserver/ogc/features/collections/hy-n:WatercourseLinkSequence/items/_'::text AS sequurl,
    'http://guid.datacove.eu/hyn/sequ/'::text AS gensequurl
   FROM tronconhydrograelt_02_rhin_meuse trm
  WHERE NOT trm.cdtronconh IS NULL;
```

#### Links from hyn_watercourselink_v

The information on the individual segments comprising the watercourse link sequence are taken from the same table as used to provide data on the individual segments.

* FK: cdtronconh --> hyn_watercourselink.id
