/// Classname:	JHIPV5.ESB.RESTS.BaseRest
/// Summary:	集成引擎监控分派类；
/// TODO:		调取后台主键组件;
/// Method:		GetStatus测试服务状态、SerOpMonitor获取服务监控数据;
/// Version:	1.0;
/// Date:		2021年07月28号09:17;
/// Author:		马家齐;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.RESTS.BaseRest1 Extends %CSP.REST
{

Parameter HandleCorsRequest = "true";

XData UrlMap [ XMLNamespace = "http://www.bjgoodwill.com/urlmap" ]
{
<Routes>
	<Route Url="/*" Method="OPTIONS" Call="GetStatus"/>
	<Route Url="/:pUrl/:pMethod" Method="POST" Call="Iesp" /> 
	<!--<Route Url="/qMethod/SerConManage/InsertItem" Method="POST" Call="InsertItem" />
	<Route Url="/qMethod/SerConManage/RemoveItem" Method="POST" Call="RemoveItem" />
	<Route Url="/qMethod/SerConManage/UpdateItem" Method="POST" Call="UpdateItem" />-->
 </Routes>
}

Parameter UseSession As Integer = 0;

ClassMethod GetStatus() As %Status
{
	Quit $$$OK
}

// 服务监控数据获取

ClassMethod Iesp(tUrl As %String, tMethod As %String) As %Status
{
 	Set tSC=$$$OK
	Try{
		//创建BS对象并将消息发送BS
		Set SerOpMonitorBS =##class(JHIPV5.ESB.BS.BaseBS).%New()
		Set tSC=##class(Ens.Director).CreateBusinessService("集成引擎监控BS",.SerOpMonitorBS)
		Set tSC = SerOpMonitorBS.Query(tUrl_"."_tMethod,%request,.tResponse)
		Do %response.SetHeader("Content-Type", "application/json;charset=UTF-8")
	}Catch(ex){
		Set tResponse="失败内容："_ex.DisplayString()
		Set tSC=ex.AsStatus()
	}
	w tResponse
	Quit tSC
}

// 组件注册服务

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
		Set:$L(%request.Content)'=0 settings =%request.Content.Read()
		Set prodConf = ##class(Ens.Config.Production).%OpenId(production)
    	Set item = ##class(Ens.Config.Item).%New()
    	Set item.PoolSize = 0
    	Set item.Category="03.服务配置"
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

ClassMethod ResubmitMessage() As %Status
{
	Do ##Class(Ens.MessageHeader).ResubmitMessage()
	Quit $$$OK
}

}
