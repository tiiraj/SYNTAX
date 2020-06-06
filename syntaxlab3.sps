* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.

*descriptives 


DESCRIPTIVES VARIABLES=PassengerId Survived Pclass Age SibSp Parch Fare
  /STATISTICS=MEAN STDDEV MIN MAX.


*frequencies

FREQUENCIES VARIABLES=PassengerId Survived Pclass Name Sex Age SibSp Parch Ticket Fare Cabin 
    Embarked
  /ORDER=ANALYSIS.


* Chart Builder. stacked bar chart with p class and survival

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Pclass COUNT()[name="COUNT"] Survived 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Pclass=col(source(s), name("Pclass"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Pclass"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Pclass by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Pclass*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.


* Chart Builder. stacked bar chart withsex and survival

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Sex COUNT()[name="COUNT"] Survived MISSING=LISTWISE 
    REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Sex=col(source(s), name("Sex"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Sex"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Sex by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Sex*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.


*recoded sex into summy varibale

RECODE Sex ('male'=0) ('female'=1) (MISSING=SYSMIS) INTO female.
EXECUTE.


* Chart Builder.  stacked bar chart with embarked and survival

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Embarked COUNT()[name="COUNT"] Survived 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Embarked=col(source(s), name("Embarked"), unit.category())
  DATA: COUNT=col(source(s), name("COUNT"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  GUIDE: axis(dim(1), label("Embarked"))
  GUIDE: axis(dim(2), label("Count"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Survived"))
  GUIDE: text.title(label("Stacked Bar Count of Embarked by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: interval.stack(position(Embarked*COUNT), color.interior(Survived), 
    shape.interior(shape.square))
END GPL.


*crosstab embarked survived

CROSSTABS
  /TABLES=Embarked BY Survived
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW 
  /COUNT ROUND CELL.


*crosstab embarked and class

CROSSTABS
  /TABLES=Embarked BY Pclass
  /FORMAT=AVALUE TABLES
  /CELLS=COUNT ROW 
  /COUNT ROUND CELL.


* Chart Builder. Boxplot age and class

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Pclass Age MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Pclass=col(source(s), name("Pclass"), unit.category())
  DATA: Age=col(source(s), name("Age"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Pclass"))
  GUIDE: axis(dim(2), label("Age"))
  GUIDE: text.title(label("Simple Boxplot of Age by Pclass"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Pclass*Age)), label(id))
END GPL.


* Chart Builder. Boxplot age and died

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Survived Age MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Survived=col(source(s), name("Survived"), unit.category())
  DATA: Age=col(source(s), name("Age"))
  DATA: id=col(source(s), name("$CASENUM"), unit.category())
  GUIDE: axis(dim(1), label("Survived"))
  GUIDE: axis(dim(2), label("Age"))
  GUIDE: text.title(label("Simple Boxplot of Age by Survived"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: schema(position(bin.quantile.letter(Survived*Age)), label(id))
END GPL.



*creating dummy for class

SPSSINC CREATE DUMMIES VARIABLE=Pclass 
ROOTNAME1=Class_dum 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

***TRYING OUT SOME LOGISTIC REGRESSEION***

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Age SibSp Parch Class_dum_2 Class_dum_3 
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Age SibSp Parch Class_dum_2 Class_dum_3 female 
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).


*recoding SibSp 


RECODE SibSp (0=0) (1=1) (2 thru 8=2) INTO sibsp_cat.
EXECUTE.


*recoding parch

RECODE Parch (0=0) (1=1) (2=2) (3 thru 6=3) INTO parch_cat.
EXECUTE.

*creating dummy variable of SibSp

SPSSINC CREATE DUMMIES VARIABLE=sibsp_cat 
ROOTNAME1=sibsp_dum 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.

*creating dummy variable fo parch

SPSSINC CREATE DUMMIES VARIABLE=parch_cat 
ROOTNAME1=parch_dum 
/OPTIONS ORDER=A USEVALUELABELS=YES USEML=YES OMITFIRST=NO.



*logistic regression

LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER Age female parch_dum_1 parch_dum_2 parch_dum_3 sibsp_dum_1 sibsp_dum_2 Class_dum_2 
    Class_dum_3 
  /CONTRAST (Sex)=Indicator
  /CRITERIA=PIN(.05) POUT(.10) ITERATE(20) CUT(.5).


*multinomial binary regression

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Age female parch_dum_1 parch_dum_2 parch_dum_3 
    sibsp_dum_1 sibsp_dum_2 Class_dum_2 Class_dum_3
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001) 
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=PARAMETER SUMMARY LRT CPS STEP MFI IC.


