Class JHIPV5.ESB.BO.SerConManage.JHIP.ServBUpdateBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第九个接口Summary:	表格内容开关按钮
/// TODO:		通过页面显示的每条服务的开关按钮，对数据库中对应服务的启用状态和日志开启状态进行更新
/// Parameters:		参数1：id 将要更新的服务id
/// 				参数2: type 选择将要更新的两个开关按钮中的某个
/// 				参数3: enabled 选择是否启用服务
/// 				参数4: logTraceEvents 选择是否开启日志
/// Response:	json对象：{"code":"","Text":""}; 
/// 				code:更新状态，成功为200，失败为100; Text:更新描述
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set MyString=pRequest.StringValue
		Set pResponse=##class(Ens.StringResponse).%New()
		Set type= $PIECE(MyString,"@",1)
		Set enabled1= $PIECE(MyString,"@",2)
		Set logTraceEvents1= $PIECE(MyString,"@",3)
		Set id= $PIECE(MyString,"@",4)
		IF type = 1{
				Set enabled=enabled1
			}ELSE{
				Set logTraceEvents=logTraceEvents1
			}
		set tStatement = ##class(%SQL.Statement).%New()
			
			//更新前检查状态
			Set sqlCheck0 = "SELECT ID, Enabled, LogTraceEvents FROM Ens_Config.Item WHERE ID = '"_id_"'"
	   		;set tSC = tStatement.%Prepare(sqlCheck0)
	   		;set tResult = tStatement.%Execute()
	   		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlCheck0)
	   		WHILE tResult.Next(){
		   		Set resEnabled0 = tResult.%Get("Enabled")
	   			Set resLogTraceEvents0 = tResult.%Get("LogTraceEvents")
		   	}
			
			//更新SQL
			Set sqlUpdate = "UPDATE Ens_Config.Item Set "
			IF type = 1{
				Set sqlUpdate = sqlUpdate_"Enabled = '"_enabled_"' "	
			}
			IF type '= 1{
				Set sqlUpdate = sqlUpdate_"LogTraceEvents = '"_logTraceEvents_"' "	
			}
			
			Set sqlUpdate = sqlUpdate_"WHERE ID='"_id_"'"
			;set tSC = tStatement.%Prepare(sqlUpdate)
	   		;set tResult = tStatement.%Execute()
	   		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlUpdate)
	   		
	   		//检查更新结果SQL
	   		Set sqlCheck = "SELECT ID, Enabled, LogTraceEvents FROM Ens_Config.Item WHERE ID = '"_id_"'"
	   		;set tSC = tStatement.%Prepare(sqlCheck)
	   		;set tResult = tStatement.%Execute()
	   		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlCheck)
	   		WHILE tResult.Next(){
		   		Set resEnabled = tResult.%Get("Enabled")
	   			Set resLogTraceEvents = tResult.%Get("LogTraceEvents")
		   	}
		   	
		   	//更新结果检查
		   	IF type =1{
		   		//启用服务选项检查
			   	IF resEnabled = enabled &&resEnabled0 '= enabled{
				   	Set pResponse.StringValue={"code":"200","Text":"操作成功"}
				   	Set pResponse.StringValue."enabled" = enabled
				   	Set pResponse.StringValue."resEnabled0" = resEnabled0
				   	Set pResponse.StringValue."resEnabled" = resEnabled
				}ELSEIF resEnabled '= enabled || resEnabled0 = enabled {
					Set pResponse={"code":"100","Text":"操作失败"}
					Set pResponse.StringValue."enabled" = enabled
					Set pResponse.StringValue."resEnabled0" = resEnabled0
				   	Set pResponse.StringValue."resEnabled" = resEnabled
				}
			}ELSE{
				//启用日志选项检查
				IF resLogTraceEvents = logTraceEvents && resLogTraceEvents0 '= logTraceEvents{
					Set pResponse.StringValue={"code":"200","Text":"操作成功"}
					Set pResponse.StringValue."logTraceEvents" = logTraceEvents
					Set pResponse.StringValue."resLogTraceEvents0" = resLogTraceEvents0
				   	Set pResponse.StringValue."resLogTraceEvents" = resLogTraceEvents
				}ELSEIF resLogTraceEvents '= logTraceEvents || resLogTraceEvents0 = logTraceEvents {
					Set pResponse.StringValue={"code":"100","Text":"操作失败"}
					Set pResponse.StringValue."logTraceEvents" = logTraceEvents
					Set pResponse.StringValue."resLogTraceEvents0" = resLogTraceEvents0
				   	Set pResponse.StringValue."resLogTraceEvents" = resLogTraceEvents
				}
			}
		   	//结果json序列化并发送
		Set pResponse.StringValue=$zcvt(pResponse.StringValue.%ToJSON(),"O","UTF8")
	}Catch(e){	
	  Set tSC=e.AsStatus()
   }
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>InvokeHDR</Method>
	</MapItem>
</MapItems>
}

}
