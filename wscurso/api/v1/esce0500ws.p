
USING Progress.Lang.Error.
USING com.totvs.framework.api.JsonApiResponseBuilder.

{utp/ut-api.i}
{utp/ut-api-utils.i}

{include/i-prgvrs.i esce0500ws 2.00.00.001 } /*** "010001" ***/


{utp/ut-api-action.i pi-get    GET /~*/}
{utp/ut-api-action.i pi-query  GET /~*}
{utp/ut-api-action.i piExecutar  POST /~*}
{utp/ut-api-notfound.i}


DEFINE VARIABLE apiHandler AS HANDLE NO-UNDO.

/*:T--- PROCEDURES V1 ---*/
PROCEDURE pi-get:
    
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.

 
    IF NOT VALID-HANDLE(apiHandler) THEN DO:
       RUN wscurso/apiEsce0500.p PERSISTENT SET apiHandler.
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

 OUTPUT CLOSE.

    CATCH oE AS Error:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).
    END CATCH.

    FINALLY: DELETE PROCEDURE apiHandler NO-ERROR. END FINALLY.

END PROCEDURE.


PROCEDURE pi-query:
    
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE lHasNext AS LOGICAL   NO-UNDO.
    DEFINE VARIABLE aOutput     AS JsonArray  NO-UNDO.
   
    IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN wscurso/apiEsce0500.p PERSISTENT SET apiHandler.
    END.

        RUN pi-query-v1 IN apiHandler  (
        INPUT oInput,
        OUTPUT aOutput,
        OUTPUT lHasNext,
        OUTPUT TABLE RowErrors
    ).

    IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE DO:
        ASSIGN oOutput = JsonApiResponseBuilder:ok(aOutput, lHasNext).
    END.

   OUTPUT CLOSE.
    
    CATCH oE AS ERROR:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).
    END CATCH.
    

    FINALLY: DELETE PROCEDURE apiHandler NO-ERROR. END FINALLY.

END PROCEDURE.

PROCEDURE piExecutar:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.

    DEFINE VARIABLE lHasNext    AS LOGICAL   INITIAL FALSE  NO-UNDO.
    DEFINE VARIABLE aOutput     AS JsonArray  NO-UNDO.

 // OUTPUT TO  "/totvs12pgs/ERP/spool/jorge/piExecutar.txt".
   
  //PUT STRING(oInput:GetJsonText()) FORMAT "x(2000)" SKIP. 

    RUN  wscurso/apiEsce0500.p PERSISTENT SET apiHandler. 

    oOutput = NEW JsonObject().

    IF VALID-HANDLE(apiHandler) THEN
        RUN  piCriaRelatorio IN apiHandler (INPUT oInput,
                                          OUTPUT oOutput,
                                          OUTPUT TABLE RowErrors ).

    
    IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'WARNING':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asWarning(aOutput, lHasNext, TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE DO:
        ASSIGN oOutput = JsonApiResponseBuilder:ok(oOutput).
    END.

  // OUTPUT CLOSE.

    CATCH oE AS Error:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).
    END CATCH.
    
    FINALLY: DELETE PROCEDURE apiHandler NO-ERROR. END FINALLY.


   
  

END PROCEDURE.


