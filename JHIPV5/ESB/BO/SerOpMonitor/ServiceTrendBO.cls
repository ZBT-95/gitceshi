/// Classname:	JHIPV5.ESB.BO.SerOpMonitor.ServiceTrendBO
/// Summary:	集成引擎监管服务监控模块——服务运行趋势获取;
/// TODO:		获取消息数、错误数、告警数等数据;
/// WebMethod:	统一对外方法InvokeHDR;
/// Parameters:	参数:Ens.StringRequest消息类型;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐、李建波;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SerOpMonitor.ServiceTrendBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// /获取服务运行状态趋势   输入value: 1或2（1：当日，2：近七天）  返回格式serverStateData = {
Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	
	set jsonObject = ##class(%DynamicObject).%New()
	set jsonObject1 = ##class(%DynamicObject).%New()
	set dataArr=##class(%DynamicArray).%New()
	set dataArrX=##class(%DynamicArray).%New()
	set dataArrName=##class(%DynamicArray).%New()
	set dataArrY=##class(%DynamicArray).%New()
	set dataArra=##class(%DynamicArray).%New()
	set dataArrb=##class(%DynamicArray).%New()
	set dataArrc=##class(%DynamicArray).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	//当日：获取当前时间七等分
	try{
		Set jsonObject1=##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set dataArr=..getDay()
		Set:(jsonObject1.%Get("value")+0)=2 dataArr=..getWeek()
		////查询时间段息数、错误数、告警数	
		FOR i=0:1:6{
			Set time1=dataArr.%Get(i)
			Set time2=dataArr.%Get(i+1)
			Do dataArrX.%Push(time1)
			Do dataArra.%Push(..getMsg(time1,time2))
			Do dataArrb.%Push(..getError(time1,time2))
			Do dataArrc.%Push(..getAlert(time1,time2))
		}  
		Do dataArrName.%Push("消息数")
		Do dataArrName.%Push("错误数")
		Do dataArrName.%Push("告警数")
		Do dataArrY.%Push(dataArra)
		Do dataArrY.%Push(dataArrb)
		Do dataArrY.%Push(dataArrc)
		Set jsonObject.Xdata=dataArrX
		Set jsonObject.nameArr=dataArrName
		Set jsonObject.Ydata=dataArrY
		Set pResponse.StringValue=$zcvt(jsonObject.%ToJSON(),"o","UTF8")
	}Catch(e){	
		Set tSC=e.AsStatus()
		$$$LOGERROR("获取失败"_e.DisplayString())
	}
	Quit $$$OK
}

// 日期

Method getDay() As %DynamicArray
{
	set dataArr2=##class(%DynamicArray).%New()
	Set time = $zdt($H,3)
	Do dataArr2.%Push($system.SQL.DATEADD("hh",-7,time))
	Do dataArr2.%Push($system.SQL.DATEADD("hh",-6,time))
	Do dataArr2.%Push($system.SQL.DATEADD("hh",-5,time))
	Do dataArr2.%Push($system.SQL.DATEADD("hh",-4,time))
	Do dataArr2.%Push($system.SQL.DATEADD("hh",-3,time))
	Do dataArr2.%Push($system.SQL.DATEADD("hh",-2,time))
	Do dataArr2.%Push($system.SQL.DATEADD("hh",-1,time))
	Do dataArr2.%Push(time)
	Quit dataArr2
}

// 周时间

Method getWeek() As %DynamicArray
{
	set dataArr1=##class(%DynamicArray).%New()
	Set time = $zd($HOROLOG,3)
	Do dataArr1.%Push($P($system.SQL.DATEADD("dd",-7,time)," ",1))
	Do dataArr1.%Push($P($system.SQL.DATEADD("dd",-6,time)," ",1))
	Do dataArr1.%Push($P($system.SQL.DATEADD("dd",-5,time)," ",1))
	Do dataArr1.%Push($P($system.SQL.DATEADD("dd",-4,time)," ",1))
	Do dataArr1.%Push($P($system.SQL.DATEADD("dd",-3,time)," ",1))
	Do dataArr1.%Push($P($system.SQL.DATEADD("dd",-2,time)," ",1))
	Do dataArr1.%Push($P($system.SQL.DATEADD("dd",-1,time)," ",1))
	Do dataArr1.%Push(time)
	Quit dataArr1
}

// 获取消息量

Method getMsg(time1 As %String, time2 As %String) As %String
{
	
	Set num=0
	set queryIn="SELECT sum(TotalCount) as num FROM Ens_Activity_Data.Seconds where HostType = '1'  and TimeSlot>='"_time1_"' and TimeSlot<'"_time2_"'"
	Set tSC = ..Adapter.ExecuteQuery(.tResult1,queryIn)
	if (tResult1.Next()){
		set num=tResult1.Get("num")
	}
	Quit num+0
}

// 获取错误数据

Method getError(time1 As %String, time2 As %String) As %String
{
	Set num=0
	Set sql="SELECT count(Distinct SessionID) as num FROM Ens.MessageHeader where TimeCreated >= '"_time1_"' and TimeProcessed <'"_time2_"' and IsError='1'"
	Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	if tResult.Next(){
		Set num = tResult.Get("num")
	}
	Quit num+0
}

// 获取告警数据

Method getAlert(time1 As %String, time2 As %String) As %String
{
	
	Set num=0
	Set sql="SELECT count(Distinct MessageID) as num,Type FROM Ens_Util.Log where TimeLogged >= '"_time1_"' and TimeLogged <'"_time2_"' and Type ='3'"
	Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	if tResult.Next(){
		Set num = tResult.Get("num")
		Set Type = tResult.Get("Type")
	}
	Quit num+0
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
