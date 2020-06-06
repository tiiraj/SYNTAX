* Encoding: UTF-8.

*descriptives of the variables

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat mindfulness cortisol_serum
  /STATISTICS=MEAN STDDEV MIN MAX.

*frequencies with histograms

FREQUENCIES VARIABLES=ID pain age sex STAI_trait pain_cat mindfulness cortisol_serum hospital
  /HISTOGRAM
  /ORDER=ANALYSIS.

*dummycoding of gender

RECODE sex ('female'=0) ('male'=1) ('Male'=1) INTO male.
EXECUTE.

FREQUENCIES VARIABLES=male
  /ORDER=ANALYSIS.

* Chart Builder. scatterplot exploring the relationship

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain hospital MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by age by hospital"))
  ELEMENT: point(position(age*pain), color.interior(hospital))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=sex pain hospital MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: sex=col(source(s), name("sex"), unit.category())
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("sex"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by sex by hospital"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(sex*pain), color.interior(hospital))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by STAI_trait by hospital"))
  ELEMENT: point(position(STAI_trait*pain), color.interior(hospital))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by pain_cat by hospital"))
  ELEMENT: point(position(pain_cat*pain), color.interior(hospital))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by mindfulness by hospital"))
  ELEMENT: point(position(mindfulness*pain), color.interior(hospital))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum pain hospital MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: pain=col(source(s), name("pain"))
  DATA: hospital=col(source(s), name("hospital"), unit.category())
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("hospital"))
  GUIDE: text.title(label("Grouped Scatter of pain by cortisol_serum by hospital"))
  ELEMENT: point(position(cortisol_serum*pain), color.interior(hospital))
END GPL.

*random intercept model

MIXED pain WITH age male STAI_trait pain_cat mindfulness cortisol_serum
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age male STAI_trait pain_cat mindfulness cortisol_serum | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC).

*save fixed predicted values 

MIXED pain WITH age male STAI_trait pain_cat mindfulness cortisol_serum
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age male STAI_trait pain_cat mindfulness cortisol_serum | SSTYPE(3)
  /METHOD=REML
  /RANDOM=INTERCEPT | SUBJECT(hospital) COVTYPE(VC)
  /SAVE=FIXPRED.

*getting the variance

DESCRIPTIVES VARIABLES=FXPRED_1
  /STATISTICS=MEAN STDDEV VARIANCE MIN MAX.


*** OPEN DATASET B***
  
 *descriptives
  
 DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat mindfulness cortisol_serum
  /STATISTICS=MEAN STDDEV MIN MAX.

*frequencies

FREQUENCIES VARIABLES=ID pain sex age STAI_trait pain_cat mindfulness cortisol_serum hospital
  /ORDER=ANALYSIS.

*recoding gender into dummy

RECODE sex ('female'=0) ('male'=1) INTO male.
EXECUTE.

*regression equation in compute variable dataset B

COMPUTE PREDvalue_modelA=3.502 - 0.054 * age + 0.298 * male + 0.001 * STAI_trait + 0.037 * pain_cat 
    - 0.262 * mindfulness + 0.610 * cortisol_serum.
EXECUTE.

*computing residual error 

COMPUTE RESID_error=pain - PREDvalue_modelA.
EXECUTE.

*residual error squared new variable

COMPUTE RESID_error_sq=RESID_error * RESID_error.
EXECUTE.

*getting the residual sum of square

DESCRIPTIVES VARIABLES=RESID_error_sq
  /STATISTICS=MEAN SUM STDDEV MIN MAX.

*computing mean difference

COMPUTE mean_difference_pain=pain - 5.20.
EXECUTE.

*squared difference

COMPUTE difference_sq=mean_difference_pain * mean_difference_pain.
EXECUTE.

*TSS

DESCRIPTIVES VARIABLES=difference_sq
  /STATISTICS=MEAN SUM STDDEV MIN MAX.


