Class JHIPV5.ESB.BO.MesRretr.JHIP.ServiceNameBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 查询所有服务名BO

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set jsonObject = ##class(%DynamicObject).%New()
	#Dim dataArr As %DynamicArray=[]
	Set ..Adapter.DSN="",countoto=0
	try{
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set spaceType = json.%Get("spaceType")
		// 切换数据来源
		If spaceType=1{
			DO ..Adapter.DSNSet("JHIP")
		}ElseIF spaceType=2{
			DO ..Adapter.DSNSet("HII")
		}		
		//Set ..Adapter.DSN=$S(1=spaceType:"HII",2=spaceType:"JHIP")
		//查询所有服务
		Set sqlName="SELECT ClassName,Name FROM Ens_Config.Item "
		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlName)
		WHILE tResult.Next(){
			// 判读服务是否为BS
			If ..GetBusinessType(tResult.%Get("ClassName"))="BS"{
				Set NewFiled = ##class(%DynamicObject).%New()
				Set countoto=countoto+1
				Do NewFiled.%Set("Name",tResult.%Get("Name"))
				Do dataArr.%Push(NewFiled)
			}
		}
		Set jsonObject.rows=dataArr
		Set jsonObject.total=countoto
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=jsonObject.%ToJSON()
			
	}Catch(e){	
	  Set tSC=e.AsStatus()
   }
  Quit $$$OK
}

Method GetBusinessType(pClassname As %String) As %String
{
	Set tValue=""
	#Dim tResultbs As EnsLib.SQL.GatewayResultSet
	#Dim tResultbp As EnsLib.SQL.GatewayResultSet
	#Dim tResultbo As EnsLib.SQL.GatewayResultSet
	Set sqlbs="SELECT PrimarySuper FROM %Dictionary.CompiledClass where ID = '"_pClassname_"' AND PrimarySuper like '%Ens.BusinessService%'"
	Set sqlbp="SELECT PrimarySuper FROM %Dictionary.CompiledClass where ID = '"_pClassname_"' AND PrimarySuper like '%Ens.BusinessProcess%'"
	;Set sqlbo="SELECT PrimarySuper FROM %Dictionary.CompiledClass where ID = '"_pClassname_"' AND PrimarySuper like '%Ens.BusinessOperation%'"
	Do {
		Set tSC=..Adapter.ExecuteQuery(.tResultbs,sqlbs)
		IF tResultbs.Next() Set tValue="BS"  Quit 
		Set tSC=..Adapter.ExecuteQuery(.tResultbp,sqlbp)
		IF tResultbp.Next() Set tValue="BP"  Quit
		;Set tSC=..Adapter.ExecuteQuery(.tResultbo,sqlbp)
		;IF tResultbo.Next() Set tValue="BO"  Quit
		Set tValue="BO"  Quit
	} While 0
	;$$$LOGINFO(tValue)
	Quit $G(tValue)
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
