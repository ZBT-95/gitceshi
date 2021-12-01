/// Classname:	JHIPV5.ESB.BO.SerConManage.ServiceListBO
/// Summary:	服务配置管理;
/// TODO:		获取组件列表;
/// WebMethod:	QueryData;
/// Parameters:	Ens.StringRequest;
/// Version:	1.0;
/// Date:		2021年08月04号16:00;
/// Author:		马家齐;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SerConManage.ServiceListBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 根据请求获取对应组件列表：BS、BP、BO

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set jsonObject = ##class(%DynamicObject).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	#Dim dataArr As %DynamicArray=[]
	Set countoto=0
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set spaceType = json.%Get("spaceType")
		Set hostType = json.%Get("hostType")
		// 切换数据来源
		Set ..Adapter.DSN=$S(1=spaceType:"JHIP",2=spaceType:"HII")
		//查询所有服务
		Set sql="SELECT ClassName,Name,Enabled,Category,Settings FROM Ens_Config.Item "
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
			// 判读服务是否为BS
			Set NewFiled = ##class(%DynamicObject).%New()
			If ..GetBusinessType(tResult.%Get("ClassName"))=hostType{
				Set countoto=countoto+1
				Do NewFiled.%Set("Name",tResult.%Get("Name"))
			}
			Do dataArr.%Push(NewFiled)
		}
		Set jsonObject.rows=dataArr
		Set jsonObject.total=countoto
		Set pResponse.StringValue=jsonObject.%ToJSON()
			
	}Catch(e){
		$$$LOGERROR("QueryData faile->"_e.DisplayString())	
	 	Set tSC=e.AsStatus()
	}
	Quit $$$OK
}

// 获取组件类型：BS、BP、BO

Method GetBusinessType(pClassname As %String) As %String
{
	Set tValue=""
	#Dim tResultbs As EnsLib.SQL.GatewayResultSet
	#Dim tResultbp As EnsLib.SQL.GatewayResultSet
	#Dim tResultbo As EnsLib.SQL.GatewayResultSet
	Set sqlbs="SELECT PrimarySuper FROM %Dictionary.CompiledClass where ID = '"_pClassname_"' AND PrimarySuper like '%Ens.BusinessService%'"
	Set sqlbp="SELECT PrimarySuper FROM %Dictionary.CompiledClass where ID = '"_pClassname_"' AND PrimarySuper like '%Ens.BusinessProcess%'"
	Do {
		Set tSC=..Adapter.ExecuteQuery(.tResultbs,sqlbs)
		IF tResultbs.Next() Set tValue="BS"  Quit 
		Set tSC=..Adapter.ExecuteQuery(.tResultbp,sqlbp)
		IF tResultbp.Next() Set tValue="BP"  Quit
		Set tValue="BO"  Quit
	} While 0
	Quit $G(tValue)
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>QueryData</Method>
	</MapItem>
</MapItems>
}

}
