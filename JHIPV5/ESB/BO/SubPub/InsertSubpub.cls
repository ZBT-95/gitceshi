/// Classname:	JHIPV5.ESB.BO.SubPub.InsertSubpub
/// Summary:	集成引擎监管订阅发布模块;
/// TODO:		新增订阅关系;
/// WebMethod:	InsertSubpub;
/// Parameters:	参数:Ens.StringRequest消息类型;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SubPub.InsertSubpub Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method InsertSubpub(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set jsonObject = ##class(%DynamicObject).%New()
	set dataArr=##class(%DynamicArray).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set spaceType= json.%Get("spaceType")
		Set serName= json.%Get("serName")
		Set ..Adapter.DSN=$S(1=spaceType:"JHIP",2=spaceType:"HII")
		
	}catch(e){
		$$$LOGERROR("InsertSubpubBO获取订阅关系出错->"_e.DisplayString())
	}
	Quit $$$OK
}

// 获取订阅系统

Method InSertSubSys(pSerName As %String, Output pResponse As %String) As %Status
{
	Set tSC=$$$OK
	Set sql="SELECT * FROM JHIPV5_ESB_DB.SubPubDB Where serName = ?"
	Set tSC = ..Adapter.ExecuteQuery(.tResult,pSql,pSerName)
	WHILE pSql.Next(){
		
	}
	Quit tSC
}

// 获取发布系统

Method InSertPubSys(pSerName As %String, Output pResponse As %String) As %Status
{
	Set tSC=$$$OK
	Set sql="SELECT * FROM JHIPV5_ESB_DB.PubSysDB Where serName = ?"
	Set tSC = ..Adapter.ExecuteQuery(.tResult,pSql,pSerName)
	WHILE pSql.Next(){
		
	}
	Quit tSC
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>InsertSubpub</Method>
	</MapItem>
</MapItems>
}

}
