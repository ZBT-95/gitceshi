Class JHIPV5.ESB.BO.SerOpMonitor.ServiceType Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 服务种类·数据获取
Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
   		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		Set pResponse=##class(Ens.StringResponse).%New()
		//获取服务种类
		Set sql="SELECT Count(ID) as num, Category FROM Ens_Config.Item where Name like '%BS%'  group by Category"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
			IF tResult.Get("Category") '=""{
				Set NewFiled = ##class(%DynamicObject).%New()
				Do NewFiled.%Set("name",tResult.Get("Category"))
				Do NewFiled.%Set("value",tResult.Get("num"))
				Do dataArr.%Push(NewFiled)
			}
		   
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
