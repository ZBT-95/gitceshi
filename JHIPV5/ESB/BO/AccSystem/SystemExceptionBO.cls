Class JHIPV5.ESB.BO.AccSystem.SystemExceptionBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第四个系统异常
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		;Set time = $zdt($H,3)
		;Set day = $zd($HOROLOG,3)_" 00:00:00"
		Set day ="2019-07-25 17:26:04.500"
		Set time ="2029-07-25 17:26:04.500"
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		//系统数
		Set sql="select distinct Publish FROM HIPPSer_MSG.MtTable"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
				Set NewFiled = ##class(%DynamicObject).%New()
		    	Set Publish = tResult.Get("Publish")
		    	Set sql2="SELECT count(ID) as num FROM Ens_Util.Log where Type='2' and TimeLogged>='"_day_"' and TimeLogged<='"_time_"' and ConfigName in(select distinct ServiceName FROM HIPPSer_MSG.MtTable where Publish='"_Publish_"')"
		   		Set tSC2=..Adapter.ExecuteQuery(.tResult2,sql2)
		   		$$$LOGINFO("sql2="_sql2)
		   		$$$LOGINFO("tResult2="_tResult2)
		   		$$$LOGINFO("tSC2="_tSC2)
		   		Set value=0
		   		if tResult2.Next(){
			   			$$$LOGINFO("num="_tResult2.Get("num"))
			   			Set value=tResult2.Get("num")
			   		}
			   	Do NewFiled.%Set("name",Publish)
			   	Do NewFiled.%Set("value",value)
			   	Do NewFiled.%Set("size",100)
			   	if value'=0{
					   	Do dataArr.%Push(NewFiled)
				   	}
		    }
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
