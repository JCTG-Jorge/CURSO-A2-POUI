
BLOCK-LEVEL ON ERROR UNDO, THROW.


USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.
USING com.totvs.framework.api.*.

{include/i-prgvrs.i apipoPedido 12.01.2301 } /*** "010002" ***/
{include/i-license-manager.i apipoPedido MCD}


{method/dbotterr.i}  

{cdp/utils.i}

  DEF TEMP-TABLE ttbPedido LIKE tbPedido
  FIELD nome LIKE emitente.nome-emit.


 FUNCTION fn-has-row-errors RETURNS LOGICAL ():

    FOR EACH RowErrors 
        WHERE UPPER(RowErrors.ErrorType) = 'INTERNAL':U:
        DELETE RowErrors. 
    END.

    RETURN CAN-FIND(FIRST RowErrors 
        WHERE UPPER(RowErrors.ErrorSubType) = 'ERROR':U).
    
END FUNCTION.

       
PROCEDURE pi-get-v1:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR RowErrors.
    
    DEFINE VARIABLE oRequest AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE cExcept  AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE tableKey AS character      NO-UNDO.

    ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).
    
   
    ASSIGN cExcept = JsonAPIUtils:getTableExceptFieldsBySerializedFields(
        TEMP-TABLE ttbPedido:HANDLE, oRequest:getFields()
    ).
      
    
     ASSIGN tableKey = STRING(oRequest:getPathParams():GetCharacter(1)).       
     
        
       FOR FIRST tbPedido WHERE tbPedido.nrPedido = INT(tableKey) NO-LOCK :
       
       
           CREATE ttbPedido.
             TEMP-TABLE ttbPedido:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
              BUFFER tbPedido:HANDLE, cExcept).  
              
              FIND emitente WHERE emitente.cod-emitente = tbPedido.codFornecedor NO-LOCK NO-ERROR.
              IF AVAIL emitente THEN
              DO:
                    ttbPedido.nome = emitente.nome-emit. 
              END.
              

           
           ASSIGN oOutput = JsonAPIUtils:convertTempTableFirstItemToJsonObject(
                TEMP-TABLE ttbPedido:HANDLE, (LENGTH(TRIM(cExcept)) > 0)
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

PROCEDURE pi-lastPedido:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM oOutput AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR RowErrors.
    
    DEFINE VARIABLE oRequest AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE cExcept  AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE tableKey AS character      NO-UNDO.

    DEFINE VARIABLE pNumPed AS INTEGER     NO-UNDO.
    
    ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).
    
   
    ASSIGN cExcept = JsonAPIUtils:getTableExceptFieldsBySerializedFields(
        TEMP-TABLE ttbPedido:HANDLE, oRequest:getFields()
    ).
      
    
     ASSIGN tableKey = STRING(oRequest:getPathParams():GetCharacter(1)).       
     
        
       FOR LAST tbPedido NO-LOCK :       
       
           ASSIGN pNumPed = tbPedido.nrPedido.    
       
       END. 
    
    oOutput = NEW  JsonObject().
    oOutput:ADD('lastPedido', pNumPed).
       
   
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
    
     DEFINE VARIABLE oRequest   AS JsonAPIRequestParser  NO-UNDO.
     
      DEFINE VARIABLE iCount     AS INTEGER INITIAL 0     NO-UNDO.
     
     DEFINE VARIABLE quickSearch AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE cExcept    AS CHARACTER             NO-UNDO.
     DEFINE VARIABLE cQuery     AS CHARACTER             NO-UNDO.    
     DEFINE VARIABLE cBy        AS CHARACTER             NO-UNDO.
	
   
     
    EMPTY TEMP-TABLE RowErrors.
    EMPTY TEMP-TABLE ttbPedido.
    
     ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).
     
     ASSIGN cExcept = JsonAPIUtils:getTableExceptFieldsBySerializedFields(
        TEMP-TABLE ttbPedido:HANDLE, oRequest:getFields()
    ).
    
    ASSIGN cQuery = 'FOR EACH tbPedido  NO-LOCK':U.
                                                     
    
    IF oRequest:getQueryParams():has("search") THEN DO:
        ASSIGN quickSearch = STRING(oRequest:getQueryParams():GetJsonArray("search"):GetCharacter(1)).
         ASSIGN cQuery = cQuery + " WHERE tbPedido.codFornecedor   = " + quickSearch . 
                                                                                               
    END.      
    ELSE
    DO:
        
         ASSIGN
         cQuery = buildWhere(TEMP-TABLE ttbPedido:HANDLE, oRequest:getQueryParams(), "", cQuery) // FUNCTION buildWhere NA INCLUDE CDP/UTILS.I
         cBy    = buildBy(TEMP-TABLE ttbPedido:HANDLE, oRequest:getOrder())                      // FUNCTION buildBy    NA INCLUDE CDP/UTILS.I
         cQuery = cQuery + cBy.   
         
         
       

    END.
          
          
    
    
    
    
    DEFINE QUERY findQuery FOR tbPedido  SCROLLING.

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
        
        CREATE ttbPedido.          
        TEMP-TABLE ttbPedido:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
            BUFFER tbPedido:HANDLE, cExcept
        ).
        
        
         FIND emitente WHERE emitente.cod-emitente = tbPedido.codFornecedor NO-LOCK NO-ERROR.
         IF AVAIL emitente THEN             
                ttbPedido.nome = emitente.nome-emit. 
       
              
              
        ASSIGN iCount = iCount + 1.          
        
    
    END.
   
    
    ASSIGN aOutput = JsonAPIUtils:convertTempTableToJsonArray(
        TEMP-TABLE ttbPedido:HANDLE, (LENGTH(TRIM(cExcept)) > 0) ).  
        
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

