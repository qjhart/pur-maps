#! /usr/bin/make -f
# This Makefile is designed to be included, in a more comprehenisve makefile.
ifndef configure.mk
include ../configure.mk
endif

# S is schema
S:=pur

# If included somewhere else
$S.mk:=1

year:=2009

INFO::
	@echo This makefile is for creating data products from the PUC database.

.PHONY:db 
db:: db/$S db/$S.pls

db/$S:
	[[ -d db]] || mkdir db
	${PG} -f $S.sql

clean:

# These are the GIS data used for the locating the pesticides.
$S.pls.url:=https://projects.atlas.ca.gov/frs/download.php/663/State_pls.ZIP
$S.pls.shp:=plsnet_nad83.shp

$S.mtr.url:=https://projects.atlas.ca.gov/frs/download.php/662/State_mtr.ZIP
$S.mtr.shp:=mtrnet_nad83.shp

db/$S.pls:db/%:db/$S
	[[ -f down/${$*.shp} ]] || ( cd down; wget ${$*.url}; unzip $(notdir ${$*.url}) )
	${shp2pgsql} -D -d -s 3310 -g teale -S down/${$*.shp} $* | ${PG} > /dev/null
	${PG} -c "select AddGeometryColumn('$S',$(subst .,,$(suffix $*))','boundary',$(srid),'POLYGON',2);"
#	${PG} -c "update $* set centroid=transform(nad83,${srid}); create index city_centroid_gist on city using gist(centroid gist_geometry_ops);"
#	${PG} -c "alter table $* add column qid char(8); update $* set qid='D'||state_fips||fips55;"
	touch $@






