Class JHIPV5.ESB.BO.SerConManage.JHIP.ServiceAddressBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第一个/// Summary:	获取HIV下的BP路径
/// TODO:		通过服务查询数据库中服务所对应BP路径并返回
/// Parameters:		参数1：id 服务id
/// 				参数2: name 服务名称
/// Response:	json对象：{"Data":""}; 
/// 				Data:BP路径，为空则返回"null"
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set Name=pRequest.StringValue
		Set jsonObject = ##class(%DynamicObject).%New()
			set tStatment = ##class(%SQL.Statement).%New()
	#;		//查询BP路径，若无则返回null
	#;		Set sqlAddress = "SELECT BPAdress FROM HII_ALL_DB.BpServiceDB WHERE SName = '"_Name_"'"
	#;		;Set tSC = tStatment.%Prepare(sqlAddress)
	#;		;Set tResultAddress = tStatment.%Execute()
	#;		Set tSC=..Adapter.ExecuteQuery(.tResultAddress,sqlAddress)
	#;		Set jsonObject.Data = "null"
	#;		While tResultAddress.Next(){
	#;			Set jsonObject.Data = tResultAddress.%Get("BPAdress")
	#;		}
	        Set ip=^Ens.LookupTable("IpTable","JHIPip")
			Set jsonObject.Data = "http://"_ip_":57772/csp/healthshare/jhipv3/EnsPortal.BPLEditor.zen?BP="_Name_".bpl"
			Set jsonString = jsonObject.%ToJSON()
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=$zcvt(jsonString,"O","UTF8")
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
