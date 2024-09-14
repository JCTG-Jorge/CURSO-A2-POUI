
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.
USING com.totvs.framework.api.*.

{include/i-prgvrs.i apiZoomFornecedor 2.00.00.002 } /*** "010002" ***/
{include/i-license-manager.i apiZoomFornecedor MCD}

{method/dbotterr.i}
{esp/esUtils.i}

DEF TEMP-TABLE ttEmitente
  FIELD cod-emitente              LIKE  emitente.cod-emitente       SERIALIZE-NAME 'codEmitente'
  FIELD nome-emit                LIKE  emitente.nome-emit      SERIALIZE-NAME 'nome'
  FIELD cgc                      LIKE emitente.cgc
  .


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

/*:T--- QUERY PROCEDURES V1 ---*/

PROCEDURE pi-get-v1:

    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR RowErrors.

    DEFINE VARIABLE oRequest AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE cExcept  AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE tableKey AS character      NO-UNDO.

    ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).

    ASSIGN tableKey = fn-get-id-from-path(oRequest).

    //PUT 'tableKey ' tableKey FORMAT "x(30)" SKIP.

    EMPTY TEMP-TABLE ttEmitente.


    ASSIGN cExcept = JsonAPIUtils:getTableExceptFieldsBySerializedFields(
        TEMP-TABLE ttEmitente:HANDLE, oRequest:getFields()
    ).


    FOR FIRST emitente
        NO-LOCK WHERE emitente.cod-emitente  EQ int(tableKey)
        AND emitente.identific > 1:
        
       CREATE ttEmitente.
        TEMP-TABLE ttEmitente:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
            BUFFER emitente:HANDLE, cExcept
        ).               

        
        ASSIGN oOutput = JsonAPIUtils:convertTempTableFirstItemToJsonObject(
            TEMP-TABLE ttEmitente:HANDLE, (LENGTH(TRIM(cExcept)) > 0)
        ).
    END.
    
    CATCH eSysError AS Progress.Lang.SysError:
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17006
               RowErrors.ErrorDescription = eSysError:getMessage(1)
               RowErrors.ErrorSubType = "ERROR".
    END.
    FINALLY: 
        IF fn-has-row-errors() THEN DO:
            UNDO, RETURN 'NOK':U.
        END.
    END FINALLY.

END PROCEDURE.

PROCEDURE pi-query-v1:
    
    DEFINE INPUT  PARAM oInput   AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM aOutput  AS JsonArray  NO-UNDO.
    DEFINE OUTPUT PARAM lHasNext AS LOGICAL    NO-UNDO INITIAL FALSE.
    DEFINE OUTPUT PARAM TABLE FOR RowErrors.

    EMPTY TEMP-TABLE RowErrors.
    EMPTY TEMP-TABLE ttEmitente.

    DEFINE VARIABLE oRequest   AS JsonAPIRequestParser  NO-UNDO.
    DEFINE VARIABLE iCount     AS INTEGER INITIAL 0     NO-UNDO.

    DEFINE VARIABLE quickSearch AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cExcept    AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE cQuery     AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE cQueryName AS CHARACTER             NO-UNDO.
	DEFINE VARIABLE cBy        AS CHARACTER             NO-UNDO.
     DEFINE VARIABLE cod AS INT   NO-UNDO.
     DEFINE VARIABLE nome AS CHARACTER   NO-UNDO.
     
    ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).

    ASSIGN cExcept = JsonAPIUtils:getTableExceptFieldsBySerializedFields(
        TEMP-TABLE ttEmitente:HANDLE, oRequest:getFields()
    ).
    
        
    
    ASSIGN cQuery = 'FOR EACH emitente  NO-LOCK  where emitente.identific > 1 '.

   
    IF oRequest:getQueryParams():has("search") THEN DO:
        ASSIGN quickSearch = STRING(oRequest:getQueryParams():GetJsonArray("search"):GetCharacter(1)).
         ASSIGN cQuery = cQuery + " and  emitente.nome-emit  MATCHES '*" + quickSearch + "*'". 
                                                                                               
    END.
    ELSE
    DO:
         IF oRequest:getQueryParams():has("filter") THEN DO:
             ASSIGN quickSearch = STRING(oRequest:getQueryParams():GetJsonArray("filter"):GetCharacter(1)).
             ASSIGN cQuery = cQuery + " and  emitente.nome-emit  MATCHES '*" + quickSearch + "*'". 
         
         END.
         ELSE
         DO:
                 
             ASSIGN
             cQuery = buildWhere(TEMP-TABLE ttEmitente:HANDLE, oRequest:getQueryParams(), "", cQuery) // FUNCTION buildWhere NA INCLUDE CDP/UTILS.I
             cBy    = buildBy(TEMP-TABLE ttEmitente:HANDLE, oRequest:getOrder())                      // FUNCTION buildBy    NA INCLUDE CDP/UTILS.I
             cQuery = cQuery + cBy.        
         END.
     END.

    
    DEFINE QUERY findQuery FOR emitente  SCROLLING.

    QUERY findQuery:QUERY-PREPARE(cQuery).
    QUERY findQuery:QUERY-OPEN().
    QUERY findQuery:REPOSITION-TO-ROW(oRequest:getStartRow()).

    REPEAT:

        GET NEXT findQuery.
        IF QUERY findQuery:QUERY-OFF-END THEN LEAVE.

         IF oRequest:getPageSize() EQ iCount THEN DO:
             ASSIGN lHasNext = TRUE.
             LEAVE.
         END.
         
        
        CREATE ttEmitente.
        TEMP-TABLE ttEmitente:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
            BUFFER emitente:HANDLE, cExcept
        ).          
        
        ASSIGN iCount = iCount + 1.
    END.

    ASSIGN aOutput = JsonAPIUtils:convertTempTableToJsonArray(
        TEMP-TABLE ttEmitente:HANDLE, (LENGTH(TRIM(cExcept)) > 0) ).

    CATCH eSysError AS Progress.Lang.SysError:
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17006
               RowErrors.ErrorDescription = eSysError:getMessage(1)
               RowErrors.ErrorSubType = "ERROR".
    END.
    FINALLY: 
        IF fn-has-row-errors() THEN DO:
            UNDO, RETURN 'NOK':U.
        END.
    END FINALLY.


END PROCEDURE.




