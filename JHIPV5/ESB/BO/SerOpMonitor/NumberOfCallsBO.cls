Class JHIPV5.ESB.BO.SerOpMonitor.NumberOfCallsBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 调用次数top5 的服务
Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	Set pResponse=##class(Ens.StringResponse).%New()
	set jsonObject = ##class(%DynamicObject).%New()
	set dataArr=##class(%DynamicArray).%New()
	try{
    	Set day = $zd($HOROLOG,3)_" 00:00:00",time = $zdt($H,3) 
	    Set sql="SELECT Top 5 HostName,sum(TotalCount) as num FROM Ens_Activity_Data.Seconds where HostType = '1' and TimeSlot>'"_day_"' and TimeSlot<'"_time_"' group by HostName order by num desc"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
			Set NewFiled = ##class(%DynamicObject).%New()
		    Set SourceConfigName = tResult.Get("HostName")
		    Set num = tResult.Get("num")
		    Do NewFiled.%Set("name",SourceConfigName)
		    Do NewFiled.%Set("value",num)
		    Do dataArr.%Push(NewFiled)
		}
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
		<Method>QueryData</Method>
	</MapItem>
</MapItems>
}

}
