
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.
USING com.totvs.framework.api.*.

{include/i-prgvrs.i apiMotivoRefugo 2.00.00.002 } /*** "010002" ***/
{include/i-license-manager.i apiBuscaItem MCD}

{method/dbotterr.i}
{cie/esUtils.i}

DEF TEMP-TABLE wsItem
    FIELD  it-codigo                    like ITEM.it-codigo            serialize-name "itCodigo"
    FIELD  desc-item                    LIKE ITEM.desc-item              serialize-name "descricao"
    FIELD  ge-codigo                    LIKE ITEM.ge-codigo               serialize-name "GE" .
        
        
   

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

    EMPTY TEMP-TABLE wsItem.


    ASSIGN cExcept = JsonAPIUtils:getTableExceptFieldsBySerializedFields(
        TEMP-TABLE wsItem:HANDLE, oRequest:getFields()
    ).


    FOR FIRST ITEM
        NO-LOCK WHERE ITEM.it-codigo  EQ tableKey:
        
       CREATE wsItem.
        TEMP-TABLE wsItem:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
            BUFFER ITEM:HANDLE, cExcept
        ).
         
              

    

        
        ASSIGN oOutput = JsonAPIUtils:convertTempTableFirstItemToJsonObject(
            TEMP-TABLE wsItem:HANDLE, (LENGTH(TRIM(cExcept)) > 0)
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
    EMPTY TEMP-TABLE wsItem.

    DEFINE VARIABLE oRequest   AS JsonAPIRequestParser  NO-UNDO.
    DEFINE VARIABLE iCount     AS INTEGER INITIAL 0     NO-UNDO.

    DEFINE VARIABLE quickSearch AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cExcept    AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE cQuery     AS CHARACTER             NO-UNDO.
    DEFINE VARIABLE cQueryName AS CHARACTER             NO-UNDO.
	DEFINE VARIABLE cBy        AS CHARACTER             NO-UNDO.

     DEFINE VARIABLE cIdEstacao        AS CHARACTER             NO-UNDO.

    ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).

    ASSIGN cExcept = JsonAPIUtils:getTableExceptFieldsBySerializedFields(
        TEMP-TABLE wsItem:HANDLE, oRequest:getFields()
    ).

   //OUTPUT TO  "/totvs12pgs/ERP/spool/jorge/item.txt".

   // PUT STRING(oInput:GetJsonText()) FORMAT "x(2000)" SKIP. 
    
    ASSIGN cQuery = 'FOR EACH item  NO-LOCK '.

   
    IF oRequest:getQueryParams():has("search") THEN DO:
        ASSIGN quickSearch = STRING(oRequest:getQueryParams():GetJsonArray("search"):GetCharacter(1)).
         ASSIGN cQuery = cQuery + " where  item.desc-item  MATCHES '*" + quickSearch + "*'". 
                                                                                               
    END.
    ELSE
    DO:
         IF oRequest:getQueryParams():has("filter") AND STRING(oRequest:getQueryParams():GetJsonArray("filter"):GetCharacter(1)) NE '' THEN DO:
             ASSIGN quickSearch = STRING(oRequest:getQueryParams():GetJsonArray("filter"):GetCharacter(1)).
             ASSIGN cQuery = cQuery + " WHERE  item.desc-item  MATCHES '*" + quickSearch + "*'".             
            
         
         END.
         ELSE
         DO:
                 
             ASSIGN
             cQuery = buildWhere(TEMP-TABLE wsItem:HANDLE, oRequest:getQueryParams(), "", cQuery) // FUNCTION buildWhere NA INCLUDE CDP/UTILS.I
             cBy    = buildBy(TEMP-TABLE wsItem:HANDLE, oRequest:getOrder())                      // FUNCTION buildBy    NA INCLUDE CDP/UTILS.I
             cQuery = cQuery + cBy.        
         END.
     END.

    
    
    DEFINE QUERY findQuery FOR ITEM  SCROLLING.

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
         
        
        CREATE wsItem.
        TEMP-TABLE wsItem:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
            BUFFER ITEM:HANDLE, cExcept
        ).          
        
        ASSIGN iCount = iCount + 1.
    END.
    
    

    ASSIGN aOutput = JsonAPIUtils:convertTempTableToJsonArray(
        TEMP-TABLE wsItem:HANDLE, (LENGTH(TRIM(cExcept)) > 0) ).

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




