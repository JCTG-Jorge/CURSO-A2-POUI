USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.

DEFINE VARIABLE iCont AS INT      NO-UNDO.
DEF VAR mayJson AS JsonObject NO-UNDO.
DEFINE VARIABLE jArr AS JsonArray.

DEF TEMP-TABLE ttDados 
     FIELD itCodigo LIKE ITEM.it-codigo
     FIELD descItem LIKE ITEM.desc-item 
     FIELD geCodigo LIKE ITEM.ge-codigo 
     FIELD dataImplant LIKE ITEM.data-implant
     FIELD codObSoleto LIKE ITEM.cod-obsoleto.
     
           
     
  RUN piPopulaObjeto(OUTPUT jArr).
  
   ASSIGN iCont = 0.  
   

  DO iCont = 1 TO jArr:LENGTH:
  
        mayJson  = NEW JsonObject().
        mayJson  = jArr:getJsonObject(iCont).
        
      
      CREATE ttDados.
      ASSIGN ttDados.itCodigo = mayJson:GetCharacter('itCodigo')
             ttDados.descItem  = mayJson:GetCharacter('descItem') 
             ttDados.geCodigo  =  mayJson:GetInteger('geCodigo') 
             ttDados.dataImplant =  mayJson:GetDate('dataImplant')
             ttDados.codObSoleto =  mayJson:GetInteger('codObSoleto') .
  
  
  END.
   
                                          
  
FOR EACH ttDados:

  DISP ttDados.
END.
     
                 
     
 
PROCEDURE piPopulaObjeto:
   DEF OUTPUT PARAMETER oJsonArray AS JsonArray NO-UNDO.
   DEFINE VARIABLE jObj AS JsonObject.
     ASSIGN iCont = 0.  
   
        oJsonArray = NEW  JsonArray().
   
   FOR EACH ITEM NO-LOCK:
   
   IF icont > 50 THEN LEAVE.
   
   jObj = NEW JsonObject().
   
   jObj:ADD('itCodigo', ITEM.it-codigo ) .
   jObj:ADD('descItem', ITEM.desc-item ) .
   jObj:ADD('geCodigo', ITEM.ge-codigo ) .
   jObj:ADD('dataImplant', ITEM.data-implant ) .
   jObj:ADD('codObSoleto', ITEM.cod-obsoleto ) .
   
    oJsonArray:ADD(jObj).  
   
    icont = icont + 1.
    
   END.    
END PROCEDURE.
