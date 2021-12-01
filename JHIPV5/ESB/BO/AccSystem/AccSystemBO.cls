Class JHIPV5.ESB.BO.AccSystem.AccSystemBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第一个获取接入系统
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		//接入系统
		Set sql="SELECT distinct(Publish) as Publish FROM HIPPSer_MSG.MtTable"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		Set countPublish=0
		WHILE tResult.Next(){
			Set countPublish=countPublish+1
		}
		//
		Set NewFiled = ##class(%DynamicObject).%New()
		Do NewFiled.%Set("name","接入系统")
		Do NewFiled.%Set("value",countPublish+0)
		Do NewFiled.%Set("max",countPublish+0)
		Do dataArr.%Push(NewFiled)
		//外部机构
		Set sql="select Publish FROM HIPPSer_MSG.MtTable where Scope='外联' group by Publish"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		Set countExternal=0
		WHILE tResult.Next(){
			Set countExternal=countExternal+1
		}
		Set NewFiled = ##class(%DynamicObject).%New()
		Do NewFiled.%Set("name","外部机构")
		Do NewFiled.%Set("value",countExternal+0)
		Do NewFiled.%Set("max",countPublish+0)
		Do dataArr.%Push(NewFiled)
	#;	//单点登录
	#;	Set NewFiled = ##class(%DynamicObject).%New()
	#;	Do NewFiled.%Set("name","单点登录")
	#;	Do NewFiled.%Set("value",3)
	#;	Do NewFiled.%Set("max",countPublish+0)
	#;	Do dataArr.%Push(NewFiled)
		//上级平台
		Set NewFiled = ##class(%DynamicObject).%New()
		Do NewFiled.%Set("name","上级平台")
		Do NewFiled.%Set("value","暂未接入")
		Do dataArr.%Push(NewFiled)
		//主流对接方式SOAP'
		Set sql="select Publish FROM HIPPSer_MSG.MtTable where AccessWay='SOAP' group by Publish"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		Set countSoap=0
		WHILE tResult.Next(){
			Set countSoap=countSoap+1
		}
		Set NewFiled = ##class(%DynamicObject).%New()
		Do NewFiled.%Set("name","主流对接方式")
		Do NewFiled.%Set("value","SOAP")
		Do dataArr.%Push(NewFiled)
		Set pResponse=##class(Ens.StringResponse).%New()
		Set dataArr=[{"name":"接入系统","value":32,"max":32},{"name":"外部机构","value":6,"max":6},{"name":"上级平台","value":"区域信息平台"},{"name":"主流对接方式","value":"SOAP"}]
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
