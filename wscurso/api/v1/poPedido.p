BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.Error.
USING com.totvs.framework.api.JsonApiResponseBuilder.

{utp/ut-api.i}
{utp/ut-api-utils.i}

{include/i-prgvrs.i poPedido 12.01.2301 } /*** "010001" ***/


{utp/ut-api-action.i piGet      GET /~*/}
{utp/ut-api-action.i piQuery    GET /~*}
{utp/ut-api-action.i piCreate    POST /~*}
{utp/ut-api-action.i piUpdate    PUT /~*}
{utp/ut-api-action.i piDelete    DELETE /~*}


                                    

{utp/ut-api-notfound.i}


DEFINE VARIABLE apiHandler AS HANDLE      NO-UNDO.

PROCEDURE piGet:
 DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
 DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.
 

 
    IF NOT VALID-HANDLE(apiHandler) THEN
    DO:
       RUN wscurso/apipoPedido.p PERSISTENT SET apiHandler . 
    END.
    
   
    RUN pi-get-v1 IN apiHandler (
        INPUT oInput,
        OUTPUT oOutput,
        OUTPUT TABLE RowErrors
    ).
          
    IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE
    DO:
         IF oOutput EQ ? THEN DO:
            ASSIGN oOutput = JsonApiResponseBuilder:empty(404).
         END.
         ELSE DO:
              ASSIGN oOutput = JsonApiResponseBuilder:ok(oOutput).
         END.
    
    END.
         
    
     //===Tratativa de erros progress
   CATCH oE AS ERROR:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).   
   END CATCH.
    
   FINALLY:          
        DELETE PROCEDURE apiHandler NO-ERROR.          
   END FINALLY.       


END PROCEDURE.


PROCEDURE piQuery:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE aOutput     AS JsonArray  NO-UNDO.
    DEFINE VARIABLE lHasNext    AS LOGICAL    NO-UNDO.
    
    IF NOT VALID-HANDLE(apiHandler) THEN
    DO:
       RUN wscurso/apipoPedido.p PERSISTENT SET apiHandler. 
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
                     
    
    //===Tratativa de erros progress
   CATCH oE AS ERROR:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).   
   END CATCH.    
   FINALLY:          
        DELETE PROCEDURE apiHandler NO-ERROR.          
   END FINALLY.
    
    
    
END PROCEDURE.


PROCEDURE piCreate:
     DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
     DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.

     DEFINE VARIABLE lHasNext    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE aOutput     AS JsonArray  NO-UNDO.
    
     IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN wscurso/apipoPedido.p PERSISTENT SET apiHandler.
     END.
     
       RUN pi-create-v1 IN apiHandler (
                        INPUT oInput,
                        OUTPUT aOutput,
                        OUTPUT TABLE RowErrors).
     
     
    IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'WARNING':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asWarning(aOutput, lHasNext, TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE DO:
        ASSIGN oOutput = JsonApiResponseBuilder:ok(aOutput, lHasNext).
    END.      
     
     
     
    CATCH oE AS Error:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).
    END CATCH.
    
    FINALLY: DELETE PROCEDURE apiHandler NO-ERROR. END FINALLY.

END PROCEDURE.

PROCEDURE piUpdate:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.
    
    DEFINE VARIABLE lHasNext    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE aOutput     AS JsonArray  NO-UNDO.
     
     IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN wscurso/apipoPedido.p PERSISTENT SET apiHandler.
     END.
     
    RUN pi-update-v1 IN apiHandler (
                    INPUT oInput,
                    OUTPUT aOutput,
                    OUTPUT TABLE RowErrors).                          
                        
      IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'WARNING':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asWarning(aOutput, lHasNext, TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE DO:
        ASSIGN oOutput = JsonApiResponseBuilder:ok(aOutput, lHasNext).
    END.      
                
     
    CATCH oE AS Error:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).
    END CATCH.
    
    FINALLY: DELETE PROCEDURE apiHandler NO-ERROR. END FINALLY.


END PROCEDURE.


PROCEDURE piDelete:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.

    
     IF NOT VALID-HANDLE(apiHandler) THEN DO:
        RUN wscurso/apipoPedido.p PERSISTENT SET apiHandler.
    END.
  
    RUN pi-delete-v1 IN apiHandler (
        INPUT oInput,
        OUTPUT TABLE RowErrors
    ).    
    
    IF CAN-FIND(FIRST RowErrors WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U) THEN DO:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(TEMP-TABLE RowErrors:HANDLE).
    END.
    ELSE DO:
        ASSIGN oOutput = JsonApiResponseBuilder:empty().
    END.

    CATCH oE AS Error:
        ASSIGN oOutput = JsonApiResponseBuilder:asError(oE).
    END CATCH.
    
    FINALLY: DELETE PROCEDURE apiHandler NO-ERROR. END FINALLY.
        
      

END.




