-- hy-n:WatercourseLink
--
-- hyn_watercourselink_v - Main table for WatercourseLink
--

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
   
--
-- hyn_link_hydroid_v - linked table for Hydro ID on WatercourseLink
-- FK: hyn_object --> hyn_watercourselink_v.id
--
   
CREATE OR REPLACE VIEW public.hyn_link_hydroid_v
AS SELECT '_'::text || trm.idtronconh::text AS hyn_object,
    trm.cdtronconh::text AS hydroid,
    'French Hydro codification circulaire n° 91-50 15th February 1991'::text AS hydroidclass,
    'http://French.Hydro.Namespace'::text AS hydroidns
   FROM tronconhydrograelt_02_rhin_meuse trm
  WHERE NOT trm.cdtronconh IS NULL;   
  
  
-- hy-n:HydroNode
--
-- hyn_hydronode_v - Main table for HydroNode
--  

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
   
--
-- hyn_node_hydroid_v - linked table for Hydro ID on HydroNode
-- FK: hyn_object --> hyn_hydronode_v.id
--   

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
   
-- hy-n:WatercourseLinkSequence
--
-- hyn_linksequence_v - Main table for WatercourseLinkSequence
--    

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
