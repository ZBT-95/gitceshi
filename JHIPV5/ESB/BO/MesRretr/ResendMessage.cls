/// Classname:	JHIPV5.ESB.BO.MesRretr.ResendMessage
/// Summary:	集成引擎监管消息检索模块——消息重发;
/// TODO:		重发消息;
/// WebMethod:	ResendMessage
/// Parameters:	参数:Ens.StringRequest消息类型;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.MesRretr.ResendMessage Extends %RegisteredObject [ Language = objectscript ]
{

/// prodName: 要统计的Production全名
/// startTime: ODBC格式的开始时间，格式如“2021-05-31 00:00:00”,闭区间
/// endTime: ODBC格式的结束时间，格式如“2021-06-02 00:00:00”,开区间
/// 上述开始结束时间的组合即为5月31日与6月1日间的统计
ClassMethod GetThroughput(prodName As %String, startTime As %String, endTime As %String, ByRef perfMatrix As %DynamicObject) As %Status
{
	Set tSC = $$$OK
	Set perfMatrix = {}
	#Dim prodInfo As ISC.Utilities.Production.ProductionInformatics = ""
	Set tSC = ##Class(ISC.Utilities.Production.ProductionInformatics).GetInstance(prodName,.prodInfo)
	If 'tSC {Return $$$ERROR("Failed in getting production informatics")}
	Set tSC = prodInfo.GetMeta()
	If 'tSC {Return $$$ERROR("Failed in getting production "_prodName_" meta data")}
	//Get overrall input throughput
	Set inSqlString = "select count(ID) from Ens.MessageHeader where SourceConfigName IN ("_prodInfo.InputHostString_") and TimeCreated between ? and ?"
	Set tStatement = ##Class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(inSqlString)
	#Dim tResult As %SQL.StatementResult = tStatement.%Execute(startTime,endTime)
	if (tResult.%Next()){
		Set perfMatrix.InputMsgCount = tResult.%GetData(1)
	}
	//Get overall output throughput
	Set outSqlString = "select count(ID) from Ens.MessageHeader where TargetConfigName IN ("_prodInfo.OutputHostString_") and TimeCreated between ? and ?"
	//Set tStatement = ##Class(%SQL.Statement).%New()
	Set tSC = tStatement.%Prepare(outSqlString)
	Set tResult = tStatement.%Execute(startTime,endTime)
	if (tResult.%Next()){
		Set perfMatrix.OutputMsgCount = tResult.%GetData(1)
	}
	//Get throughput by Business Partner
	#Dim partners As %DynamicObject = prodInfo.PartnerRelation
	#Dim iter As %Iterator.Object  = partners.%GetIterator()
	While iter.%GetNext(.key,.val){
		set op = $Extract(key,$L(key)-1,$L(key))
		Set sqlString = $Case(op,
		"in":"select count(ID) from Ens.MessageHeader where SourceConfigName IN ("_val_") and TimeCreated between ? and ?",
		"ot":"select count(ID) from Ens.MessageHeader where TargetConfigName IN ("_val_") and TimeCreated between ? and ?",
		:""
		)
		If ("" '= sqlString){
			Set tSC = tStatement.%Prepare(sqlString)
			Set tResult = tStatement.%Execute(startTime,endTime)
			if (tResult.%Next()){
				Set existing = perfMatrix.%Get(key)
				D perfMatrix.%Set(key,existing+tResult.%GetData(1))
			}
		}
	}
	Quit tSC
}

ClassMethod ResendMessage(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	Set tSC = $$$OK
	
	Set tSC = ##Class(Ens.MessageHeader).ResendDuplicatedMessage(tMessID,.newId,,newReq)
	Quit tSC
}

}
