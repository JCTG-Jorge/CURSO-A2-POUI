
BLOCK-LEVEL ON ERROR UNDO, THROW.


USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.
USING com.totvs.framework.api.*.

{include/i-prgvrs.i apipoPedido 12.01.2301 } /*** "010002" ***/
{include/i-license-manager.i apipoPedido MCD}


{method/dbotterr.i}  

{cdp/utils.i}

  DEF TEMP-TABLE ttTbItemPedido LIKE tbItemPedido
  FIELD descricao LIKE ITEM.desc-item
  FIELD id AS CHARACTER .


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
        TEMP-TABLE ttTbItemPedido:HANDLE, oRequest:getFields()
    ).
      
    
     ASSIGN tableKey = STRING(oRequest:getPathParams():GetCharacter(1)).       
     
        
       FOR FIRST tbItemPedido WHERE ROWID(tbItemPedido) = TO-ROWID(tableKey) NO-LOCK :
       
       
       
           CREATE ttTbItemPedido.
             TEMP-TABLE ttTbItemPedido:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
              BUFFER tbItemPedido:HANDLE, cExcept).   
            
            FIND ITEM WHERE ITEM.it-codigo = tbItemPedido.produto NO-LOCK NO-ERROR.
           ASSIGN ttTbItemPedido.id  =  string(ROWID(tbItemPedido))
           ttTbItemPedido.descricao = ITEM.desc-item  .
           
           ASSIGN oOutput = JsonAPIUtils:convertTempTableFirstItemToJsonObject(
                TEMP-TABLE ttTbItemPedido:HANDLE, (LENGTH(TRIM(cExcept)) > 0)
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
    
     DEFINE VARIABLE oRequest   AS JsonAPIRequestParser  NO-UNDO.
     
      DEFINE VARIABLE iCount     AS INTEGER INITIAL 0     NO-UNDO.
     
     DEFINE VARIABLE quickSearch AS CHARACTER   NO-UNDO.
     DEFINE VARIABLE cExcept    AS CHARACTER             NO-UNDO.
     DEFINE VARIABLE cQuery     AS CHARACTER             NO-UNDO.    
     DEFINE VARIABLE cBy        AS CHARACTER             NO-UNDO.
     DEFINE VARIABLE pPedido AS INT   NO-UNDO.
     
    EMPTY TEMP-TABLE RowErrors.
    EMPTY TEMP-TABLE ttTbItemPedido.
    
     ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).
     
          
     ASSIGN cExcept = JsonAPIUtils:getTableExceptFieldsBySerializedFields(
        TEMP-TABLE ttTbItemPedido:HANDLE, oRequest:getFields()
    ).
    
     IF oRequest:getQueryParams():has("nrPedido") THEN 
        ASSIGN pPedido = INT(oRequest:getQueryParams():GetJsonArray("nrPedido"):GetCharacter(1)).
        
               
    ASSIGN cQuery = 'FOR EACH tbItemPedido  NO-LOCK  where tbItemPedido.nrPedido = ' + STRING(pPedido).
                                                     
    
    IF oRequest:getQueryParams():has("search") THEN DO:
        ASSIGN quickSearch = STRING(oRequest:getQueryParams():GetJsonArray("search"):GetCharacter(1)).
         ASSIGN cQuery = cQuery + " and tbItemPedido.nome   MATCHES '*" + quickSearch + "*'". 
                                                                                               
    END.      
    ELSE
    DO:
        
         ASSIGN
         cQuery = buildWhere(TEMP-TABLE ttTbItemPedido:HANDLE, oRequest:getQueryParams(), "", cQuery) // FUNCTION buildWhere NA INCLUDE CDP/UTILS.I
         cBy    = buildBy(TEMP-TABLE ttTbItemPedido:HANDLE, oRequest:getOrder())                      // FUNCTION buildBy    NA INCLUDE CDP/UTILS.I
         cQuery = cQuery + cBy.        

    END.
          
          
    
    
    
    
    DEFINE QUERY findQuery FOR tbItemPedido  SCROLLING.

    QUERY findQuery:QUERY-PREPARE(cQuery).
    QUERY findQuery:QUERY-OPEN().
    QUERY findQuery:REPOSITION-TO-ROW(oRequest:getStartRow()).
    
    REPEAT:
        GET NEXT findQuery.
        IF QUERY findQuery:QUERY-OFF-END THEN LEAVE.
    
      /*  
        IF oRequest:getPageSize() EQ iCount THEN DO:
                ASSIGN lHasNext = TRUE.
                LEAVE.
        END.    
                  */
        CREATE ttTbItemPedido.          
        TEMP-TABLE ttTbItemPedido:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
            BUFFER tbItemPedido:HANDLE, cExcept
        ).
        
         
            FIND ITEM WHERE ITEM.it-codigo = tbItemPedido.produto NO-LOCK NO-ERROR.
           ASSIGN ttTbItemPedido.id  =  string(ROWID(tbItemPedido))
           ttTbItemPedido.descricao = ITEM.desc-item  .
        
        ASSIGN iCount = iCount + 1.          
        
    
    END.
   
    
    ASSIGN aOutput = JsonAPIUtils:convertTempTableToJsonArray(
        TEMP-TABLE ttTbItemPedido:HANDLE, (LENGTH(TRIM(cExcept)) > 0) ).  
        
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
    DEF BUFFER btbItemPedido FOR tbItemPedido.
   
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
             
             
             // tbItemPedido.nrPedido tbItemPedido.produto tbItemPedido.quantidade tbItemPedido.preco tbItemPedido.vlrTotal
             
             
            
           CREATE ttTbItemPedido.
           ASSIGN ttTbItemPedido.nrPedido    =  oPayload:getInteger("nrPedido")  WHEN  oPayload:has("nrPedido")
                  ttTbItemPedido.produto     =  oPayload:getCharacter("produto")  WHEN  oPayload:has("produto")                  
                  ttTbItemPedido.quantidade  =  oPayload:getDecimal("quantidade")  WHEN  oPayload:has("quantidade")
                  ttTbItemPedido.preco       =  oPayload:getDecimal("preco")  WHEN  oPayload:has("preco")             
                  ttTbItemPedido.vlrTotal    =  oPayload:getDecimal("vlrTotal")  WHEN  oPayload:has("vlrTotal") .
                  
         
          
          FIND  tbItemPedido WHERE tbItemPedido.nrPedido  = ttTbItemPedido.nrPedido
                              AND  tbItemPedido.produto   = ttTbItemPedido.produto EXCLUSIVE-LOCK NO-ERROR.
          
          
          IF  cAction = 'create' THEN
          DO:
               IF AVAIL tbItemPedido THEN
               DO:
                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17006
                           RowErrors.ErrorDescription = "Registro j ÿ existe com id informado!"
                           RowErrors.ErrorSubType = "ERROR".
                   
               END. 
               ELSE
               DO:
                   CREATE tbItemPedido.
                   ASSIGN tbItemPedido.nrPedido    = ttTbItemPedido.nrPedido 
                          tbItemPedido.produto     = ttTbItemPedido.produto
                          tbItemPedido.quantidade  = ttTbItemPedido.quantidade  
                          tbItemPedido.preco       = ttTbItemPedido.preco                           
                          tbItemPedido.vlrTotal    = ttTbItemPedido.vlrTotal  .     
               
               END.
                  
               
          END.
          ELSE
          DO:
              IF NOT AVAIL tbItemPedido THEN
               DO:
                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17006
                           RowErrors.ErrorDescription = "Registro n’o encontrado para Nr Pedido informado!"
                           RowErrors.ErrorSubType = "ERROR".
                   
               END.
               ELSE
               DO:              
               
                   ASSIGN tbItemPedido.quantidade  = ttTbItemPedido.quantidade  
                          tbItemPedido.preco       = ttTbItemPedido.preco                           
                          tbItemPedido.vlrTotal    = ttTbItemPedido.vlrTotal  . 
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
           TEMP-TABLE ttTbItemPedido:HANDLE ).

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
    DEFINE VARIABLE vId      AS CHARACTER            NO-UNDO.

    ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).

    ASSIGN vId = oRequest:getPathParams():GetCharacter(1).
            
    
    
    FIND tbItemPedido WHERE ROWID(tbItemPedido) =  TO-ROWID(vId) EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL tbItemPedido THEN
    DO:
        DELETE tbItemPedido.        
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

































