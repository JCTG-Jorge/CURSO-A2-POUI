USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.


DEFINE VARIABLE cSourceType AS CHARACTER NO-UNDO.
DEFINE VARIABLE cReadMode   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFile       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lRetOK      AS LOGICAL   NO-UNDO.

DEF TEMP-TABLE ttdados  SERIALIZE-NAME 'dados'
FIELD id AS INTEGER
FIELD nome AS CHAR
FIELD telefone AS CHAR.

DEF VAR jArray AS JsonArray NO-UNDO.
DEF VAR jObj   AS JsonObject NO-UNDO.

DEFINE VARIABLE lJson AS LONGCHAR   NO-UNDO.


ASSIGN  cSourceType = 'file'
        cFile =  'D:\Jornada-PO-UI\agenda.json'  
        cReadMode = 'empty' .
        
        
 lRetOK = TEMP-TABLE ttdados:READ-JSON(cSourceType, cFile, cReadMode ).  
 
  
  jObj  = NEW JsonObject().
  
  jObj:READ(TEMP-TABLE ttdados:HANDLE).
  
  
  EMPTY TEMP-TABLE ttdados.
  
  lJson =  string(jObj:getJsonText()) .
  
  TEMP-TABLE ttdados:READ-JSON('longchar', lJson ) .
  
  
   FOR EACH ttdados:
 
   DISPL  ttdados.
 END.    
 
 
   
 
  
  
  
  
 
 
        
        
