Class JHIPV5.ESB.BO.SerStatis.DownloadBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 表格下载BO

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
	Set MyString=pRequest.StringValue
	Set name= $PIECE(MyString,"@",1)
	Set Publish= $PIECE(MyString,"@",2)
	Set Subscribe = $PIECE(MyString,"@",3)
	set jsonObject = ##class(%DynamicObject).%New()
	set dataArr=##class(%DynamicArray).%New()
	set tStatement = ##class(%SQL.Statement).%New()
	Set countoto=0
	//查询soap
	Set Sql="SELECT ID, AccessWay, Publish, Scope, ServiceName, ServiceType, Subscribe FROM HIPPSer_MSG.MtTable where 1=1"
	Set tSC=..Adapter.ExecuteQuery(.tResult,Sql)
	;set fileName=$TRanslate($ZDate($H,3),"-")
 	set fileName="C:\服务统计详情.xls"
 	Set stream=##class(%FileCharacterStream).%New()
    Set stream.Filename=fileName
    do stream.Clear()
	;do stream.WriteLine("接入方式      联通范围          发布系统                     服务名称                                    服务类型                  订阅系统")
 	;do stream.OpenStream(Filename)
 	do stream.MoveToEnd()
 	do stream.Write("接入方式	")
 	do stream.Write("联通范围	")
 	do stream.Write("发布系统	")
 	do stream.Write("服务名称	")
 	do stream.Write("服务类型	")
 	do stream.Write("订阅系统	")
 	do stream.WriteLine()
 	;do stream.WriteLine("接入方式")
 	;do stream.SaveStream()
 	;do stream.Write("联通范围")
 	WHILE tResult.Next(){
	 		$$$LOGINFO("tSC111")
			Set countoto=countoto+1
	 		Set NewFiled = ##class(%DynamicObject).%New()
	 		Set AccessWay=tResult.Get("AccessWay")
	    	Set Publish=tResult.Get("Publish")
	    	Set Scope=tResult.Get("Scope")
	    	Set ServiceName=tResult.Get("ServiceName")
	    	Set ServiceType=tResult.Get("ServiceType")
	    	Set Subscribe=tResult.Get("Subscribe")
	    	do stream.Write(""_AccessWay_"	")
		 	do stream.Write(""_Scope_"	")
		 	do stream.Write(""_Publish_"	")
		 	do stream.Write(""_ServiceName_"	")
		 	do stream.Write(""_ServiceType_"	")
		 	do stream.Write(""_Subscribe_"	")
	    	do stream.WriteLine()
			;do stream.WriteLine(""_AccessWay_"           "_Scope_"                  "_Publish_"             "_ServiceName_"                  "_ServiceType_"                      "_Subscribe_"")
			 
			 Do dataArr.%Push(NewFiled)
			 
		}
	;Set id=##class(%FileCharacterStream).GetStreamIdForFile(fileName)
	;Set stream=##class(%FileCharacterStream).%Open(id)
	;Do stream.OutputToDevice()
	Set jsonObject=stream.Read()
	;Set jsonObject=$zcvt(stream.Read(),"O","UTF8")
	
	;do stream.%Delete()
	Set pResponse=##class(Ens.StringResponse).%New()
	Set pResponse.StringValue=$zcvt(jsonObject,"O","UTF8")
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
