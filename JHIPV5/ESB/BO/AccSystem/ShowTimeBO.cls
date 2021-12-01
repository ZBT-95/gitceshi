Class JHIPV5.ESB.BO.AccSystem.ShowTimeBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第八个，表格详情
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set MyString=pRequest.StringValue
		Set Number= $PIECE(MyString,"@",1)
		Set Size= $PIECE(MyString,"@",2)
		Set selVal = $PIECE(MyString,"@",3)
		Set PageTop = Size*(Number-1)+ 1
		Set PageButtom = Size * Number
		;Set time = $zdt($H,3)
		;Set day =$system.SQL.DATEADD("dd",-7,time) 
		Set day ="2019-07-25 17:26:04.500"
		Set time ="2021-07-25 17:26:04.500"
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		//系统数
		if selVal=""{
				Set sql="SELECT %VID AS ContentID ,* FROM (SELECT distinct substring(Description,1,charindex(':',Description)-1) as ClassName,PrimaryContact_Name as name, PrimaryContact_PhoneNumber as phone,ID FROM Ens_Config.BusinessPartner"
			}
		if selVal'=""{
				Set sql="SELECT %VID AS ContentID ,* FROM (SELECT distinct substring(Description,1,charindex(':',Description)-1) as ClassName,PrimaryContact_Name as name, PrimaryContact_PhoneNumber as phone,ID FROM Ens_Config.BusinessPartner  where Description like '%"_selVal_"%'"
			}
		Set sql = sql_") WHERE %VID BETWEEN "_PageTop_" AND "_PageButtom_" "
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
				Set NewFiled = ##class(%DynamicObject).%New()
		    	Set ClassName = tResult.Get("ClassName")
		    	Set name = tResult.Get("name")
		    	Set phone = tResult.Get("phone")
		    	Set ID = tResult.Get("ID")
		    	Set sql2="SELECT count(ID) as num FROM Ens.MessageHeader where TimeCreated >= '"_day_"' and TimeCreated <= '"_time_"' and SourceConfigName in(select distinct ServiceName FROM HIPPSer_MSG.MtTable where Publish='"_ID_"')"
		   		Set tSC2=..Adapter.ExecuteQuery(.tResult2,sql2)
		   		if tResult2.Next(){
						Do NewFiled.%Set("Liveness",tResult2.Get("num"))
			   		}
				Do NewFiled.%Set("Vendor",ClassName)
				Do NewFiled.%Set("Linkman",name)
				Do NewFiled.%Set("ContactWay",phone)
				Do dataArr.%Push(NewFiled)
		    }
		Set sql="SELECT distinct substring(Description,1,charindex(':',Description)-1) as ClassName,PrimaryContact_Name as name, PrimaryContact_PhoneNumber as phone,ID,count(ID) as num FROM Ens_Config.BusinessPartner  where Description like '%"_selVal_"%'"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		Set total=0
		if tResult.Next(){
						Set total=tResult.Get("num")
			   		}
		Set jsonObject.rows=dataArr
		Set jsonObject.total=total
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=$zcvt(jsonObject.%ToJSON(),"O","UTF8")
	}Catch(e){	
	  Set tSC=e.AsStatus()
	  $$$LOGERROR("XX错误* : "_tSC)
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
