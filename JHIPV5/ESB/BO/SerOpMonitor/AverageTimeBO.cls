/// Classname:	JHIPV5.ESB.BO.SerOpMonitor.AverageTimeBO
/// Summary:	集成引擎监管服务监控模块——平均耗时大于1秒获取;
/// TODO:		获取平均耗时大于1秒数据;
/// WebMethod:	统一对外方法InvokeHDR;
/// Parameters:	参数:Ens.StringRequest消息类型;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐、李建波;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SerOpMonitor.AverageTimeBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// /平均耗时大于1秒 服务
Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
	    Set day = $zd($HOROLOG,3)_" 00:00:00"
	    Set time = $zdt($H,3) 
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		//获取时间
		Set sql="SELECT ID,HostName, avg(TotalDuration) as tim FROM Ens_Activity_Data.Seconds where HostType ='1' and TotalDuration>='1'and TimeSlot>='"_day_"' and TimeSlot<='"_time_"' group by HostName"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
		    Set NewFiled = ##class(%DynamicObject).%New()
		    Set ID = tResult.Get("ID")
			Set HostName = tResult.Get("HostName")
			Set tim = tResult.Get("tim")
	    	if (tim>1) && (tim<5){
		    	Set tim=tim*100
		    	Set tim= $PIECE(tim,".",1)
		    	Do NewFiled.%Set("time",tim/100+0_"(s)")
		    	Do NewFiled.%Set("id",ID)
		    	Do NewFiled.%Set("name",HostName)
		    	Do dataArr.%Push(NewFiled)		    	  		
		    }elseif tim>5{
		    	Do NewFiled.%Set("time","5.00(s)")
		    	Do NewFiled.%Set("id",ID)
		    	Do NewFiled.%Set("name",HostName)
		        Do dataArr.%Push(NewFiled)
			}
	    }
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=dataArr.%ToJSON()
	}Catch(e){	
		Set tSC=e.AsStatus()
	}
	Quit $$$OK
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