PROCEDURE pi-create-v1:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM aOutput     AS JsonArray  NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR RowErrors.
    
    
    RUN piAcao IN THIS-PROCEDURE (INPUT 'create',
                                  INPUT oInput,
                                  OUTPUT aOutput).
                                  
   CATCH eSysError AS PROGRESS.Lang.SysError:
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17006
               RowErrors.ErrorDescription = eSysError:getMessage(1)
               RowErrors.ErrorSubType = "ERROR".
    END.
    FINALLY:
        IF fn-has-row-errors() THEN DO:
            UNDO, RETURN 'NOK'.
        END.
    END FINALLY. 
                  
END PROCEDURE.


PROCEDURE pi-update-v1:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM aOutput     AS JsonArray  NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR RowErrors.
    
    
    RUN piAcao IN THIS-PROCEDURE (INPUT 'update',
                                  INPUT oInput,
                                  OUTPUT aOutput).
                                  
   CATCH eSysError AS PROGRESS.Lang.SysError:
        CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17006
               RowErrors.ErrorDescription = eSysError:getMessage(1)
               RowErrors.ErrorSubType = "ERROR".
    END.
    FINALLY:
        IF fn-has-row-errors() THEN DO:
            UNDO, RETURN 'NOK'.
        END.
    END FINALLY. 
                  


END PROCEDURE.

