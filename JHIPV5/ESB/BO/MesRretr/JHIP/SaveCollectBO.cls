Class JHIPV5.ESB.BO.MesRretr.JHIP.SaveCollectBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 第三个， 收藏添加BO， 表 JHIPV5_ESB_DB.CollectionDB

// 重复添加无效

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	Set pResponse=##class(Ens.StringResponse).%New()
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set inputVal= $zcvt(json.%Get("inputVal"),"O","UTF8")
		Set radioVal= json.%Get("radioVal")
		Set spaceType= json.%Get("spaceType")
		//拼接inputVal和radioVal，后面用FileBody来判读唯一值
		Set FileBody=inputVal_"-"_radioVal
		set sql="SELECT ID FROM JHIPV5_ESB_DB.CollectionDB Where FileBody = '"_FileBody_"'"
		$$$LOGINFO("sql: "_sql)
		Set tsc1=..Adapter.ExecuteQuery(.tResult,sql)
		//设置开关factor，当factor为1时，允许收藏，通过遍历FileBody来改变factor
		set factor =1
		While tResult.Next() 
		{
			set factor=0
		}
		if factor=0{
			Set str={"code":"201","Text":"该收藏已存在，重复收藏"}
		}elseIf factor=1{
			set sql="INSERT INTO JHIPV5_ESB_DB.CollectionDB (FileBody,inputVal,radioVal,spaceType) VALUES('"_FileBody_"','"_inputVal_"','"_radioVal_"','"_spaceType_"')"
			Set tsc2=..Adapter.ExecuteUpdate(.tResult2,sql)
			Set str={"code":"200","Text":"收藏成功"}
		}
		
	}Catch(e){
		Set str={"code":"201","Text":"收藏失败"}
	 	Set tSC=e.AsStatus()
   }
  	Set pResponse.StringValue=$zcvt(str.%ToJSON(),"O","UTF8")
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
