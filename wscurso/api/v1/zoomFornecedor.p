
USING Progress.Lang.Error.
USING com.totvs.framework.api.JsonApiResponseBuilder.

{utp/ut-api.i}
{utp/ut-api-utils.i}

{include/i-prgvrs.i zoomFornecedor 2.00.00.001 } /*** "010001" ***/
{utp/ut-api-action.i pi-get    GET /~*/}
{utp/ut-api-action.i pi-query  GET /~*}
{utp/ut-api-notfound.i}


DEFINE VARIABLE apiHandler AS HANDLE NO-UNDO.

/*:T--- PROCEDURES V1 ---*/
PROCEDURE pi-get:
    
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.
    
    IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN wscurso/apiZoomFornecedor.p  PERSISTENT SET apiHandler.
    END.

    RUN pi-get-v1 IN apiHandler (
        INPUT oInput,
        OUTPUT oOutput,
        OUTPUT TABLE RowErrors
    ).

    IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE DO:
        IF oOutput EQ ? THEN DO:
            ASSIGN oOutput = JsonApiResponseBuilder:empty(404).
        END.
        ELSE DO:
            ASSIGN oOutput = JsonApiResponseBuilder:ok(oOutput).
        END.
    END.

    
    CATCH oE AS Error:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).
    END CATCH.

    FINALLY: DELETE PROCEDURE apiHandler NO-ERROR. END FINALLY.

END PROCEDURE.


PROCEDURE pi-query:
    
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE lHasNext AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE aResult  AS JsonArray NO-UNDO.

     
    

    IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN  wscurso/apiZoomFornecedor.p  PERSISTENT SET apiHandler.
    END.

        RUN pi-query-v1 IN apiHandler  (
        INPUT oInput,
        OUTPUT aResult,
        OUTPUT lHasNext,
        OUTPUT TABLE RowErrors
    ).

    IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(TEMP-TABLE RowErrors:HANDLE).
    END.

    ELSE DO:
        ASSIGN oOutput = JsonApiResponseBuilder:ok(aResult, lHasNext).
    END.

  
    CATCH oE AS ERROR:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).
    END CATCH.
    

    FINALLY: DELETE PROCEDURE apiHandler NO-ERROR. END FINALLY.

END PROCEDURE.
