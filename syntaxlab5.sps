* Encoding: UTF-8.

*descriptve statistics of the variables

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=pain1 pain2 pain3 pain4 age STAI_trait pain_cat cortisol_serum mindfulness
  /STATISTICS=MEAN STDDEV MIN MAX.


*frequencies

FREQUENCIES VARIABLES=ID pain1 pain2 pain3 pain4 sex age STAI_trait pain_cat cortisol_serum 
    mindfulness
  /ORDER=ANALYSIS.


*gender dummy coded

RECODE sex ('female'=0) ('male'=1) INTO male.
EXECUTE.


*exploring repeated measures data correlation

CORRELATIONS
  /VARIABLES=pain1 pain2 pain3 pain4
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.


*restructuring from wide format to long format

VARSTOCASES 
  /MAKE pain_postop FROM pain1 pain2 pain3 pain4
  /INDEX=time_days(4) 
  /KEEP=ID sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness weight IQ household_income male
  /NULL=KEEP.


* Chart Builder. scatterplot pain_postop and time

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_days pain_postop MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_days=col(source(s), name("time_days"), unit.category())
  DATA: pain_postop=col(source(s), name("pain_postop"))
  GUIDE: axis(dim(1), label("time_days"))
  GUIDE: axis(dim(2), label("pain_postop"))
  GUIDE: text.title(label("Simple Scatter of pain_postop by time_days"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(time_days*pain_postop))
END GPL.


* Chart Builder. Simple line plot pain_postop and time


GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_days MEAN(pain_postop)[name="MEAN_pain_postop"] 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_days=col(source(s), name("time_days"), unit.category())
  DATA: MEAN_pain_postop=col(source(s), name("MEAN_pain_postop"))
  GUIDE: axis(dim(1), label("time_days"))
  GUIDE: axis(dim(2), label("Mean pain_postop"))
  GUIDE: text.title(label("Simple Line Mean of pain_postop by time_days"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time_days*MEAN_pain_postop), missing.wings())
END GPL.

*random intercept model


MIXED pain_postop WITH male age STAI_trait pain_cat mindfulness cortisol_serum time_days
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=male age STAI_trait pain_cat mindfulness cortisol_serum time_days | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
  /SAVE=PRED.


* random slope model

MIXED pain_postop WITH male age STAI_trait pain_cat mindfulness cortisol_serum time_days
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=male age STAI_trait pain_cat mindfulness cortisol_serum time_days | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT time_days | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.

*restructuring of the data again. 

VARSTOCASES
  /MAKE pain_postop FROM pain_postop PRED_INTER PRED_SLOPE
  /INDEX=data_type(pain_postop)
  /KEEP=ID sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness weight IQ household_income male time_days
  /NULL=KEEP.
 

* Chart Builder. Line graph for time and pain_postop with color data_type

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_days MEAN(pain_postop)[name="MEAN_pain_postop"] 
    data_type MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_days=col(source(s), name("time_days"), unit.category())
  DATA: MEAN_pain_postop=col(source(s), name("MEAN_pain_postop"))
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time_days"))
  GUIDE: axis(dim(2), label("Mean pain_postop"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line Mean of pain_postop by time_days by data_type"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time_days*MEAN_pain_postop), color.interior(data_type), missing.wings())
END GPL.

*SPLT FILE

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

* Chart Builder. For every participant separately

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_days MEAN(pain_postop)[name="MEAN_pain_postop"] 
    data_type MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_days=col(source(s), name("time_days"), unit.category())
  DATA: MEAN_pain_postop=col(source(s), name("MEAN_pain_postop"))
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time_days"))
  GUIDE: axis(dim(2), label("Mean pain_postop"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line Mean of pain_postop by time_days by data_type"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time_days*MEAN_pain_postop), color.interior(data_type), missing.wings())
END GPL.


***going back to the old document manually***

*centering time

COMPUTE centered_time=time_days - 2.5.
EXECUTE.

*computing a squared centered time variable

COMPUTE centered_time_squared=centered_time * centered_time.
EXECUTE.

*random slope model with centered and quadratic term. random slope: centered_time

MIXED pain_postop WITH male age STAI_trait pain_cat mindfulness cortisol_serum centered_time 
    centered_time_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=male age STAI_trait pain_cat mindfulness cortisol_serum centered_time 
    centered_time_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT centered_time | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED RESID.


*restructruing from wide to long with: pain_postop, predicetd value random slope, predicted values random slope_time_sq

VARSTOCASES 
  /MAKE pain_postop FROM pain_postop PRED_SLOPE PRED_slope_timeSQ 
  /INDEX=data_type(pain_postop) 
  /KEEP=ID sex age STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness weight IQ household_income male time_days PRED_INTER centered_time centered_time_squared RESID_slope_timeSQ 
  /NULL=KEEP
  


* Chart Builder. line gragh, painpostop, time and datatyp

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_days MEAN(pain_postop)[name="MEAN_pain_postop"] 
    data_type MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_days=col(source(s), name("time_days"), unit.category())
  DATA: MEAN_pain_postop=col(source(s), name("MEAN_pain_postop"))
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time_days"))
  GUIDE: axis(dim(2), label("Mean pain_postop"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line Mean of pain_postop by time_days by data_type"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time_days*MEAN_pain_postop), color.interior(data_type), missing.wings())
END GPL.

*split file to look at graphs for each participants 

SORT CASES  BY ID.
SPLIT FILE SEPARATE BY ID.

* Chart Builder. For each participant with random slope and time_sq

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_days MEAN(pain_postop)[name="MEAN_pain_postop"] 
    data_type MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_days=col(source(s), name("time_days"), unit.category())
  DATA: MEAN_pain_postop=col(source(s), name("MEAN_pain_postop"))
  DATA: data_type=col(source(s), name("data_type"), unit.category())
  GUIDE: axis(dim(1), label("time_days"))
  GUIDE: axis(dim(2), label("Mean pain_postop"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("data_type"))
  GUIDE: text.title(label("Multiple Line Mean of pain_postop by time_days by data_type"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time_days*MEAN_pain_postop), color.interior(data_type), missing.wings())
END GPL.


***Model diagnostics***

* Chart Builder. graph to check for outliers

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=time_days MEAN(pain_postop)[name="MEAN_pain_postop"] 
    ID MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: time_days=col(source(s), name("time_days"), unit.category())
  DATA: MEAN_pain_postop=col(source(s), name("MEAN_pain_postop"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  GUIDE: axis(dim(1), label("time_days"))
  GUIDE: axis(dim(2), label("Mean pain_postop"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("ID"))
  GUIDE: text.title(label("Multiple Line Mean of pain_postop by time_days by ID"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(time_days*MEAN_pain_postop), color.interior(ID), missing.wings())
END GPL.


*boxplot

EXAMINE VARIABLES=pain_postop BY ID
  /PLOT BOXPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.




*explore residuals to check for normality

EXAMINE VARIABLES=RESID_slope_timeSQ
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

* Chart Builder. Check for linearity. Scatterplot residuals and predicted values

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=PRED_slope_timeSQ RESID_slope_timeSQ MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: PRED_slope_timeSQ=col(source(s), name("PRED_slope_timeSQ"))
  DATA: RESID_slope_timeSQ=col(source(s), name("RESID_slope_timeSQ"))
  GUIDE: axis(dim(1), label("Predicted Values"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by Predicted Values"))
  ELEMENT: point(position(PRED_slope_timeSQ*RESID_slope_timeSQ))
END GPL.

*Chart builder. Scatterplots of residuals and fixed predictors

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age RESID_slope_timeSQ MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: RESID_slope_timeSQ=col(source(s), name("RESID_slope_timeSQ"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by age"))
  ELEMENT: point(position(age*RESID_slope_timeSQ))
END GPL.


GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=male RESID_slope_timeSQ MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: male=col(source(s), name("male"), unit.category())
  DATA: RESID_slope_timeSQ=col(source(s), name("RESID_slope_timeSQ"))
  GUIDE: axis(dim(1), label("male"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by male"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(male*RESID_slope_timeSQ))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait RESID_slope_timeSQ MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: RESID_slope_timeSQ=col(source(s), name("RESID_slope_timeSQ"))
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by STAI_trait"))
  ELEMENT: point(position(STAI_trait*RESID_slope_timeSQ))
END GPL.



* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat RESID_slope_timeSQ MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: RESID_slope_timeSQ=col(source(s), name("RESID_slope_timeSQ"))
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by pain_cat"))
  ELEMENT: point(position(pain_cat*RESID_slope_timeSQ))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness RESID_slope_timeSQ MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: RESID_slope_timeSQ=col(source(s), name("RESID_slope_timeSQ"))
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by mindfulness"))
  ELEMENT: point(position(mindfulness*RESID_slope_timeSQ))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum RESID_slope_timeSQ MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: RESID_slope_timeSQ=col(source(s), name("RESID_slope_timeSQ"))
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*RESID_slope_timeSQ))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=centered_time RESID_slope_timeSQ MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: centered_time=col(source(s), name("centered_time"))
  DATA: RESID_slope_timeSQ=col(source(s), name("RESID_slope_timeSQ"))
  GUIDE: axis(dim(1), label("centered_time"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by centered_time"))
  ELEMENT: point(position(centered_time*RESID_slope_timeSQ))
END GPL.



* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=centered_time_squared RESID_slope_timeSQ 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: centered_time_squared=col(source(s), name("centered_time_squared"))
  DATA: RESID_slope_timeSQ=col(source(s), name("RESID_slope_timeSQ"))
  GUIDE: axis(dim(1), label("centered_time_squared"))
  GUIDE: axis(dim(2), label("Residuals"))
  GUIDE: text.title(label("Simple Scatter of Residuals by centered_time_squared"))
  ELEMENT: point(position(centered_time_squared*RESID_slope_timeSQ))
END GPL.


*multicollinearity

CORRELATIONS
  /VARIABLES=age male STAI_trait pain_cat mindfulness cortisol_serum centered_time 
    centered_time_squared
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.


*constant variance of residuals around clusters 

*creating dummy variables of ID

SPSSINC CREATE DUMMIES VARIABLE=ID 
ROOTNAME1=ID_dummy 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.



*computing squared residuals from residuals of the model (timeSQ means that it is from the model that used squared time)

COMPUTE RESID_SQ=RESID_slope_timeSQ*RESID_slope_timeSQ.
EXECUTE.


*regression

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS R ANOVA
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT RESID_SQ
  /METHOD=ENTER ID_dummy_2 ID_dummy_3 ID_dummy_4 ID_dummy_5 ID_dummy_6 ID_dummy_7 ID_dummy_8 
    ID_dummy_9 ID_dummy_10 ID_dummy_11 ID_dummy_12 ID_dummy_13 ID_dummy_14 ID_dummy_15 ID_dummy_16 
    ID_dummy_17 ID_dummy_18 ID_dummy_19 ID_dummy_20.


*normal distribution of random effects

*model adding SOLUTION

MIXED pain_postop WITH male age STAI_trait pain_cat mindfulness cortisol_serum centered_time 
    centered_time_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=male age STAI_trait pain_cat mindfulness cortisol_serum centered_time 
    centered_time_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT centered_time | SUBJECT(ID) COVTYPE(UN) SOLUTION
  /SAVE=PRED RESID.


DATASET ACTIVATE DataSet2.

*explore random effects

EXAMINE VARIABLES=VAR00001
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


*dependency structure of the random effects

MIXED pain_postop WITH male age STAI_trait pain_cat mindfulness cortisol_serum centered_time 
    centered_time_squared
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=male age STAI_trait pain_cat mindfulness cortisol_serum centered_time 
    centered_time_squared | SSTYPE(3)
  /METHOD=REML
  /PRINT=CORB  SOLUTION
  /RANDOM=INTERCEPT centered_time | SUBJECT(ID) COVTYPE(UN)


