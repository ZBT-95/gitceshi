Class JHIPV5.ESB.BO.SerStatis.LinkBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 第二个获取 联通范围

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
	Set MyString=pRequest.StringValue
	set jsonObject = ##class(%DynamicObject).%New()
	set totalArr=##class(%DynamicArray).%New()
	set nameArr=##class(%DynamicArray).%New()
	set tStatement = ##class(%SQL.Statement).%New()
	Set countoto=0
	//查询所有服务
	;Set sqlName="SELECT  Category, Name FROM Ens_Config.Item where ClassName in(SELECT ID FROM %Dictionary.CompiledClass where PrimarySuper like '%Ens.BusinessService%')"
	Set sqlName="SELECT count(distinct  ServiceName) AS num, Scope FROM HIPPSer_MSG.MtTable group by Scope order by num asc"
	Set tSC=..Adapter.ExecuteQuery(.tResult,sqlName)
 	WHILE tResult.Next(){
	 	Set countoto=countoto+tResult.Get("num")
		Do nameArr.%Push(tResult.Get("Scope"))
		Do totalArr.%Push(tResult.Get("num"))
	}
	Do nameArr.%Push("联通总数")
	Do totalArr.%Push(countoto)
	Set jsonObject.xData=nameArr
    Set jsonObject.yData=totalArr
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
