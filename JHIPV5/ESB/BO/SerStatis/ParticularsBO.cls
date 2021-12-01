Class JHIPV5.ESB.BO.SerStatis.ParticularsBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 联通接入表格详情BO

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set accept = json.%Get("accept")
		Set range = json.%Get("range")
#;		Set MyString=pRequest.StringValue
#;		Set accept= $PIECE(MyString,"@",1)
#;		Set range = $PIECE(MyString,"@",2)
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		set tStatement = ##class(%SQL.Statement).%New()
		Set countoto=0
		//查询soap
		Set Sql="SELECT distinct(ServiceName), AccessWay, Scope, ServiceName, ServiceType FROM HIPPSer_MSG.MtTable where 1=1"
		if accept'="全部"{
			Set Sql=Sql_"and Scope='"_accept_"'"
			}
		if range'="全部"{
			Set Sql=Sql_"and AccessWay='"_range_"'"
			}
		
		Set tSC=..Adapter.ExecuteQuery(.tResult,Sql)
	 	WHILE tResult.Next(){
				Set countoto=countoto+1
		 		Set NewFiled = ##class(%DynamicObject).%New()
		 		Do NewFiled.%Set("AccessWay",tResult.Get("AccessWay"))
		    	;Do NewFiled.%Set("Publish",tResult.Get("Publish"))
		    	Do NewFiled.%Set("Scope",tResult.Get("Scope"))
		    	Do NewFiled.%Set("ServiceName",tResult.Get("ServiceName"))
		    	Do NewFiled.%Set("ServiceType",tResult.Get("ServiceType"))
		    	;Do NewFiled.%Set("Subscribe",tResult.Get("Subscribe"))
		    	Do dataArr.%Push(NewFiled)
			}
		Set jsonObject.rows=dataArr
	    Set jsonObject.total=countoto
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=$zcvt(jsonObject.%ToJSON(),"O","UTF8")
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