PROCEDURE piAcao:
    DEFINE INPUT  PARAM cAction   AS CHAR NO-UNDO.
    DEFINE INPUT  PARAM oInput    AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM aOutput   AS JsonArray  NO-UNDO.
    DEF BUFFER btbPedido FOR tbPedido.
   
    EMPTY TEMP-TABLE RowErrors.
    
    DEFINE VARIABLE oRequest  AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE oPayload  AS JsonObject           NO-UNDO.
    DEFINE VARIABLE oOutput   AS JsonObject           NO-UNDO.
    
    ASSIGN oRequest = NEW JsonAPIRequestParser(oInput)
           oPayload = oRequest:getPayload().
    
    createBlock:
    DO TRANS ON ERROR UNDO, LEAVE
             ON STOP  UNDO, LEAVE
             ON QUIT  UNDO, LEAVE:
             
             
             //tbPedido.nrPedido tbPedido.codFornecedor tbPedido.dataPedido tbPedido.statusPedido tbPedido.narrativa
             
             
            
           CREATE ttbPedido.
           ASSIGN ttbPedido.nrPedido        =  oPayload:getInteger("nrPedido")  WHEN  oPayload:has("nrPedido")
                  ttbPedido.codFornecedor   =  oPayload:getInteger("codFornecedor")  WHEN  oPayload:has("codFornecedor")                  
                  ttbPedido.dataPedido      =  oPayload:getDate("dataPedido")  WHEN  oPayload:has("dataPedido")
                  ttbPedido.narrativa       =  oPayload:getCharacter("narrativa")  WHEN  oPayload:has("narrativa")             
                  ttbPedido.statusPedido    =  oPayload:getInteger("statusPedido")  WHEN  oPayload:has("statusPedido") .
                  
         
          
          FIND  tbPedido WHERE tbPedido.nrPedido  = ttbPedido.nrPedido EXCLUSIVE-LOCK NO-ERROR.
          
          
          IF  cAction = 'create' THEN
          DO:
               IF AVAIL tbPedido THEN
               DO:
                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17006
                           RowErrors.ErrorDescription = "Registro j ÿ existe com id informado!"
                           RowErrors.ErrorSubType = "ERROR".
                   
               END.
               ELSE
               DO:
                   CREATE tbPedido.
                   ASSIGN tbPedido.nrPedido          = ttbPedido.nrPedido 
                          tbPedido.codFornecedor     = ttbPedido.codFornecedor
                          tbPedido.narrativa         = ttbPedido.narrativa  
                          tbPedido.dataPedido        = ttbPedido.dataPedido                           
                          tbPedido.statusPedido      = ttbPedido.statusPedido  .     
               
               END.
                  
               
          END.
          ELSE
          DO:
              IF NOT AVAIL tbPedido THEN
               DO:
                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17006
                           RowErrors.ErrorDescription = "Registro n’o encontrado para Nr Pedido informado!"
                           RowErrors.ErrorSubType = "ERROR".
                   
               END.
               ELSE
               DO:              
               
                   ASSIGN tbPedido.codFornecedor     = ttbPedido.codFornecedor
                          tbPedido.narrativa         = ttbPedido.narrativa  
                          tbPedido.dataPedido        = ttbPedido.dataPedido                           
                          tbPedido.statusPedido      = ttbPedido.statusPedido  .
              END.          
            
          END.  
          
          
          
        IF fn-has-row-errors() THEN DO:
            UNDO, RETURN 'NOK':U.
        END.
        
        CATCH eSysError AS PROGRESS.Lang.SysError:
            CREATE RowErrors.
            ASSIGN RowErrors.ErrorNumber = 17006
                   RowErrors.ErrorDescription = eSysError:getMessage(1)
                   RowErrors.ErrorSubType = "ERROR".
        END.
             
             
    END.
    
    
    oOutput = NEW JsonObject().
    ASSIGN oOutput = JsonAPIUtils:convertTempTableFirstItemToJsonObject(
           TEMP-TABLE ttbPedido:HANDLE ).

    aOutput = NEW JsonArray().
    aOutput:ADD(oOutput).
    
    
    
    CATCH eSysError AS PROGRESS.Lang.SysError:
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

PROCEDURE pi-delete-v1:
    DEFINE INPUT  PARAM oInput  AS JsonObject NO-UNDO.
    DEFINE OUTPUT PARAM TABLE FOR RowErrors.

    DEFINE VARIABLE oRequest AS JsonAPIRequestParser NO-UNDO.
    DEFINE VARIABLE cExcept  AS CHARACTER            NO-UNDO.
    DEFINE VARIABLE vId      AS INTEGER            NO-UNDO.

    ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).

    ASSIGN vId = INT(oRequest:getPathParams():GetCharacter(1)).
            
    
    
    FIND tbPedido WHERE tbPedido.nrPedido =  vId EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL tbPedido THEN
    DO:
        DELETE tbPedido.        
    END.
    ELSE
    DO:
         CREATE RowErrors.
        ASSIGN RowErrors.ErrorNumber = 17021
               RowErrors.ErrorDescription = "Registro n’o encontrado!"
               RowErrors.ErrorSubType = "ERROR".
    
    
    END.         
    
    
    
     CATCH eSysError AS PROGRESS.Lang.SysError:
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

































