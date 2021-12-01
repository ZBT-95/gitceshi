/// Classname:	JHIPV5.ESB.SerOpMonitor
/// Summary:	集成引擎监管平台；
/// TODO:		数据获取BS;
/// WebMethod:	Query统一获取数据方法
/// Version:	1.1;
/// Date:		2021年07月14号11:50;
/// Author:		马家齐;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BS.BaseBS Extends Ens.BusinessService
{

Parameter SETTINGS = "dataArr:Basic,dataArr2:Basic";

Property dataArr As %String [ InitialExpression = 0 ];

Property dataArr2 As %String [ InitialExpression = 0 ];

// 数据获取

Method Query(tMethod As %String, tRequest As %CSP.Request, Output pResponse As %String) As %Status
{
	Set tSC=$$$OK,str="入参为空"
	Try{
		Set request = ##class(Ens.StringRequest).%New()
		Set response = ##class(Ens.StringResponse).%New()
		Set TargetBO = ^Ens.LookupTable("TargetBO",tMethod)
		$$$LOGINFO("TargetBO"_TargetBO)
		Do ..getRequest(tMethod,tRequest,.str)
		Set request.StringValue=str
		$$$LOGINFO("request"_str)
		Set tSC=..ProcessInput(request,.response,TargetBO)
		Set pResponse=response.StringValue
	}Catch(ex){
		Set pResponse="失败内容："_ex.DisplayString()
		Set tSC=ex.AsStatus()
	}
	Kill request
	Quit tSC
}

// 处理请求消息

Method getRequest(tMethod As %String, tRequest As %CSP.Request, Output pResponse As %String) As %Status
{
	Try{
		Set obj=##Class(%DynamicObject).%New()
		Set parameters = ^Ens.LookupTable("Parameters",tMethod)
		Set:$L($p(parameters,",",1))'=0 tSC=obj.%Set($p(parameters,",",1),tRequest.Get($p(parameters,",",1)))
		Set:$L($p(parameters,",",2))'=0 tSC=obj.%Set($p(parameters,",",2),tRequest.Get($p(parameters,",",2)))
		Set:$L($p(parameters,",",3))'=0 tSC=obj.%Set($p(parameters,",",3),tRequest.Get($p(parameters,",",3)))
		Set:$L($p(parameters,",",4))'=0 tSC=obj.%Set($p(parameters,",",4),tRequest.Get($p(parameters,",",4)))
		Set:$L($p(parameters,",",5))'=0 tSC=obj.%Set($p(parameters,",",5),tRequest.Get($p(parameters,",",5)))
		Set:$L($p(parameters,",",6))'=0 tSC=obj.%Set($p(parameters,",",6),tRequest.Get($p(parameters,",",6)))
		Set:$L($p(parameters,",",7))'=0 tSC=obj.%Set($p(parameters,",",7),tRequest.Get($p(parameters,",",7)))
		Set:$L($p(parameters,",",8))'=0 tSC=obj.%Set($p(parameters,",",8),tRequest.Get($p(parameters,",",7)))
		Set:$L($p(parameters,",",9))'=0 tSC=obj.%Set($p(parameters,",",9),tRequest.Get($p(parameters,",",7)))
		Set:$L($p(parameters,",",10))'=0 tSC=obj.%Set($p(parameters,",",10),tRequest.Get($p(parameters,",",7)))
		Set:$L(tRequest.Content)'=0 tSC=obj.%Set("count",tRequest.Content.Read())
		Set pResponse=obj.%ToJSON()
	}Catch(ex){
		Set tSC=ex.AsStatus()
	}
	Quit $$$OK
}

Method OnProcessInput(request As %RegisteredObject, Output pOutput As Ens.StringResponse, ByRef pHint As %String) As %Status
{
	Set tSC=$$$OK
	Try{
		$$$TRACE("发送到-"_pHint)
		Set tSC=..SendRequestSync(pHint,request,.pOutput)
	}Catch(ex){
		Set pOutput.StringValue="失败内容："_ex.DisplayString()
		Set tSC=ex.AsStatus()
	}
	Quit tSC
}

}
