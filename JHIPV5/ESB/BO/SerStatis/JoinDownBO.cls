/// Classname:	JHIPV5.ESB.BO.SerStatis.JoinBO
/// Summary:	集成引擎监管服务统计模块——接入方式数据获取;
/// TODO:		获取接入方式数据;
/// WebMethod:	统一对外方法InvokeHDR;
/// Parameters:	参数:Ens.StringRequest消息类型;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐、李建波、李健;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.SerStatis.JoinDownBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 第三个，接入方式BO

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
				Set tSC=$$$OK
				set jsonObject = ##class(%DynamicObject).%New()
				set dataArr = ##class(%DynamicArray).%New()
				set tStatement = ##class(%SQL.Statement).%New()
				Do dataArr.%Push("SOAP")
			    Do dataArr.%Push("HTTP")
				Do dataArr.%Push("MQ")
				Do dataArr.%Push("TCP")
				Do dataArr.%Push("SQL")
		    	//序列化json
			    Set jsonObject=dataArr
		    	Set jsonString=jsonObject.%ToJSON()
		    	Set pResponse=##class(Ens.StringResponse).%New()
				Set pResponse.StringValue=jsonString


	}Catch(e){	
		Set tSC=e.AsStatus()
    }
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>InvokeHDR</Method>
	</MapItem>
</MapItems>
}

}
