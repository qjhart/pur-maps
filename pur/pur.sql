drop schema pur cascade;
create schema pur;
set search_path=pur,public;
set datestyle=MDY;

create function pur_date(char(8))
RETURNS date AS 
$$
select date substr($1,1,2)||'-'||substr($1,3,2)||'-'||substr($1,5,4);
$$ LANGUAGE SQL;

create domain application_unit as char
CHECK(
   VALUE in ('?','A','C','S','U')
);

comment on application_unit is 'This is the unit designation for the
application of the pesticide.  Used for acre_planted and acres_applied
fields in the UDC codes.  Codes are: A=acres, S=square feet, C=cubic
feet, K=thousand cubic feet, U= Misc. Examples of misc. units include:
bins, tree holes, bunches, pallets, etc.'

create table chemical (
CHEM_CODE decimal(5,0) primary key,
CHEMALPHA_CD decimal(8),
CHEMNAME varchar(171)
);
\copy chemical from chemical.txt CSV HEADER;

create table CAS_Number (
CHEM_CODE decimal(5,0) references chemical,
CAS_NUMBER char(12)
);
\copy cas_number from chem_cas.txt CSV HEADER;

create table site (
SITE_CODE decimal(6,0) primary key,
SITE_NAME varchar(50)
);
\copy site from site.txt CSV HEADER;

create table Formula (
FORMULA_CD char(2) primary key,
FORMULA_DSC varchar(50)
);
\copy formula from formula.txt CSV HEADER;

create table Qualify (
QUALIFY_CD decimal(3,0) primary key,
QUALIFY_DSC varchar(50)
);
\copy qualify from qualify.txt CSV HEADER;

create table County (
COUNTY_CD char(2) primary key,
COUNTY_NAME varchar(15)
);
\copy county from county.txt CSV HEADER;

create table product(
prodno decimal(6,0) primary key,
mfg_firmno decimal(7,0),
reg_firmno decimal(7,0),
LABEL_SEQ_NO  decimal(5,0),	
REVISION_NO   char(2),	
FUT_FIRMNO    decimal(7,0),
PRODSTAT_IND  char(1),	
PRODUCT_NAME  varchar(100),	
SHOW_REGNO    varchar(24),	
AER_GRND_IND  char(1),	
AGRICCOM_SW   char(1),	
CONFID_SW     char(1),	
DENSITY	      decimal(7,3),
FORMULA_CD    char(2) references formula,	
FULL_EXP_DT   char(8),
FULL_ISS_DT   char(8),
FUMIGANT_SW   char(1),	
GEN_PEST_IND  char(1),	
LASTUP_DT     char(8),
MFG_REF_SW    char(1),	
PROD_INAC_DT  char(8),
REG_DT	      char(8),
REG_TYPE_IND  char(1),	
RODENT_SW     char(1),	
SIGNLWRD_IND  decimal(9,0),
SOILAPPL_SW   char(1),	
SPECGRAV_SW   char(1),	
SPEC_GRAVITY  decimal(7,4),
CONDREG_SW    char(1)
);
\copy product from product.txt CSV HEADER;
--FULL_EXP_DT   date,
--FULL_ISS_DT   date,
--LASTUP_DT     date,
--PROD_INAC_DT  date,
--REG_DTdate,

create table udc (
use_no decimal(8,0),
prodno decimal(8,0) references product,
chem_code decimal(5,0) references chemical,
prodchem_pct decimal(10,5),
lbs_chm_used float,
lbs_prd_used decimal(15,4),
amt_prd_used decimal(13,4),
unit_of_meas char(2),
acre_planted decimal(8,2),
unit_planted char(1),
acre_treated decimal(8,2),
unit_treated char(1),
applic_cnt decimal(6,0),
applic_dt date,
applic_time char(4), -- time HHMM,
county_cd char(2) references county,
base_ln_mer char(1),
township char(2),
tship_dir char(1),
range char(2),
range_dir char(1),
section char(2),
site_loc_id char(8),
grower_id char(11),
license_no char(13),
planting_seq decimal(1,0),
aer_gnd_ind char(1),
site_code decimal(6,0) references site,
qualify_cd decimal(2,0) references qualify,
batch_no decimal(4,0),
document_no char(8),
summary_cd decimal(4,0),
record_id char(1),
comtrs varchar(12),
error_flag char(2)
-- chem_code is NULL
--primary key(use_no,chem_code)
);
-- Many copies
--\copy from CSV HEADER;
