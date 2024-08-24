USING PROGRESS.json.*.
USING PROGRESS.json.ObjectModel.*.


DEFINE VARIABLE cSourceType AS CHARACTER NO-UNDO.
DEFINE VARIABLE cReadMode   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFile       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lRetOK      AS LOGICAL   NO-UNDO.

DEF TEMP-TABLE dados 
FIELD id AS INTEGER
FIELD nome AS CHAR
FIELD telefone AS CHAR.

DEF VAR jArray AS JsonArray NO-UNDO.
DEF VAR jObj   AS JsonObject NO-UNDO.


ASSIGN  cSourceType = 'file'
        cFile =  'D:\Jornada-PO-UI\agenda.json'  
        cReadMode = 'empty' .
        
        
 lRetOK = TEMP-TABLE dados:READ-JSON(cSourceType, cFile, cReadMode ).
 
   /* 
 FOR EACH dados:
 
  DISP dados.
 END.        */
 
  jArray = NEW JsonArray().
  
  jArray:READ(TEMP-TABLE dados:HANDLE). 
  
  MESSAGE  string(jArray:getJsonText())
     VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  
  
  jObj  = NEW JsonObject().
  
 // jObj:READ(TEMP-TABLE dados:HANDLE).
 
 jObj:ADD('dados', jArray ) .
 
 
 
  
  MESSAGE string(jObj:getJsonText())
      VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
  
  
  
  
 
 
        
        
