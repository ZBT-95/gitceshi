/// Classname:	JHIPV5.ESB.BO.SerConManage.DeleteItem
/// Summary:	服务配置管理;
/// TODO:		服务配置管理服务删除BO;
/// WebMethod:	OnMethod
/// Parameters:	Ens.StringRequest;
/// Version:	1.0;
/// Date:		2021年08月04号16:00;
/// Author:		马家齐;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SerConManage.DeleteItem Extends Ens.BusinessOperation
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
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set spaceType = json.%Get("spaceType")
		
	}Catch(ex){
		$$$LOGINFO("BO代码运行出错->"_ex.DisplayString())
		Set tSC=ex.AsStatus()
		Set jsonObject.code="500-"_tSC
		Set jsonObject.data="BO代码运行出错！！！ 请前往HC后台排查原因。"
	}
	Set pResponse.StringValue=jsonObject.%ToJSON()
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
