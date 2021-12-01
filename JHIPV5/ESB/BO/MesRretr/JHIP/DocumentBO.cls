Class JHIPV5.ESB.BO.MesRretr.JHIP.DocumentBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 获取追踪详情时间BO

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set jsonObject = ##class(%DynamicObject).%New()
	set DataArr=##class(%DynamicArray).%New()
	Set type=1,num=0,total=0,INTIME=""
	Set pResponse=##class(Ens.StringResponse).%New()
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set SessionID= json.%Get("SessionID")
		Set spaceType= json.%Get("spaceType")
#;		Set ..Adapter.DSN=$S(1=spaceType:"JHIP",2=spaceType:"HII")
		If spaceType=2{
			DO ..Adapter.DSNSet("JHIP")
		}ElseIF spaceType=1{
			DO ..Adapter.DSNSet("HII")
		}
		Set sql = "SELECT Type,SessionId,SourceConfigName,TargetBusinessType,ID, COUNT(*) AS CID, TimeCreated, TimeProcessed FROM Ens.MessageHeader where SessionId= '"_SessionID_"' "
		$$$LOGINFO("sql:"_sql)
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		//遍历结果集并将分页查询显示SQL获取到的数据放至json
		WHILE tResult.Next(){
			Set num=num+1
			Set NewFiled = ##class(%DynamicObject).%New()
			//第一次请求BS发出
			if num="1"{
				Set total=tResult.%Get("CID")
		 		DO NewFiled.%Set("ID",tResult.Get("ID"))
		 		DO NewFiled.%Set("name",tResult.Get("SourceConfigName"))
				DO NewFiled.%Set("inputVal","")
				DO NewFiled.%Set("outputVal",tResult.Get("TimeCreated")_"</br>会话ID："_pRequest.StringValue)
				Set INTIME=tResult.Get("TimeCreated")
				DO NewFiled.%ToJSON()
				Do DataArr.%Push(NewFiled)
		   	}elseIf num="2"{
			   	//第二次请求
			 	Set total=tResult.%Get("CID")
		 		DO NewFiled.%Set("ID",tResult.Get("ID"))
		 		DO NewFiled.%Set("name",tResult.Get("SourceConfigName"))
				DO NewFiled.%Set("inputVal","")
		 		DO NewFiled.%Set("outputVal","")
		 		// type 空值是否存在流程
				if tResult.Get("TargetBusinessType")=3{
					Set type=1
				}else{
					Set type=2
				}
				DO NewFiled.%ToJSON()
				Do DataArr.%Push(NewFiled)
			}else{
				If tResult.Get("Type")=2{
			 		Set total=tResult.Get("CID")
					DO NewFiled.%Set("ID",tResult.Get("ID"))
					DO NewFiled.%Set("name",tResult.Get("SourceConfigName"))
					DO NewFiled.%Set("inputVal",INTIME)
					Set aa = tResult.Get("TimeCreated")
					Set hs=$TRanslate(aa,"-,:, ,.")-$TRanslate(INTIME,"-,:, ,.")
					DO NewFiled.%Set("outputVal",aa_"<BR>耗时："_hs_"毫秒")
					DO NewFiled.%ToJSON()
					Do DataArr.%Push(NewFiled)
				}
				
			 }
			
		}
		Set jsonObject.resinfoArr=DataArr
		DO jsonObject.%Set("total",total)
		Set jsonObject.type=type
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
