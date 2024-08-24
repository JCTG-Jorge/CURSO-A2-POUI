
BLOCK-LEVEL ON ERROR UNDO, THROW.


USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.
USING com.totvs.framework.api.*.

{include/i-prgvrs.i apiAgenda 12.01.2301 } /*** "010002" ***/
{include/i-license-manager.i apiAgenda MCD}


{method/dbotterr.i}  

{cdp/utils.i}

  DEF TEMP-TABLE ttagenda LIKE agenda.


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
        TEMP-TABLE ttAgenda:HANDLE, oRequest:getFields()
    ).
      
    
     ASSIGN tableKey = STRING(oRequest:getPathParams():GetCharacter(1)).       
     
        
       FOR FIRST agenda WHERE agenda.id = INT(tableKey) NO-LOCK :
       
       
           CREATE ttAgenda.
             TEMP-TABLE ttagenda:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
              BUFFER agenda:HANDLE, cExcept).   
           
           ASSIGN oOutput = JsonAPIUtils:convertTempTableFirstItemToJsonObject(
                TEMP-TABLE ttAgenda:HANDLE, (LENGTH(TRIM(cExcept)) > 0)
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
	
     
    EMPTY TEMP-TABLE RowErrors.
    EMPTY TEMP-TABLE ttAgenda.
    
     ASSIGN oRequest = NEW JsonAPIRequestParser(oInput).
     
     ASSIGN cExcept = JsonAPIUtils:getTableExceptFieldsBySerializedFields(
        TEMP-TABLE ttAgenda:HANDLE, oRequest:getFields()
    ).
    
    ASSIGN cQuery = 'FOR EACH agenda  NO-LOCK':U.
                                                     
    
    IF oRequest:getQueryParams():has("search") THEN DO:
        ASSIGN quickSearch = STRING(oRequest:getQueryParams():GetJsonArray("search"):GetCharacter(1)).
         ASSIGN cQuery = cQuery + " WHERE agenda.nome   MATCHES '*" + quickSearch + "*'". 
                                                                                               
    END.      
    ELSE
    DO:
        
         ASSIGN
         cQuery = buildWhere(TEMP-TABLE ttAgenda:HANDLE, oRequest:getQueryParams(), "", cQuery) // FUNCTION buildWhere NA INCLUDE CDP/UTILS.I
         cBy    = buildBy(TEMP-TABLE ttAgenda:HANDLE, oRequest:getOrder())                      // FUNCTION buildBy    NA INCLUDE CDP/UTILS.I
         cQuery = cQuery + cBy.        

    END.
          
          
    
    
    
    
    DEFINE QUERY findQuery FOR agenda  SCROLLING.

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
        
        CREATE ttAgenda.          
        TEMP-TABLE ttAgenda:HANDLE:DEFAULT-BUFFER-HANDLE:BUFFER-COPY(
            BUFFER agenda:HANDLE, cExcept
        ).
        
        ASSIGN iCount = iCount + 1.          
        
    
    END.
   
    
    ASSIGN aOutput = JsonAPIUtils:convertTempTableToJsonArray(
        TEMP-TABLE ttAgenda:HANDLE, (LENGTH(TRIM(cExcept)) > 0) ).  
        
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
    DEF BUFFER bagenda FOR agenda.
   
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
             
           
           CREATE ttagenda.
           ASSIGN ttagenda.id          =  oPayload:getInteger("id")  WHEN  oPayload:has("id")
                  ttagenda.nome        =  oPayload:getCharacter("nome")  WHEN  oPayload:has("nome")
                  ttagenda.telefone    =  oPayload:getCharacter("telefone")  WHEN  oPayload:has("telefone")
                  ttagenda.dtCriacao   =  oPayload:getDate("dtCriacao")  WHEN  oPayload:has("dtCriacao")
                  ttagenda.ativo       =  oPayload:getLogical("ativo")  WHEN  oPayload:has("ativo")             
                  ttagenda.situacao    =  oPayload:getInteger("situacao")  WHEN  oPayload:has("situacao") .
                  
         
          
          FIND  agenda WHERE agenda.id  = ttagenda.id EXCLUSIVE-LOCK NO-ERROR.
          
          
          IF  cAction = 'create' THEN
          DO:
               IF AVAIL agenda THEN
               DO:
                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17006
                           RowErrors.ErrorDescription = "Registro j ÿ existe com id informado!"
                           RowErrors.ErrorSubType = "ERROR".
                   
               END.
               ELSE
               DO:
                   CREATE agenda.
                   ASSIGN agenda.id          = ttagenda.id    
                          agenda.nome        = ttagenda.nome      
                          agenda.telefone    = ttagenda.telefone  
                          agenda.dtCriacao   = ttagenda.dtCriacao
                          agenda.ativo       = ttagenda.ativo     
                          agenda.situacao    =  ttagenda.situacao  .     
               
               END.
                  
               
          END.
          ELSE
          DO:
              IF NOT AVAIL agenda THEN
               DO:
                    CREATE RowErrors.
                    ASSIGN RowErrors.ErrorNumber = 17006
                           RowErrors.ErrorDescription = "Registro n’o encontrado para id informado!"
                           RowErrors.ErrorSubType = "ERROR".
                   
               END.
               ELSE
               DO:              
               
                   ASSIGN agenda.nome        = ttagenda.nome      
                          agenda.telefone    = ttagenda.telefone  
                          agenda.dtCriacao   = ttagenda.dtCriacao 
                          agenda.ativo       = ttagenda.ativo    
                          agenda.situacao    = ttagenda.situacao .
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
           TEMP-TABLE ttagenda:HANDLE ).

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
            
    
    
    FIND agenda WHERE agenda.id =  vId EXCLUSIVE-LOCK NO-ERROR.
    IF AVAIL agenda THEN
    DO:
        DELETE agenda.        
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

































