Class JHIPV5.ESB.BO.MesRretr.JHIP.DeleteCollectBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 第五个， 收藏删除BO， 表 JHIPV5_ESB_DB.CollectionDB

// 通过ID进行删除

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	Set pResponse=##class(Ens.StringResponse).%New()
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set ID= json.%Get("ID")
		Set spaceType= json.%Get("spaceType")
		;Set ..Adapter.DSN=$S(1=spaceType:"JHIP",2=spaceType:"HII")
		set sql="DELETE FROM JHIPV5_ESB_DB.CollectionDB WHERE ID= "_ID_""
		Set tsc=..Adapter.ExecuteQuery(.tResult1,sql)
		Set str={"code":"200"}
		Set str.Text="删除成功"
		Set str.tSC=tsc
		Set pResponse.StringValue=$zcvt(str.%ToJSON(),"O","UTF8")
	}Catch(e){	
	 	$$$LOGERROR("数据获取失败"_e.DisplayString())
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
