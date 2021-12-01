Class JHIPV5.ESB.BO.MesRretr.JHIP.GetCollectBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 第四个，收藏查询BO， HII_Util_Collection_DB.CollectionDB

// 分页，模糊查询

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	
	set jsonObject = ##class(%DynamicObject).%New()
	set dataArr = ##class(%DynamicArray).%New()
	Set pResponse=##class(Ens.StringResponse).%New()
	Set total=0,num = 0
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set inputVal= $zcvt(json.%Get("inputVal"),"O","UTF8")
		Set radioVal= json.%Get("radioVal")
		Set Number= json.%Get("number")
		Set Size= json.%Get("size")
		Set PageTop = Size*(Number-1)+ 1
		Set PageButtom = Size * Number
		set sql="SELECT %VID AS ContentID ,* FROM (SELECT COUNT(*) AS CID,ID,spaceType, inputVal,radioVal FROM JHIPV5_ESB_DB.CollectionDB WHERE inputVal LIKE '%"_inputVal_"%') WHERE %VID BETWEEN "_PageTop_" AND "_PageButtom_""
		$$$LOGINFO("收藏查询sql: "_sql)
		Set tsc1=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
			Set NewFiled = ##class(%DynamicObject).%New()
			Set total=tResult.%Get("CID")
			Set ID=tResult.%Get("ID")
			DO NewFiled.%Set("ID",ID)
			Set inputVal=tResult.%Get("inputVal")
			DO NewFiled.%Set("inputVal",inputVal)
			Set radioVal=tResult.%Get("radioVal")
			DO NewFiled.%Set("radioVal",radioVal)
			Set spaceType=tResult.%Get("spaceType")
			DO NewFiled.%Set("spaceType",spaceType)
			DO NewFiled.%ToJSON()
			Do dataArr.%Push(NewFiled)
		}
		Set jsonObject.rows=dataArr
		DO jsonObject.%Set("total",total)	 		
		Set pResponse.StringValue=jsonObject.%ToJSON()
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
