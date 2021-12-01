Class JHIPV5.ESB.BO.MesRretr.JHIP.XmlBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SOAP.OutboundAdapter";

Property Adapter As EnsLib.SOAP.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 获取详情XML的BO

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	Set pResponse=##class(Ens.StringResponse).%New()
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set SessionID= json.%Get("SessionID")
		Set spaceType= json.%Get("spaceType")
		Set ..Adapter.WebServiceURL=$S(1=spaceType:"http://192.168.100.69:57772/soap/JHIPLIB.SOAP.BS.Service.cls?cfgitem=JH1601获取消息正文",2=spaceType:"http://192.168.100.61:57772/soap/JHIPLIB.SOAP.BS.Service.cls?cfgitem=JH1601获取消息正文")
		Set ..Adapter.WebServiceClientClass=$S(1=spaceType:"JHIPV5.ESB.WSDL.ServiceSoap",2=spaceType:"JHIPV5.ESB.WSDL.ServiceSoap2")
		Set tSC=..Adapter.InvokeMethod("Send",.pOUT,SessionID)
		Set pResponse.StringValue=pOUT
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
