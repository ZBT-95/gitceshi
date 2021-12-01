Class JHIPV5.ESB.BO.SerStatis.ServiceDropDownBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 获取服务下拉框BO

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set MyString=pRequest.StringValue
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr = ##class(%DynamicArray).%New()
		set tStatement = ##class(%SQL.Statement).%New()
		Set countoto=0
		//查询所有服务
		///JHIP.Production.JHIPV3
		Set sqlName="SELECT distinct Name FROM ( select * from Ens_Config.Item where Production='JHIP.Production.JHIPV3')  WHERE Name LIKE '%JH0%' or Name LIKE '%JH1%'"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlName)
		Set name=""
		WHILE tResult.Next(){
		 		Set countoto=countoto+1
				Set NewFiled = ##class(%DynamicObject).%New()
		    	Do NewFiled.%Set("Name",tResult.%Get("Name"))
		    	Do dataArr.%Push(NewFiled)
			}
		Set jsonObject.rows=dataArr
		Set jsonObject.total="20"
		$$$LOGINFO("result:"_jsonObject.%ToJSON())
		Set pResponse=##class(Ens.StringResponse).%New()
#;		Set pResponse.StringValue=$zcvt(jsonObject.%ToJSON(),"O","UTF8")
		$$$LOGINFO("pResponse:"_pResponse.StringValue)
		Set pResponse.StringValue=jsonObject.%ToJSON()
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
