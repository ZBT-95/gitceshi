/// Classname:	JHIPV5.MesRretr.BO.ResubmitMessage
/// Summary:	集成引擎监管消息检索模块——消息重发;
/// TODO:		重发消息;
/// WebMethod:	ResendMessage
/// Parameters:	参数:Ens.StringRequest消息类型;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.MesRretr.BO.ResubmitMessage Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 消息补发
ClassMethod ResendMessage(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	Set tSC = $$$OK
	Set tSC = ##Class(Ens.MessageHeader).ResendDuplicatedMessage(tMessID,.newId,,newReq)
	Quit tSC
}

}
