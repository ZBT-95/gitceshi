Class JHIPV5.ESB.BO.SerStatis.SysDownBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 下拉系统BO

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set name=pRequest.StringValue
		set jsonObject = ##class(%DynamicObject).%New()
		set totalArr=##class(%DynamicArray).%New()
		set nameArr=##class(%DynamicArray).%New()
		set tStatement = ##class(%SQL.Statement).%New()
		//查询所有发布
		Set sqlName="SELECT  distinct(Publish) as Publish FROM HIPPSer_MSG.MtTable"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlName)
	 	WHILE tResult.Next(){
		 	    Set NewFiled = ##class(%DynamicObject).%New()
		    	Do NewFiled.%Set("Publish",tResult.Get("Publish"))
		    	Do totalArr.%Push(NewFiled)
			}
		//查询所有订阅
		Set sqlName="SELECT  distinct(Subscribe) as Subscribe FROM HIPPSer_MSG.MtTable"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlName)
	 	WHILE tResult.Next(){
		 	    Set NewFiled = ##class(%DynamicObject).%New()
		 	    Set Subscribe = tResult.%Get("Subscribe")
		        if Subscribe'=""{
		    	Do NewFiled.%Set("Subscribe",Subscribe)
		    	Do nameArr.%Push(NewFiled)
		        }
			}
	    Set jsonObject.Publish=totalArr
	    Set jsonObject.Subscribe=nameArr
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
