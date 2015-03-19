#Include Once "../util/util.bas"
#Include Once "clientUDT.bas"
#Include Once "networkMSG.bas"
#Include Once "networkData.bas"
#include once "TSNE_V3.bi"
'##############################################################################################################
Dim Shared G_Server     as UInteger                 'Eine Variable f�r den Server-Handel erstellen

'##############################################################################################################
'   Deklarationen f�r die Empf�nger Sub Routinen erstellen
Declare Sub TSNE_Client_Disconnected           (ByVal V_TSNEID as UInteger)
Declare Sub TSNE_Client_Connected              (ByVal V_TSNEID as UInteger)
Declare Sub TSNE_NewData                (ByVal V_TSNEID as UInteger, ByRef V_Data as String)
Declare Sub TSNE_NewConnection          (ByVal V_TSNEID as UInteger, ByVal V_RequestID as Socket, ByVal V_IPA as String)
Declare Sub TSNE_NewConnectionCanceled  (ByVal V_TSNEID as UInteger, ByVal V_IPA as String)


Type networkUDT
	as Long RV 
	As UInteger G_Client
	as Integer BV 
	As UByte IsServerBool
	
	As list_type log
	As staticstackUDT Input = 1000
	As clientUDT Ptr serverCLIENT 
	As Any Ptr networkMutex
	'Declare Constructor
	'Declare Destructor
	
	Declare Function CreateServer(port As UShort,max_connection As UShort) As Byte 
	Declare Function CloseServerConnection As Byte 
	
	Declare Function CreateClient(adresse As String,port As UShort) As Byte 
	Declare Function CloseClientConnection As Byte 

	
	Declare Function Send(item As networkData Ptr,is2delete As Byte=0) As UByte 
	
	
	Declare Function isServer As UByte
	
	'Client
	As lockUDT clientTable = 10	
	Declare Sub storeClient(key As UInteger,DataPTR As clientUDT Ptr)
	Declare Function lockClient(key As UInteger) As clientUDT ptr
	Declare Sub unlockClient(key As UInteger,DataPTR As clientUDT Ptr)
	Declare Sub freeClient(key As UInteger,itemDelete As UByte=0) 
End Type


Dim Shared As networkUDT network

'Constructor networkUDT
'	'networkMutex = mutexcreate
'End Constructor
'
'Destructor networkUDT
'	'MutexDestroy networkMutex
'End Destructor


Function networkUDT.Send(item As networkData Ptr,is2delete As Byte=0) As UByte
	Dim As String tmp=item->toString 
	RV=TSNE_Data_Send(item->V_TSNEID,chr(Len(Str(Len(tmp))))+Str(Len(tmp))+tmp)
	If RV <> TSNE_Const_NoError Then                  
	    log.add(new networkMSG(TSNE_GetGURUCode(RV),0),1)        
	    If is2delete=1 Then Delete item                    
	    Return 0                                         
	End If
	If is2delete=1 Then Delete item	
	Return 1
End Function

Function networkUDT.CreateServer(port As UShort,max_connection As UShort) As Byte 
	IsServerBool=1                                                      
	Log.add(new networkMSG("[SERVER] Init...",1),1)                         
	RV = TSNE_Create_Server(G_Server,port, max_connection, @TSNE_NewConnection, @TSNE_NewConnectionCanceled)
	
	If RV <> TSNE_Const_NoError Then                  
	    log.add(new networkMSG(TSNE_GetGURUCode(RV),0),1)  
                  
	    log.add(new networkMSG( "[END]",1),1)                                
	    Return 0                                         
	End If
	
	log.add(new networkMSG( "[OK]",1 ),1)                            
	
	RV = TSNE_BW_SetEnable(G_Server, TSNE_BW_Mode_Black)   
	If RV <> TSNE_Const_NoError Then                 
	    log.add(new networkMSG(TSNE_GetGURUCode(RV),0),1)  
                
	    log.add(new networkMSG( "[END]",1),1)                              
	    Return 0                                           
	End If	

	Return 1
End function

Function networkUDT.CloseServerConnection As Byte
	log.add(new networkMSG( "Disconnecting...",1),1)                
	RV = TSNE_Disconnect(G_Server)                     
	
	If RV <> TSNE_Const_NoError Then log.add(new networkMSG(TSNE_GetGURUCode(RV),0),1)   
	log.add(new networkMSG( "Wait disconnected...",1 ),1)            

	TSNE_WaitClose(G_Server)   
	                      
	log.add(new networkMSG( "Disconnected!",1),1)                     
   log.add(new networkMSG( "[END]",1),1)                                 
	Return 1   
End Function

Function networkUDT.CreateClient(adresse As String,port As UShort) As Byte 
	IsServerBool=0
	log.add(new networkMSG(  "[INIT] Client...",1),1)                       'Programm beginnen
  
	
	log.add(new networkMSG(  "[Connecting]",1),1)
	BV = TSNE_Create_Client(G_Client,adresse, port, @TSNE_Client_Disconnected, @TSNE_Client_Connected, @TSNE_NewData, 60)

	If BV <> TSNE_Const_NoError Then
	    log.add(new networkMSG(TSNE_GetGURUCode(BV),0),1)
	    Return 0
	End If
	
	log.add(new networkMSG(  "[OK]",1  ),1)
	Return 1
End Function

Function networkUDT.CloseClientConnection As Byte
	log.add(new networkMSG( "[WAIT] ...",1),1)
	TSNE_Disconnect(G_Client)
	TSNE_WaitClose(G_Client)
	log.add(new networkMSG( "[WAIT] OK",1),1)
	log.add(new networkMSG( "[END]",1),1)
	
	Return 1 
End Function

Sub networkUDT.storeClient(key As UInteger,DataPTR As clientUDT Ptr)
	clientTable.store(key,DataPTR)
End Sub

Function networkUDT.lockClient(key As UInteger) As clientUDT Ptr
	Return Cast(clientUDT Ptr,clientTable.lock(key))
End Function

Sub networkUDT.unlockClient(key As UInteger,DataPTR As clientUDT Ptr)
	clientTable.unlock(key,DataPTR)
End Sub

Sub networkUDT.freeClient(key As UInteger,itemDelete As UByte=0) 
	clientTable.free(key,itemDelete)
End Sub

Function networkUDT.isServer As UByte
	Dim As UByte tmp = 0
	'MutexLock networkMutex
		tmp = this.isServerBool
	'MutexUnLock networkMutex
	Return tmp
End Function
