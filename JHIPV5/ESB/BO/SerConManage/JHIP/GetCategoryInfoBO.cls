Class JHIPV5.ESB.BO.SerConManage.JHIP.GetCategoryInfoBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第十一接口Summary:	获取数据服务类别集成内容
/// TODO:		在搜索选项栏的集成服务场景部分，为下拉菜单返回数据
/// Parameters:	无
/// Response:	json对象：{"catg":[{"Category":"","ID":""},...]}; 
/// 				catg:json数组;Category:集成场景名称;ID:数据库中的集成场景内容的数字部分
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		//获取下拉菜单内容
		 	set jsonObject = ##class(%DynamicObject).%New()
			set dataArr = ##class(%DynamicArray).%New()
		 	Set tStatement = ##class(%SQL.Statement).%New()
		 	//sql查询集成服务场景
		 	Set sql = "SELECT DISTINCT id, Category FROM (SELECT Ens_Config.Item.ID, Name, ClassName, Category, PoolSize, Enabled, LogTraceEvents, Comment,(%EXACT(FieldCode))FieldCode, FieldName FROM Ens_Config.Item LEFT JOIN HII_ALL_DB.TableFieldDB ON Ens_Config.Item.NAME = HII_ALL_DB.TableFieldDB.SerName WHERE ClassName LIKE '%BP%')  GROUP BY Category ORDER BY Category"
		 	Set tSC = ..Adapter.ExecuteQuery(.tResult,sql)
		 	//遍历结果集并存入json对象
		 	WHILE tResult.Next(){
				Set NewFiled = ##class(%DynamicObject).%New()
				Set Category = tResult.%Get("Category")
				DO NewFiled.%Set("Category",Category)
				//截取集成场景名称前的数字部分作为id
				Set id = $p(Category,".",1)
				Do NewFiled.%Set("ID", id)
				Do dataArr.%Push(NewFiled)
			}
			//序列化json
		 	Set jsonObject.catg=dataArr
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
