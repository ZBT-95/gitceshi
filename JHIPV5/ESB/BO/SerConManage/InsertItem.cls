/// Classname:	JHIPV5.ESB.BO.SerConManage.InsertItem
/// Summary:	服务配置管理;
/// TODO:		服务配置管理服务注册BO;
/// WebMethod:	OnMethod
/// Parameters:	Ens.StringRequest;
/// Version:	1.0;
/// Date:		2021年08月04号16:00;
/// Author:		马家齐;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SerConManage.InsertItem Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method OnMethod(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	Set tSC=$$$OK
	Set jsonObject = ##class(%DynamicObject).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	Try{
		$$$TRACE(pRequest.StringValue)
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set spaceType = json.%Get("spaceType")
		Set hostType = json.%Get("hostType")
		Set value = json.%Get("value")
		Set clsName = json.%Get("clsName")
		Set production = json.%Get("production")
		Set settings = json.%Get("count")
		Set prodConf = ##class(Ens.Config.Production).%OpenId(production)
    	Set item = ##class(Ens.Config.Item).%New()
    	Set item.PoolSize = 0
    	Set item.Category="03.服务配置"
    	Set item.ClassName = clsName
    	Set item.Name = $CASE(value,"":clsName,:value)
    	$$$TRACE("服务名称->"_item.Name)
    	Set item.Enabled = $$$YES
#;    	If ("" '= settings){
#;	    	Set settings=##class(%DynamicArray).%FromJSON(settings)
#;	    	$$$TRACE("服务大小->"_settings.%Size())
#;    		while settings.%Size(){
#;		    	#Dim settingObj As %DynamicObject = settings.%Pop()
#;		    	$$$TRACE("服务->"_settingObj.%Get("Name"))
#;	    		#Dim settingItem As Ens.Config.Setting = ##Class(Ens.Config.Setting).%New()
#;		    	Set settingItem.Name = settingObj.%Get("Name")
#;		    	Set settingItem.Value = settingObj.%Get("Value")
#;		    	Set target = settingObj.%Get("Target")
#;		    	If ("" '= target){
#;			    	Set settingItem.Target = settingObj.%Get("Target")
#;			    }
#;			    D item.Settings.Insert(settingItem)
#;			    $$$TRACE("服务配置->"_item.Settings)
#;		    }
#;	    }
    	Set tSC = prodConf.Items.Insert(item)
    	Set jsonObject.code="200"
		Set jsonObject.data="Item注册完成！！！"
		Set pResponse.StringValue=$ZCVT(jsonObject.%ToJSON(),"O","UTF8")
		Do ##class(Ens.Util.Auditing).AuditModifyProductionConfig(prodConf.Name,item.Name,"Item added to production using generator in " _ $classname())
    	;Do prodConf.%Save()
    	Do ##class(EnsPortal.Template.prodConfigSCPage).CallProductionUpdateAndSaveToClass(prodConf,"","SaveProduction")
   }Catch(ex){
		$$$LOGINFO("BO代码运行出错->"_ex.DisplayString())
		Set tSC=ex.AsStatus()
		Set jsonObject.code="500"
		Set jsonObject.data="BO代码运行出错！！！ 请前往HC后台排查原因。"
		Set pResponse.StringValue=$ZCVT(jsonObject.%ToJSON(),"O","UTF8")
	}
	Quit $$$OK
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
