/// Classname:	JHIPV5.ESB.BO.SerConManage.GetItems
/// Summary:	服务配置管理;
/// TODO:		服务配置管理列表获取BO;
/// WebMethod:	OnMethod
/// Parameters:	Ens.StringRequest;
/// Version:	1.0;
/// Date:		2021年08月04号16:00;
/// Author:		马家齐;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SerConManage.GetItems Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

Property total As %Integer [ InitialExpression = 0 ];

Method OnMethod(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	Set tSC=$$$OK
	Set jsonObject = ##class(%DynamicObject).%New()
	set itemArr=##class(%DynamicArray).%New()
	Set sItemObject = ##class(%DynamicObject).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	Try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set spaceType = json.%Get("spaceType")
		Set hostType = json.%Get("hostType")
		Set value = json.%Get("value")
		Set production = json.%Get("production")
		Set Category = json.%Get("Category")
		Set size = json.%Get("size")
		Set number = json.%Get("number")
		//根据传参修改sql,获取组件ID
#;		Set production ="HIIPKG.FoundationProduction"
		Set sql="SELECT ID FROM Ens_Config.Item where Production = '"_production_"'"
		Set:value'="" sql=sql_ " and Name = '"_value_"'"
		Set:Category'="" sql=sql_ " and Name = '"_Category_"'"
		Set qStatement = ##class(%SQL.Statement).%New()
		Set tSC = qStatement.%Prepare(.sql)
		#Dim rtn As %SQL.StatementResult = qStatement.execute()
		While (rtn.%Next()){
			Set sItemObject=..GetItem(rtn.%Get("ID"),hostType)
			If (sItemObject.%Size())>=1{
				Do itemArr.%Push(sItemObject)
				Set ..total=..total+1
			}
			
		}
		Set jsonObject.rows=itemArr
		Set jsonObject.total= ..total
	}Catch(ex){
		$$$LOGERROR("BO-OnMethod代码运行出错->"_ex.DisplayString())
		Set tSC=ex.AsStatus()
		Set jsonObject.code="500-"
		Set jsonObject.data="BO代码运行出错！！！ 请前往HC后台排查原因。"
	}
	Set pResponse.StringValue=jsonObject.%ToJSON()
	Kill jsonObject,sItemObject,itemArr,json
	Set ..total=0
	Quit $$$OK
}

// 获取单个组件内容，pRequest：组件ID，hostType：组件类型（1-BS, 2-BP, 3-BO）

Method GetItem(pRequest As %String, hostType As %String) As %DynamicObject
{
	Set itemObject = ##class(%DynamicObject).%New()
	set CategoryArr=##class(%DynamicArray).%New()
	Try{
		Set Item = ##Class(Ens.Config.Item).%OpenId(pRequest)
		// 获取组件相关信息
		Set type=Item.BusinessType()
		IF hostType=type{
			Do itemObject.%Set("serviceName",$Zcvt(Item.Name_"","O","UTF8"))
			Set Category=$Zcvt(Item.Category_"","O","UTF8")
			Do CategoryArr.%Push(Category)
			Do itemObject.%Set("Category",Category)
			Do itemObject.%Set("Enabled",Item.Enabled_"")
			Do itemObject.%Set("ClassName",Item.ClassName_"")
			Do itemObject.%Set("LogTraceEvents",Item.LogTraceEvents_"")
			Do itemObject.%Set("Production",Item.Production.Name_"")
			Do itemObject.%Set("Foreground",Item.Foreground_"")
			Do itemObject.%Set("DisableErrorTraps",Item.DisableErrorTraps_"")
			Do itemObject.%Set("Comment",Item.Comment_"")
			Do itemObject.%Set("AlertGroups",Item.AlertGroups_"")
			Do itemObject.%Set("hostType",type_"")
			// 获取组件配置信息
			#Dim settings AS list Of Ens.Config.Setting = Item.Settings
			For i=1:1:settings.Count() {
				#dim tSetting As Ens.Config.Setting
				Set tSetting = settings.GetAt(i)
				Do itemObject.%Set($Zcvt(tSetting.Name_"","O","UTF8"),$ZCVT(tSetting.Value_"","O","UTF8"))
			}
		}
	}Catch(ex){
		$$$LOGERROR("BO-GetItem代码运行出错->"_ex.DisplayString())
		Set tSC=ex.AsStatus()
		Set itemObject.code="500-2"
		Set itemObject.data="BO代码运行出错！！！ 请前往HC后台排查原因。"
	}
	Set itemObject.CategoryArr=CategoryArr
	Quit itemObject
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>OnMethod</Method>
	</MapItem>
</MapItems>
}

}
