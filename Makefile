#! /usr/bin/make -f

include configure.mk

# Sometime we include this in other locations. If included somewhere else check for this 
pur.mk:=1

year:=2010

INFO::
	@echo Creating data products from the PUR database.

# In order to use our PostGIS import, we include some standard
# configuration file.  This is pulled from a specific version, as a
# github GIST.  This, we probably don't save in our repo.  Want users
# to see where it came from.  Update to newer version if required.
configure.mk:gist:=https://gist.githubusercontent.com/qjhart/052c63d3b1a8b48e4d4f
configure.mk:
	wget ${gist}/raw/e30543c3b8d8ff18a950750a0f340788cc8c1931/configure.mk


mtrs.geojson:mtrs.vrt 
	ogr2ogr -f GEOJSON $@ $<

.PHONY:db 
db:: db/pur db/pur.pls

db/pur:
	[[ -d db]] || mkdir db
	${PG} -f pur.sql

clean:

db/pur.pls:db/%:db/pur
	[[ -f down/${$*.shp} ]] || ( cd down; wget ${$*.url}; unzip $(notdir ${$*.url}) )
	${shp2pgsql} -D -d -s 3310 -g teale -S down/${$*.shp} $* | ${PG} > /dev/null
	${PG} -c "select AddGeometryColumn('pur',$(subst .,,$(suffix $*))','boundary',$(srid),'POLYGON',2);"
#	${PG} -c "update $* set centroid=transform(nad83,${srid}); create index city_centroid_gist on city using gist(centroid gist_geometry_ops);"
#	${PG} -c "alter table $* add column qid char(8); update $* set qid='D'||state_fips||fips55;"
	touch $@

pur${year}:mirror:=pestreg.cdpr.ca.gov/pub/outgoing/pur_archives
pur${year}:
	wget --mirror ftp://${mirror}/pur${year}.zip;\
	mkdir $@;\
	cd $@; unzip ../${mirror}/pur${year}.zip

mirror:gis:=pestreg.cdpr.ca.gov/pub/outgoing/gis
mirror:
	wget --mirror ftp://${gis}/plsnet.*
	wget --mirror ftp://${gis}/DWR_LANDUSE*
	wget --mirror ftp://${gis}/PLSMETA*
