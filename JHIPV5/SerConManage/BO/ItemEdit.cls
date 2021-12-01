/// Classname:	JHIPV5.SerConManage.BO.ItemEdit
/// Summary:	集成引擎监管服务配置模块——组件配置;
/// TODO:		组件配置;
/// WebMethod:	ResendMessage
/// Parameters:	参数:Ens.StringRequest消息类型;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.SerConManage.BO.ItemEdit Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 组件注册服务
ClassMethod InsertItem(tUrl As %String, tMethod As %String) As %Status
{
	Set tSC=$$$OK
	Set jsonObject = ##class(%DynamicObject).%New()
	Try{
		Set spaceType = %request.Get("spaceType")
		Set hostType = %request.Get("hostType")
		Set value = %request.Get("value")
		Set clsName = %request.Get("clsName")
		Set production = %request.Get("production")
		Set Category = %request.Get("category")
		Set PoolSize = %request.Get("poolSize")
		Set:$L(%request.Content)'=0 settings =%request.Content.Read()
		Set prodConf = ##class(Ens.Config.Production).%OpenId(production)
    	Set item = ##class(Ens.Config.Item).%New()
    	Set item.PoolSize = PoolSize
    	Set item.Category=Category
    	Set item.ClassName = clsName
    	Set item.Name = $CASE(value,"":clsName,:value)
    	Set item.Enabled = $$$YES
    	If ("" '= settings){
	    	Set settings=##class(%DynamicArray).%FromJSON(settings)
	    	while settings.%Size(){
		    	#Dim settingObj As %DynamicObject = settings.%Pop()
	    		#Dim settingItem As Ens.Config.Setting = ##Class(Ens.Config.Setting).%New()
	    		Set settingItem.Name = settingObj.%Get("Name")
		    	Set settingItem.Value = settingObj.%Get("Value")
		    	Set target = settingObj.%Get("Target")
		    	If ("" '= target){
			    	Set settingItem.Target = settingObj.%Get("Target")
		    	}
			    D item.Settings.Insert(settingItem)
			}
	    }
    	Set jsonObject.code="200"
		Set jsonObject.data="Item注册完成！！！"
		Do ##class(Ens.Util.Auditing).AuditModifyProductionConfig(prodConf.Name,item.Name,"Item added to production using generator in " _ $classname())
    	Do ##class(EnsPortal.Template.prodConfigSCPage).CallProductionUpdateAndSaveToClass(prodConf,item,"InsertItem")
		Do ##class(Ens.Director).UpdateProduction()
	}Catch(ex){
		Set tSC=ex.AsStatus()
		Set jsonObject.code="500"
		Set jsonObject.data="BO代码运行出错！！！ 请前往HC后台排查原因。"
	}
	w jsonObject.%ToJSON()
	Quit $$$OK
}

// 组件删除

ClassMethod RemoveItem() As %Status
{
	Set tSC = $$$OK
	Set jsonObject = ##class(%DynamicObject).%New()
	Try{
		Set spaceType = %request.Get("spaceType")
		Set value = %request.Get("value")
		Set prodName = %request.Get("production")
		#Dim prodConf As Ens.Config.Production = ##class(Ens.Config.Production).%OpenId(prodName)
		Set sql="SELECT ID FROM Ens_Config.Item where Production = '"_prodName_"' and Name = '"_value_"'"
		Set qStatement = ##class(%SQL.Statement).%New()
		Set tSC = qStatement.%Prepare(.sql)
		#Dim rtn As %SQL.StatementResult = qStatement.execute()
		While (rtn.%Next()){
			Set confItem = ##Class(Ens.Config.Item).%OpenId(rtn.%Get("ID"))
		}
		Set tSC = ##class(EnsPortal.Template.prodConfigSCPage).CallProductionUpdateAndSaveToClass(prodConf,confItem,"RemoveItem")
   		Set tSC = ##class(Ens.Director).UpdateProduction()
   		Set jsonObject.code="200"
		Set jsonObject.data="Item删除完成！！！"
	}Catch(ex){
		Set tSC=ex.AsStatus()
		Set jsonObject.code="500"
		Set jsonObject.data="BO代码运行出错！！！ 请前往HC后台排查原因。"
	}
	w jsonObject.%ToJSON()
	Quit tSC
}

// 组件更新

ClassMethod UpdateItem() As %Status
{
	Set tSC = $$$OK
	Set jsonObject = ##class(%DynamicObject).%New()
	Set settgings =  ##class(%DynamicArray).%New()
	Try{
		Set spaceType = %request.Get("spaceType")
		Set value = %request.Get("value")
		Set prodName = %request.Get("production")
		Set clsName = %request.Get("clsName")
		Set settgings = []
		Set:$L(%request.Content)'=0 settings =%request.Content.Read()
		#Dim prodConf As Ens.Config.Production = ##class(Ens.Config.Production).%OpenId(prodName)
		Set sql="SELECT ID FROM Ens_Config.Item where Production = '"_prodName_"' and Name = '"_value_"'"
		Set qStatement = ##class(%SQL.Statement).%New()
		Set tSC = qStatement.%Prepare(.sql)
		#Dim rtn As %SQL.StatementResult = qStatement.execute()
		While (rtn.%Next()){
			Set item = ##Class(Ens.Config.Item).%OpenId(rtn.%Get("ID"))
			Set item.PoolSize = 0
    		Set item.Category="03.服务配置"
    		Set item.ClassName = clsName
    		Set item.Name = $CASE(value,"":clsName,:value)
    		Set item.Enabled = $$$YES
    		If ("" '= settings){
	    		Do item.Settings.Clear()
	    		Set settings=##class(%DynamicArray).%FromJSON(settings)
	    		while settings.%Size(){
		    	#Dim settingObj As %DynamicObject = settings.%Pop()
	    		#Dim settingItem As Ens.Config.Setting = ##Class(Ens.Config.Setting).%New()
	    		Set settingItem.Name = settingObj.%Get("Name")
		    	Set settingItem.Value = settingObj.%Get("Value")
		    	Set target = settingObj.%Get("Target")
		    	If ("" '= target){
			    	Set settingItem.Target = settingObj.%Get("Target")
		    	}
		    	Do item.Settings.Insert(settingItem)
				}
		    }
    		Do item.%Save()
		}
		Set tSC = ##class(Ens.Director).UpdateProduction()
   		Set jsonObject.code="200"
		Set jsonObject.data="Item更新完成！！！"
	}Catch(ex){
		Set tSC=ex.AsStatus()
		Set jsonObject.code="500"
		Set jsonObject.data="BO代码运行出错！！！ 请前往HC后台排查原因。"
	}
	Kill item
	w jsonObject.%ToJSON()
	Quit tSC
}

// 消息重发

ClassMethod ResubmitMessage() As %Status
{
	Do ##Class(Ens.MessageHeader).ResubmitMessage()
	Quit $$$OK
}

}
