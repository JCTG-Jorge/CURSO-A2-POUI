
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.
USING com.totvs.framework.api.*.

{include/i-prgvrs.i apiEsce0500 2.00.00.002 } /*** "010002" ***/
{include/i-license-manager.i apiEsce0500 MCD}

{method/dbotterr.i}
{cie/esUtils.i}
{utp/ut-glob.i}
   
 
 DEF VAR hApi AS HANDLE NO-UNDO.      
 DEF VAR cFile AS CHAR .
 
 DEFINE TEMP-TABLE ttMovimento 
    FIELD cod-estabel LIKE movto-estoq.cod-estabel
    FIELD tipoTrans  AS CHAR LABEL 'Tipo Trans'
    FIELD dt-trans LIKE movto-estoq.dt-trans
    FIELD it-codigo LIKE movto-estoq.it-codigo
    FIELD descricao LIKE ITEM.desc-item
    FIELD especie   AS CHAR   LABEL 'Especie'
    FIELD quantidade LIKE movto-estoq.quantidade.
    

/*:T--- FUNCTIONS ---*/



FUNCTION fn-get-id-from-path RETURNS CHARACTER (
    INPUT oRequest AS JsonAPIRequestParser
):

    RETURN STRING(oRequest:getPathParams():GetCharacter(1)).
    
END FUNCTION.  

FUNCTION fn-has-row-errors RETURNS LOGICAL ():

    FOR EACH RowErrors 
        WHERE UPPER(RowErrors.ErrorType) = 'INTERNAL':U:
        DELETE RowErrors. 
    END.

    RETURN CAN-FIND(FIRST RowErrors 
        WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U).
    
END FUNCTION.



PROCEDURE piCriaRelatorio:

    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR RowErrors.

    DEFINE VARIABLE oRequest AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE cExcept  AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE oPayload  AS JsonObject           NO-UNDO.
    
  
    DEFINE VARIABLE iCont AS INTEGER     NO-UNDO.
    DEFINE VARIABLE lReport AS LOGICAL     NO-UNDO.
    DEF VAR pRelatorio AS LONGCHAR NO-UNDO.
   
    
    DEFINE VARIABLE vCodEstabelIni AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vCodEstabelFim AS CHARACTER   NO-UNDO.   
    DEFINE VARIABLE vDataIni AS DATE   NO-UNDO.
    DEFINE VARIABLE vDataFim AS DATE   NO-UNDO.
     DEFINE VARIABLE vItCodigoIni AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE vItCodigoFim AS CHARACTER   NO-UNDO.
    
    DEFINE VARIABLE mStorage AS MEMPTR.
   
    
    ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).
    ASSIGN oPayload = oRequest:getPayload().
       
    ASSIGN vCodEstabelIni         = oPayload:getCharacter("codEstabel")   WHEN oPayload:has("codEstabel")   
           vCodEstabelFim         = oPayload:getCharacter("codEstabel")   WHEN oPayload:has("codEstabel")   
           vDataIni               = oPayload:getDate("dataIni")     WHEN oPayload:has("dataIni")     
           vDataFim               = oPayload:getDate("dataFim")     WHEN oPayload:has("dataFim")     
           vItCodigoIni           = oPayload:getCharacter("itCodigoIni")     WHEN oPayload:has("itCodigoIni")  
           vItCodigoFim           = oPayload:getCharacter("itCodigoFim")     WHEN oPayload:has("itCodigoFim")  . 
               
   
   FOR EACH movto-estoq  USE-INDEX data-item
       WHERE movto-estoq.dt-trans >= vDataIni
       AND   movto-estoq.dt-trans <= vDataFim
       AND   movto-estoq.it-codigo >= vItCodigoIni
       AND   movto-estoq.it-codigo <= vItCodigoFim           
       NO-LOCK,
       FIRST ITEM WHERE ITEM.it-codigo = movto-estoq.it-codigo NO-LOCK :
       
       CREATE ttMovimento.
       ASSIGN ttMovimento.cod-estabel = movto-estoq.cod-estabel
              ttMovimento.dt-trans    = movto-estoq.dt-trans
              ttMovimento.it-codigo   = movto-estoq.it-codigo
              ttMovimento.descricao   = ITEM.desc-item
              ttMovimento.especie     = {ininc/i03in218.i 4 movto-estoq.esp-docto} 
              ttMovimento.tipoTrans   =  {ininc/i01in218.i  4 movto-estoq.tipo-trans}
              ttMovimento.quantidade  = movto-estoq.quantidade.
       
          lReport = YES.
       
       
    END. 
    
     ASSIGN cFile = SESSION:TEMP-DIRECTORY + "esce0500_" + replace(STRING(TODAY,"99/99/99"),"/","") + '.xml'.   
    
    
    RUN utp/utapi033.p PERSISTENT SET hApi.  

    RUN piNewWorksheetbyTT IN hApi (
        INPUT "esce0500", INPUT "Listagem do Movimento de Estoque",
        INPUT BUFFER ttMovimento:HANDLE, 
        ?, 
        ?). 

    RUN ConvertToXls IN hApi (YES).
    RUN show IN hApi (NO).

    RUN piProcessa IN hApi (
        INPUT-OUTPUT cFile, 
        INPUT "", 
        INPUT "").
        
     IF RETURN-VALUE <> "OK" THEN 
     DO:
      CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17006
               RowErrors.ErrorDescription = RETURN-VALUE
               RowErrors.ErrorSubType = "ERROR".
     
     END.
   
           
       
    COPY-LOB FROM FILE cFile  TO mStorage NO-ERROR.
    pRelatorio = BASE64-ENCODE(mStorage) NO-ERROR.                     

                              


   oOutput = NEW JsonObject().

   oOutput:ADD('lReport', lReport).
   oOutput:ADD('pRelatorio', pRelatorio).
   oOutput:ADD('pNomeArquivo', 'esce0500.xml').
    
    CATCH eSysError AS Progress.Lang.SysError:
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17006
               RowErrors.ErrorDescription = eSysError:getMessage(1)
               RowErrors.ErrorSubType = "ERROR".
    END.
    FINALLY: 
         DELETE PROCEDURE hApi NO-ERROR. 
         
        IF fn-has-row-errors() THEN DO:
            UNDO, RETURN 'NOK':U.
        END.
    END FINALLY.

END PROCEDURE.








