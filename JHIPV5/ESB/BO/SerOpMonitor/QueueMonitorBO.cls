Class JHIPV5.ESB.BO.SerOpMonitor.QueueMonitorBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "dataArr:Basic";

Property dataArr As %Boolean [ InitialExpression = 0 ];

/// 第五个接口队列监控，球
Method QueryDate(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		Set sql="call EnsPortal.Queues_EnumerateQueues()"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		while tResult.Next(){
			Set NewFiled = ##class(%DynamicObject).%New()
			If tResult.Get("Count")'=0{
				Do NewFiled.%Set("name",tResult.Get("Name")_" : "_tResult.Get("Count"))
				//活动
				Do NewFiled.%Set("value",tResult.Get("Active"))
				Do NewFiled.%Set("size",50)
				Do dataArr.%Push(NewFiled)
			}
		}
		Set pResponse=##class(Ens.StringResponse).%New()
		Set:..dataArr dataArr=[]
		;Set pResponse.StringValue=$zcvt(dataArr.%ToJSON(),"O","UTF8")
		Set pResponse.StringValue=dataArr.%ToJSON()
	}Catch(e){	
	  Set tSC=e.AsStatus()
   }
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>QueryDate</Method>
	</MapItem>
</MapItems>
}

}
