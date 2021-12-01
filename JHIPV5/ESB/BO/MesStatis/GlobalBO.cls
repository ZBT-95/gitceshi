Class JHIPV5.ESB.BO.MesStatis.GlobalBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 获取BS、BO的Global------BO

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		set jsonObject = ##class(%DynamicObject).%New()
		set returnArr=##class(%DynamicArray).%New()
		set tStatement = ##class(%SQL.Statement).%New()
		Set countoto=0
		//查询所有BO
		Set sqlName="SELECT Name FROM Ens_Config.Item where ClassName in(SELECT ID FROM %Dictionary.CompiledClass where PrimarySuper like '%Ens.BusinessOperation%')"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlName)
		Set name=""
		WHILE tResult.Next(){
			Set countoto=countoto+1
		    Set name=name_"'"_tResult.Get("Name")_"',"
		}
		Set ^b("BO")= "("_name_"''"_")"
		Set jsonObject.rows=returnArr
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
