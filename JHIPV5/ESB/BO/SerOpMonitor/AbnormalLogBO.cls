/// Classname:	JHIPV5.ESB.BO.SerOpMonitor.AbnormalLogBO
/// Summary:	集成引擎监管服务监控模块——异常日志获取;
/// TODO:		获取异常日志获取数据;
/// WebMethod:	统一对外方法InvokeHDR;
/// Parameters:	参数:Ens.StringRequest消息类型;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐、李建波;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SerOpMonitor.AbnormalLogBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 异常日志
Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set time = $zdt($H,3) 
		Set day = $system.SQL.DATEADD("mi",-5,time)
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		Set sql="SELECT top 1000 TimeLogged,SessionId,Text  FROM Ens_Util.Log where Type='2' and TimeLogged >= '"_day_"' and TimeLogged <= '"_time_"' group by SessionId"
		$$$LOGINFO("sql:"_sql)
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
			Set NewFiled = ##class(%DynamicObject).%New()
			Do NewFiled.%Set("time",tResult.Get("TimeLogged"))
			Do NewFiled.%Set("id",tResult.Get("SessionId"))
			Do NewFiled.%Set("text",tResult.Get("Text"))
		    Do dataArr.%Push(NewFiled)		    	  		
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
