
DEFINE VARIABLE cSourceType AS CHARACTER NO-UNDO.
DEFINE VARIABLE cReadMode   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cFile       AS CHARACTER NO-UNDO.
DEFINE VARIABLE lRetOK      AS LOGICAL   NO-UNDO.

DEF TEMP-TABLE dados 
FIELD id AS INTEGER
FIELD nome AS CHAR
FIELD telefone AS CHAR.



ASSIGN  cSourceType = 'file'
        cFile =  'D:\Jornada-PO-UI\agenda.json'  
        cReadMode = 'empty' .
        
        
 lRetOK = TEMP-TABLE dados:READ-JSON(cSourceType, cFile, cReadMode ).
 
 
 FOR EACH dados:
 
  DISP dados.
 END.
        
        
