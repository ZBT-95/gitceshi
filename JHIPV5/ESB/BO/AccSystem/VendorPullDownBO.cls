Class JHIPV5.ESB.BO.AccSystem.VendorPullDownBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第六个，所有厂商下拉
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		;Set time = $zdt($H,3)
		;Set day =$system.SQL.DATEADD("dd",-7,time) 
		Set day ="2019-07-25 17:26:04.500"
		Set time ="2021-07-25 17:26:04.500"
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		//系统数
		Set sql="SELECT distinct substring(Description,1,charindex(':',Description)-1) as ClassName FROM Ens_Config.BusinessPartner"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
		    	Set ClassName = tResult.Get("ClassName")
		    	Set NewFiled = ##class(%DynamicObject).%New()
				Do NewFiled.%Set("name",ClassName)
				Do NewFiled.%Set("value",ClassName)
				Do dataArr.%Push(NewFiled)
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
