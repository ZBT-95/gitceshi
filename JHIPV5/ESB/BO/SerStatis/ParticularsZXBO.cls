Class JHIPV5.ESB.BO.SerStatis.ParticularsZXBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 服务总线订阅表格详情BO

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{

	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set name = json.%Get("name")
		Set Publish = json.%Get("Publish")
		Set Subscribe = json.%Get("Subscribe")
		
#;		Set MyString=pRequest.StringValue
#;		Set name= $PIECE(MyString,"@",1)
#;		Set Publish= $PIECE(MyString,"@",2)
#;		Set Subscribe = $PIECE(MyString,"@",3)
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		set tStatement = ##class(%SQL.Statement).%New()
		Set countoto=0
		//查询soap
		Set Sql="SELECT ID, AccessWay, Publish, Scope, ServiceName, ServiceType, Subscribe FROM HIPPSer_MSG.MtTable where 1=1"
		if name'=""{
			Set Sql=Sql_" and ServiceName='"_name_"'"
			}
		if Publish'="全部"{
			Set Sql=Sql_"and Publish='"_Publish_"'"
			}
		if Subscribe'="全部"{
			Set Sql=Sql_"and Subscribe='"_Subscribe_"'"
			}
		
		Set tSC=..Adapter.ExecuteQuery(.tResult,Sql)
	 	WHILE tResult.Next(){
				Set countoto=countoto+1
		 		Set NewFiled = ##class(%DynamicObject).%New()
		 		Do NewFiled.%Set("AccessWay",tResult.Get("AccessWay"))
		    	Do NewFiled.%Set("Publish",tResult.Get("Publish"))
		    	Do NewFiled.%Set("Scope",tResult.Get("Scope"))
		    	Do NewFiled.%Set("ServiceName",tResult.Get("ServiceName"))
		    	Do NewFiled.%Set("ServiceType",tResult.Get("ServiceType"))
		    	Do NewFiled.%Set("Subscribe",tResult.Get("Subscribe"))
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
