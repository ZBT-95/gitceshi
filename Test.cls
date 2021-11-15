Class JHIPLIB.SOAP.BO.Test Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SOAP.OutboundAdapter";

Property Adapter As EnsLib.SOAP.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method Send(pRequest As EnsLib.EDI.XML.Document, Output pResponse As Ens.StringResponse) As %Status
{
	;进行测试
	; 再次进行测试
	; 再次测试
<<<<<<< HEAD
=======
	; 第4次测试
>>>>>>> b5d7f06 (第4次修改测试类)
	Quit $$$ERROR($$$NotImplemented)
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="EnsLib.EDI.XML.Document"> 
		<Method>Send</Method>
	</MapItem>
</MapItems>
}

}
