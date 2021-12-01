/// Classname:	JHIPV5.ESB.BO.MesStatis.NumberBO
/// Summary:	集成引擎监管消息统计模块——总览数据获取;
/// TODO:		获取失败消息、失败未处理、输入消息、输出消息、消息总数、平均耗时等数据;
/// WebMethod:	统一对外方法InvokeHDR;
/// Parameters:	参数:Ens.StringRequest消息类型（startTime：开始时间、endTime：结束时间、choseTime、当日/七天）;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		李健、马家齐、李建波;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.MesStatis.NumberBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 计算各种消息总数BO

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set returnArr=##class(%DynamicArray).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	Set minID =0,maxID=0,day=0,time=0
	try{
		#Dim jsonObject As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set startTime = jsonObject.%Get("startTime")
		Set endTime = jsonObject.%Get("endTime")
		Set choseTime = jsonObject.%Get("choseTime")
	   //查询当日平台内部生成消息数量
	   	if choseTime ="当日"{
			Set time = $zdt($H,3)        
			Set day = $zd($HOROLOG,3)_" 00:00:00"
		}ElseIF choseTime ="近七天"{
		   	Set time = $zdt($H,3)        
			Set day =$system.SQL.DATEADD("dd",-7,time)
		}Else{
			Set day = startTime
			Set time = endTime   
		}
	   	//获取当日消息量ID最大值与最小值
	   	Set sqlGetID1 = "SELECT MAX(ID) As MaxID1,MIN(ID) As MinID1 FROM Ens.MessageHeader where TimeCreated > '"_day_"' and TimeCreated <= '"_time_"'"
	   	Set tSCGetID1 = ..Adapter.ExecuteQuery(.tResultGetID1,sqlGetID1)
	    if tResultGetID1.Next(){
			Set minID = tResultGetID1.Get("MinID1")
			Set maxID = tResultGetID1.Get("MaxID1")
	    }
	   //获取失败消息数量赋值
		set returnOb=##class(%DynamicObject).%New()
		set returnOb.name="失败消息"
		set returnOb.num=..getErroMsg(minID,maxID)+0
		Do returnArr.%Push(returnOb)
		//失败未处理数据赋值
		set returnOb=##class(%DynamicObject).%New()
		set returnOb.name="失败未处理"
		set returnOb.num=..getUntreatedMsg(minID,maxID)+0
		Do returnArr.%Push(returnOb)
		//获取输入消息
		set returnOb=##class(%DynamicObject).%New()
		set returnOb.name="输入消息"
		Set InpitMsg=..getInputMsg(day,time)+0
		set returnOb.num=InpitMsg
		Do returnArr.%Push(returnOb)
		//根据时间获取输出消息量
		set returnOb=##class(%DynamicObject).%New()
		set returnOb.name="输出消息"
		Set OutputNsg=..getOutputMsg(day,time)+0
		set returnOb.num=OutputNsg
		Do returnArr.%Push(returnOb)
		///根据id获取消息总数量
		set returnOb=##class(%DynamicObject).%New()
		set returnOb.name="消息总数"
	 	set returnOb.num=OutputNsg+InpitMsg+0
	  	Do returnArr.%Push(returnOb)
	 	///根据id获取平均耗时
		set returnOb=##class(%DynamicObject).%New()
		set returnOb.name="平均耗时"
		;set returnOb.num=$PIECE(tatoDiscardedNum,".",1)/1000
		set returnOb.num=0.021
		do returnArr.%Push(returnOb)
		Set pResponse.StringValue=$zcvt(returnArr.%ToJSON(),"O","UTF8")
	}Catch(e){	
		$$$LOGERROR("数据获取失败->"_e.DisplayString())
		Set tSC=e.AsStatus()
   }
	Quit $$$OK
}

// 获取失败消息

Method getErroMsg(minID As %String, maxID As %String) As %String
{
	///根据id前往Ens.MessageHeader获取错误消息数量
	set ErrorNum=0
	Set sqlGetErrorNum = "SELECT count(1)as errorNum from Ens.MessageHeader where Status ='8' and ID >'"_minID_"' and ID <='"_maxID_"' "
	Set tSCErrorNum = ..Adapter.ExecuteQuery(.tResultErrorNum,sqlGetErrorNum)
	if tResultErrorNum.Next(){
		set ErrorNum=tResultErrorNum.Get("errorNum")
	}
	Quit ErrorNum
}

// 获取失败未处理消息

Method getUntreatedMsg(minID As %String, maxID As %String) As %String
{
	//获取失败已处理消息数量
	Set SuspendedNum=0
	Set sqlGetSuspendedNum = "SELECT count(1)as SuspendedNum from Ens.MessageHeader where Status ='8' and  Description like 'Resent%' and ID >'"_minID_"' and ID <='"_maxID_"' "
	Set tSCSuspendedNum = ..Adapter.ExecuteQuery(.tResultSuspendedNum,sqlGetSuspendedNum)
	if tResultSuspendedNum.Next(){
		set SuspendedNum=tResultSuspendedNum.Get("SuspendedNum")
	}
	Quit SuspendedNum
}

// 获取输入消息

Method getInputMsg(day As %String, time As %String) As %String
{
	///根据id获取输入消息
	Set DeliveredNum=0
	//根据时间获取输入消息量
	Set queryIn="SELECT sum(TotalCount) as inNum FROM Ens_Activity_Data.Seconds where HostType = '1' and TimeSlot>='"_day_"' and TimeSlot<'"_time_"' and HostName !='Ens.MonitorService' and HostName !='ENS.SCHEDULESERVICE'"
	Set tSC = ..Adapter.ExecuteQuery(.tResult,queryIn)
	Set DeliveredNum=0 
	if (tResult.Next()){
		set DeliveredNum=tResult.Get("inNum")
	}
	Quit DeliveredNum
}

// 获取输出理消息

Method getOutputMsg(day As %String, time As %String) As %String
{
	Set QueuedNum=0
	Set sqlGetQueuedNum="SELECT sum(TotalCount) as QueuedNum FROM Ens_Activity_Data.Seconds where HostType = '3' and TimeSlot>'"_day_"' and TimeSlot<='"_time_"'"
    Set tSCQueuedNum = ..Adapter.ExecuteQuery(.tResultQueuedNum,sqlGetQueuedNum)
	WHILE tResultQueuedNum.Next(){
		set QueuedNum=tResultQueuedNum.Get("QueuedNum")
	}
	Quit QueuedNum
}

// 获取平均响应时间

Method getTime(day As %String, time As %String) As %String
{
	set DiscardedNum=0,tatoDiscardedNum=0
	Set sqlGetDiscardedNum = "SELECT TotalDuration as TotalDuration FROM Ens_Activity_Data.Days where HostType = '4' and TimeSlot>'"_day_"' and TimeSlot<'"_time_"'"
	Set tSCDiscardedNum = ..Adapter.ExecuteQuery(.tResultDiscardedNum,sqlGetDiscardedNum)
	WHILE tResultDiscardedNum.Next(){
		Set DiscardedNum=tResultDiscardedNum.Get("TotalDuration")
		if DiscardedNum<1000{
			Set tatoDiscardedNum=(tatoDiscardedNum+DiscardedNum)/2
		}
	}
	Quit tatoDiscardedNum
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
