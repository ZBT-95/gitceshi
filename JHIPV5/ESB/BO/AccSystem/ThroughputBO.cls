Class JHIPV5.ESB.BO.AccSystem.ThroughputBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第六个吞吐量
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set name=pRequest.StringValue
		Set time = $zdt($H,3)
		Set day = $zd($HOROLOG,3)_" 00:00:00" 
		Set day ="2019-07-25 17:26:04.500"
		Set time ="2029-07-25 17:26:04.500"
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		set dataArrB=##class(%DynamicArray).%New()
		set dataArrC=##class(%DynamicArray).%New()
		//吞吐量
		Set sql="SELECT count(ID) as num FROM Ens.MessageHeader where TimeCreated >= '"_day_"' and TimeCreated <= '"_time_"' and SourceConfigName in(select distinct ServiceName FROM HIPPSer_MSG.MtTable where Publish='"_name_"')"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		Set NewFiled = ##class(%DynamicObject).%New()
		Do NewFiled.%Set("name","吞吐量")
		if tResult.Next(){
				Set num = tResult.Get("num")
			   	Do NewFiled.%Set("value",num)
			   	Do NewFiled.%Set("unit","")
			   	Do dataArrB.%Push("25%")
			   	Do dataArrB.%Push("50%")
			   	Do NewFiled.%Set("pos",dataArrB)
		    }
		Set sql="SELECT count(ID) as sumnum FROM Ens.MessageHeader where TimeCreated >= '"_day_"' and TimeCreated <= '"_time_"' and SourceConfigName in(select distinct ServiceName FROM HIPPSer_MSG.MtTable)"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		if tResult.Next(){
				Set sumnum = tResult.Get("sumnum")
				Do dataArrC.%Push(0)
			   	Do dataArrC.%Push(sumnum)
			   	Do NewFiled.%Set("range",dataArrC)
			   	Do NewFiled.%Set("splitNum",10)
		    }
		Do dataArr.%Push(NewFiled)
		//时间
		Set sql="SELECT avg(TotalDuration) as tim FROM Ens_Activity_Data.Days where TimeSlot >= '"_day_"' and TimeSlot <= '"_time_"' and HostName in(select distinct ServiceName FROM HIPPSer_MSG.MtTable where Publish='"_name_"')"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		Set NewFiled = ##class(%DynamicObject).%New()
		set dataArrB=##class(%DynamicArray).%New()
		set dataArrC=##class(%DynamicArray).%New()
		Do NewFiled.%Set("name","耗时")
		if tResult.Next(){
				Set tim = tResult.Get("tim")
			   	Do NewFiled.%Set("value",tim)
			   	Do NewFiled.%Set("unit","")
			   	Do dataArrB.%Push("75%")
			   	Do dataArrB.%Push("50%")
			   	Do NewFiled.%Set("pos",dataArrB)
			   	Do dataArrC.%Push(0)
			   	if tim<1{
			   		Do dataArrC.%Push(1)
				   	}
				if tim>1{
					Do dataArrC.%Push(60)
				   	}
				Do NewFiled.%Set("range",dataArrC)			   	
			   	Do NewFiled.%Set("splitNum",10)
		    }
		Do dataArr.%Push(NewFiled)
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=$zcvt(dataArr.%ToJSON(),"O","UTF8")
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
