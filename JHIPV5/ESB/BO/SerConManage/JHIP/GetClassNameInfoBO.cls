Class JHIPV5.ESB.BO.SerConManage.JHIP.GetClassNameInfoBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// //第十个接口// 获取数据服务类别名称内容

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		set jsonObject = ##class(%DynamicObject).%New()
			set dataArr = ##class(%DynamicArray).%New()
		 	Set tStatement = ##class(%SQL.Statement).%New()
		 	//sql查询服务类别
		 	Set sql = "SELECT DISTINCT ID, ClassName FROM (SELECT Ens_Config.Item.ID, Name, (%EXACT(ClassName))ClassName, Category, PoolSize, Enabled, LogTraceEvents,Comment,(%EXACT(FieldCode))FieldCode, FieldName FROM Ens_Config.Item LEFT JOIN HII_ALL_DB.TableFieldDB ON Ens_Config.Item.NAME = HII_ALL_DB.TableFieldDB.SerName) WHERE ClassName LIKE '%Service' GROUP BY ClassName ORDER BY ClassName"
		 	Set tSC = ..Adapter.ExecuteQuery(.tResult,sql)
		 	WHILE tResult.Next(){
				Set NewFiled = ##class(%DynamicObject).%New()
				DO NewFiled.%Set("ClassName",tResult.%Get("ClassName"))
				Do NewFiled.%Set("ID", tResult.%Get("ID"))
				Do dataArr.%Push(NewFiled)
			}
		 	Set jsonObject.clsName=dataArr
	    	Set jsonString=jsonObject.%ToJSON()
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
