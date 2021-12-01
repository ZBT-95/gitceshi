/// Classname:	JHIPV5.ESB.BO.SerOpMonitor.SerOpMonitorBO
/// Summary:	服务监控数据获取BO；
/// TODO:		获取各指标总数;
/// Method:		QueryNum获取指标数据;
/// Version:	1.0;
/// Date:		2021年07月28号09:17;
/// Author:		马家齐;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SerOpMonitor.SerOpMonitorBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

Parameter SETTINGS = "dataArr:Basic";

// 返回结果集默认为1 ，可进行配置如：50,32,261,25,291,36

Property dataArr As %String [ InitialExpression = "1" ];

/// 服务监控模块数据。 [0,4,261,25,291,36]
Method QueryNum(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set jsonObject = ##class(%DynamicObject).%New()
	set dataArr=##class(%DynamicArray).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	try{
		//服务调用次数
		
		Do dataArr.%Push(..getDeliveredNum()/10000)
		//接入系统
		;Do dataArr.%Push(..getCountPublish()+0)
		Do dataArr.%Push(50)
		//服务总数
		Do dataArr.%Push(..getCountName()+0)
		//已启用服务
		Do dataArr.%Push(..getCountService()+0)
		//启用进程数
		Do dataArr.%Push(..getProcessCount()+0)
		//服务队列
		Do dataArr.%Push(..getQueueNum()+0)
	}Catch(e){
		$$$LOGERROR("数据获取失败"_e.DisplayString())
		Set dataArr=[0,0,0,0,0,0]
	}
	Set:..dataArr'="1" dataArr=..getDataArr()
	Set pResponse.StringValue=$zcvt(dataArr.%ToJSON(),"O","UTF8")
	Quit $$$OK
}

// 获取前台配置数据并返回

Method getDataArr() As %DynamicArray
{
	set Arr=##class(%DynamicArray).%New()
	For i=1:1:6{
		Do Arr.%Push($p(..dataArr,",",i)+0)
	}
	Quit Arr
}

// 获取服务调用次数函数,当前的取值位置为days表，后续要与消息统计的取值表保持一致，因为展示的数据理论上为相同的数据

Method getDeliveredNum() As %String
{
	Set startTime = $zd($HOROLOG,3)_" 00:00:00"
	Set endTime = $zdt($H,3)
	//以定为的最大最小ID为范围进行取值
	set TotalCount=0
	Set sqlGetDeliveredNum = "SELECT TotalCount FROM Ens_Activity_Data.Seconds where HostType = '1' and TimeSlot >='"_startTime_"' and TimeSlot <='"_endTime_"'"
	$$$TRACE(sqlGetDeliveredNum)
	Set tSCDeliveredNum = ..Adapter.ExecuteQuery(.tResultDeliveredNum,sqlGetDeliveredNum)
	WHILE tResultDeliveredNum.Next(){
		set TotalCount=tResultDeliveredNum.Get("TotalCount")+TotalCount
	}
	Quit TotalCount
}

// 获取接入系统数量

Method getCountPublish() As %String
{
	Set sql="SELECT distinct(Publish) as Publish FROM HIPPSer_MSG.MtTable"
	Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	Set countPublish=0
	WHILE tResult.Next(){
	    Set countPublish=countPublish+1
	}
	Quit countPublish
}

// 获取服务总数

Method getCountName() As %String
{
	;Set sql="SELECT distinct Name,count(ID) countName FROM Ens_Config.Item WHERE (Name LIKE '%JH0%' or Name LIKE '%JH1%')"
	Set sql="SELECT distinct Name,count(ID) countName FROM Ens_Config.Item WHERE Name LIKE '%BS%'"
	;Set sql="SELECT distinct ServiceName,Scope FROM HIPPSer_MSG.MtTable"
	Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	if tResult.Next(){
		$$$TRACE(tResult.Get("countName"))
		Set countName = tResult.Get("countName")+0
	}
	Quit countName
}

// 获取启用服务数

Method getCountService() As %String
{
	;Set sql="SELECT distinct Name,count(ID) countService FROM Ens_Config.Item WHERE Enabled='1' and (Name LIKE '%JH0%' or Name LIKE '%JH1%')"
	Set sql="SELECT distinct Name,count(ID) countService FROM Ens_Config.Item WHERE Enabled='1' and Name LIKE '%BS%'"
	Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	if tResult.Next(){
	    Set countService = tResult.Get("countService")+0
	}
	Quit countService
}

// 获取启用进程数

Method getProcessCount() As %String
{
	Set sql="SELECT count(ID) as countName FROM %SYS.ProcessQuery where NameSpace !='%sys' and NameSpace is not null"
	Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	if tResult.Next(){
		Set processCount = tResult.Get("countName")+0
	}
	Quit processCount
}

// 获取服务队列数

Method getQueueNum() As %String
{
	Set sql="call EnsPortal.Queues_EnumerateQueues()"
	Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	Set queueNum = 0
	while tResult.Next(){
		Set queueNum = queueNum+1
	}
	Quit queueNum
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>QueryNum</Method>
	</MapItem>
</MapItems>
}

}
