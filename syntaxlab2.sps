* Encoding: UTF-8.
*descriptive statistics of the variables with kurtosis and skewness

DATASET ACTIVATE DataSet2.
DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

*frequencies of variables including ID

FREQUENCIES VARIABLES=ID pain age male STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.

*MANUALLY CHANGED ID 142 entry of 'pain' from 50 to 5 in data view
*MANUALLY CHANGED ID 49 entry 'mindfulness' from 6.22 to 5.22 in data view


*recoded 'sex' into dummy variable, also taking into account the error of ID 35 which was coded as "women"

DATASET ACTIVATE DataSet1.
RECODE sex ('female'=0) ('women'=0) ('male'=1) (MISSING=SYSMIS) INTO male.
EXECUTE.


*running descriptives and frequencies again to check the changed variables


DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

FREQUENCIES VARIABLES=ID pain age male STAI_trait pain_cat cortisol_serum cortisol_saliva mindfulness
  /HISTOGRAM NORMAL
  /ORDER=ANALYSIS.



* Chart Builder. Scatterplots of the outcome variable and predicting variables

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain=col(source(s), name("pain"), unit.category())
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by age"))
  ELEMENT: point(position(age*pain))
END GPL.


* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"), unit.category())
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by pain_cat"))
  ELEMENT: point(position(pain_cat*pain))
END GPL.



* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: pain=col(source(s), name("pain"), unit.category())
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_saliva pain MISSING=LISTWISE REPORTMISSING=NO    
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_saliva=col(source(s), name("cortisol_saliva"))
  DATA: pain=col(source(s), name("pain"), unit.category())
  GUIDE: axis(dim(1), label("cortisol_saliva"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by cortisol_saliva"))
  ELEMENT: point(position(cortisol_saliva*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: pain=col(source(s), name("pain"), unit.category())
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by mindfulness"))
  ELEMENT: point(position(mindfulness*pain))
END GPL.


*regression with cooks distance, plots: zresid and zpred and normal prob. 

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age male
  /METHOD=ENTER age male STAI_trait pain_cat mindfulness cortisol_saliva cortisol_serum
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.

*Scatterplot of Cooks distance and case number ID

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID COO_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: COO_1=col(source(s), name("COO_1"))
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("Cook's Distance"))
  GUIDE: text.title(label("Simple Scatter of Cook's Distance by ID"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(ID*COO_1))
END GPL.

*histogram and normality plots with tests

EXAMINE VARIABLES=RES_1
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.


* Chart Builder. scatterplots of outcome variable and prediciting variables to check linearity and added loeses lines

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=age pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: age=col(source(s), name("age"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("age"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by age"))
  ELEMENT: point(position(age*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=male pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: male=col(source(s), name("male"), unit.category())
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("male"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by male"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(male*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=STAI_trait pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: STAI_trait=col(source(s), name("STAI_trait"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("STAI_trait"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by STAI_trait"))
  ELEMENT: point(position(STAI_trait*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=pain_cat pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: pain_cat=col(source(s), name("pain_cat"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("pain_cat"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by pain_cat"))
  ELEMENT: point(position(pain_cat*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_serum pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_serum=col(source(s), name("cortisol_serum"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("cortisol_serum"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by cortisol_serum"))
  ELEMENT: point(position(cortisol_serum*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=cortisol_saliva pain MISSING=LISTWISE REPORTMISSING=NO    
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: cortisol_saliva=col(source(s), name("cortisol_saliva"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("cortisol_saliva"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by cortisol_saliva"))
  ELEMENT: point(position(cortisol_saliva*pain))
END GPL.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=mindfulness pain MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: mindfulness=col(source(s), name("mindfulness"))
  DATA: pain=col(source(s), name("pain"))
  GUIDE: axis(dim(1), label("mindfulness"))
  GUIDE: axis(dim(2), label("pain"))
  GUIDE: text.title(label("Simple Scatter of pain by mindfulness"))
  ELEMENT: point(position(mindfulness*pain))
END GPL.

*computing variable and creating a variable for squared residuals res_sq

COMPUTE res_sq=RES_1 * RES_1.
EXECUTE.

*regression predicting the squared residuals to check for heteroscedasticity

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT res_sq
  /METHOD=ENTER age male
  /METHOD=ENTER age male STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva
 

*regression with collinearity diagnostics

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age male
  /METHOD=ENTER age male STAI_trait pain_cat mindfulness cortisol_serum cortisol_saliva
 
* regression with collinearity diagnostics without variable cortisol saliva

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age male
  /METHOD=ENTER age male STAI_trait pain_cat mindfulness cortisol_serum



*PART 2. Running the new model where cortisol saliva is removed to check for assumptions

* regression without cortisol saliva with collinearity diagnostics, cooks etc.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age male
  /METHOD=ENTER age male STAI_trait pain_cat mindfulness cortisol_serum
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.

*explore histogram

EXAMINE VARIABLES=RES_2
  /PLOT BOXPLOT STEMLEAF HISTOGRAM NPPLOT
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

 
*computing a squared residuals variable

COMPUTE res_sq2=RES_2 * RES_2.
EXECUTE.

*regression with squared residuas as dependent variable to do a breuch pagan test

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT res_sq2
  /METHOD=ENTER age male
  /METHOD=ENTER age male STAI_trait pain_cat mindfulness cortisol_serum
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS HISTOGRAM(ZRESID) NORMPROB(ZRESID).

*PART 3 COMPARING MODELS

*regression Likelihood ratio test with R squared change

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age male
  /METHOD=ENTER age male STAI_trait pain_cat mindfulness cortisol_serum
  /SCATTERPLOT=(*ZRESID ,*ZPRED).

*regression with AIC

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) R ANOVA SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age male
  /METHOD=ENTER age male STAI_trait pain_cat mindfulness cortisol_serum
  /SCATTERPLOT=(*ZRESID ,*ZPRED).


