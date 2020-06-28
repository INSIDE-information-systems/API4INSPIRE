# API4INSPIRE Hydrography Network Mapping for BRGM

In the following sections, we provide information on the source data used and transformations required for the provision of Hydrography Networks under the INSPIRE Schema (https://inspire.ec.europa.eu/schemas/hy-n/4.0/HydroNetwork.xsd )[https://inspire.ec.europa.eu/schemas/hy-n/4.0/HydroNetwork.xsd ]

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

### hy-n:HydroNode

### hy-n:WatercourseLinkSequence


