Class JHIPV5.ESB.BO.MesStatis.IDBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 获取错误详情BO

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set jsonObject = ##class(%DynamicObject).%New()
	set returnArr=##class(%DynamicArray).%New()
	set tStatement = ##class(%SQL.Statement).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	Set countoto=0
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set startTime = json.%Get("startTime")
		Set endTime = json.%Get("endTime")
		Set ID = $ZCVT(json.%Get("ID"),"O","UTF8")
		Set choseTime = json.%Get("choseTime")
		IF choseTime = "当日"{
			Set time = $zdt($H,3)        
			Set day = $zd($HOROLOG,3)_" 00:00:00"
		}ElseIF choseTime="近七天"{
			Set time = $zdt($H,3)        
			Set day =$system.SQL.DATEADD("dd",-7,time)
		}Else{
			Set day = startTime
		   	Set time = endTime       
		}
		Set sqlName="SELECT SessionId,Status,TimeCreated FROM Ens.MessageHeader where Status = '8' and SourceConfigName ='"_ID_"' and TimeCreated >='"_day_"' and TimeCreated <='"_time_"'"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlName)
	 	//遍历结果集并将分页查询显示SQL获取到的数据放至json
	 	WHILE tResult.Next(){
		 	Set countoto=countoto+1
		    Set NewFiled = ##class(%DynamicObject).%New()
		    Do NewFiled.%Set("lb",tResult.Get("SessionId"))
			Do NewFiled.%Set("xq","错误")
		    Do NewFiled.%Set("sj",tResult.Get("TimeCreated"))
		    Do returnArr.%Push(NewFiled)
		}
		Set jsonObject.rows=returnArr
		Set jsonObject.total=countoto
		Set pResponse.StringValue=$zcvt(jsonObject.%ToJSON(),"O","UTF8")
		Do jsonObject.%Remove("rows")
		Do jsonObject.%Remove("total")
	}Catch(e){
		$$$LOGERROR(e.DisplayString())	
	  Set tSC=e.AsStatus()
   }
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>QueryData</Method>
	</MapItem>
</MapItems>
}

}
