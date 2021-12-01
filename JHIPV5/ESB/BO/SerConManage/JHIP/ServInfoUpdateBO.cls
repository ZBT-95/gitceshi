Class JHIPV5.ESB.BO.SerConManage.JHIP.ServInfoUpdateBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SOAP.OutboundAdapter";

Property Adapter As EnsLib.SOAP.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set upDateInfo=pRequest.StringValue
		s tSC=..Adapter.InvokeMethod("ServInfoUpdate",.pOUT,upDateInfo)
		$$$LOGINFO("pOUT="_pOUT)
		Set pResponse=##class(Ens.StringResponse).%New()
		if pOUT=1{
			Set pResponse.StringValue={"code":"200","Text":"操作成功！"}
			}
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
