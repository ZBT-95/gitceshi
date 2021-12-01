Class JHIPV5.ESB.BO.MesRretr.JHIP.MessageRetrievalBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 根据参数，获取表格信息BO

Method QueryMsg(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set jsonObject = ##class(%DynamicObject).%New()
	set dataArr = ##class(%DynamicArray).%New()
	set dataArrB = ##class(%DynamicArray).%New()
	set dataArrR = ##class(%DynamicArray).%New()
	set tStatement = ##class(%SQL.Statement).%New()
	set tStatement2 = ##class(%SQL.Statement).%New()
	Set pResponse=##Class(Ens.StringResponse).%New()
	try{
		Set tSC=$$$OK,countoto=0,sql="",sqlCount=""
		#Dim json As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set Number = json.%Get("number")
		Set Size = json.%Get("size")
		Set type = json.%Get("type")
		Set arName = json.%Get("value")
		Set arName=$ZCVT(arName,"O","UTF8")
		Set startTime = json.%Get("startTime")
		Set endTime = json.%Get("endTime")
		Set serverName = json.%Get("serverName")
		Set statusNumber = json.%Get("statusNumber")
		Set spaceType = json.%Get("spaceType")
		;Set ..Adapter.DSN=$S(1=spaceType:"JHIP",2=spaceType:"HII")
		If spaceType=1{
			DO ..Adapter.DSNSet("JHIP")
		}ElseIF spaceType=2{
			DO ..Adapter.DSNSet("HII")
		}
		Set PageTop = Size*(Number-1)+ 1
		Set PageButtom = Size * Number
		IF type = 0{
			//获取存在患者ID字段的SearchTable
			Set sql = "select distinct substring(parent,0,charindex('||',parent)) as ClassName FROM %Dictionary.CompiledStorageDataValue where  value = 'PatientID' and parent like 'JHIPLIB_SearchTable%'"
			Set sqlcode="PatientID"
		}ElseIF type = 1{
			//获取存在患者姓名字段的SearchTable
			Set sql = "select distinct substring(parent,0,charindex('||',parent)) as ClassName FROM %Dictionary.CompiledStorageDataValue where  value = 'PatientName' and parent like 'JHIPLIB_SearchTable%'"
			Set sqlcode="PatientName"
		}ElseIF type = 3{
			//申请单号
			Set sql = "select distinct substring(parent,0,charindex('||',parent)) as ClassName FROM %Dictionary.CompiledStorageDataValue where  value = 'ApplicationID' and parent like 'JHIPLIB_SearchTable%'"
			Set sqlcode="ApplicationID"
		}ElseIF type = 4{
			//医嘱号
			Set sql = "select distinct substring(parent,0,charindex('||',parent)) as ClassName FROM %Dictionary.CompiledStorageDataValue where  value = 'OrderID' and parent like 'JHIPLIB_SearchTable%'"
			Set sqlcode="OrderID"
		}
		ElseIF type = 5{
			//住院号
			Set sql = "select distinct substring(parent,0,charindex('||',parent)) as ClassName FROM %Dictionary.CompiledStorageDataValue where  value = 'HospitalizationID' and parent like 'JHIPLIB_SearchTable%'"
			Set sqlcode="HospitalizationID"
		}ElseIF type = 6{
			//门诊号
			Set sql = "select distinct substring(parent,0,charindex('||',parent)) as ClassName FROM %Dictionary.CompiledStorageDataValue where  value = 'OutpatientID' and parent like 'JHIPLIB_SearchTable%'"
			Set sqlcode="OutpatientID"
		}ElseIF type = 7{
			//字典内容
			Set sql = "select distinct substring(parent,0,charindex('||',parent)) as ClassName FROM %Dictionary.CompiledStorageDataValue where  value = 'Search1' and parent like 'JHIPLIB_SearchTable%'"
			Set sqlcode="Search1"
		}ElseIF type = 9{
			//其他信息
			Set sql = "select distinct substring(parent,0,charindex('||',parent)) as ClassName FROM %Dictionary.CompiledStorageDataValue where  value = 'Search1' and parent like 'JHIPLIB_SearchTable%'"
			Set sqlcode="Search1"
		}
		//通用Searchable
		IF (type '=2)&(type'= 8){
		 	Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	 		//遍历结果集并将分页查询显示SQL获取到的数据放至json
	 		WHILE tResult.Next(){
		 		Set ClassName=tResult.Get("ClassName")
		 		Set cName=$p(ClassName,".",*)
			 	Set table=$Translate($e(ClassName,0,*-$L(cName)-1),".","_")_"."_cName
			 	Set mysql="SELECT Type,SessionId, Status, SourceConfigName,max(TimeCreated) as ma,TimeCreated as mi FROM Ens.MessageHeader Where SessionId in (SELECT SessionId FROM Ens.MessageHeader WHERE MessageBodyId in (SELECT DocId FROM "_table_" WHERE "_sqlcode_"='"_arName_"'))and (TargetBusinessType='2') "
		 	   	IF startTime '= ""{
					Set mysql = mysql_"AND TimeCreated>='"_startTime_"' AND TimeCreated<='"_endTime_"'"
				}
				IF serverName '= ""{
					Set mysql = mysql_"AND SourceConfigName='"_serverName_"'"
				}
				IF statusNumber '= ""{
					Set mysql = mysql_"AND Status='"_statusNumber_"'"
				}
				Set mysql=mysql_"group by SessionId order by SessionId desc"
				Set tSC=..Adapter.ExecuteQuery(.tResult2,mysql)
				WHILE tResult2.Next(){
					Set countoto=countoto+1
					Set NewFiled = ##class(%DynamicObject).%New()
					Do NewFiled.%Set("ID",tResult2.Get("SessionId"))
				   	Do NewFiled.%Set("Status",tResult2.Get("Status"))
				   	Do NewFiled.%Set("SourceConfigName",tResult2.Get("SourceConfigName"))
				   	Do NewFiled.%Set("sourceSys","-")
				   	Do NewFiled.%Set("consumptionSys","-")
				   	Do NewFiled.%Set("TimeCreated",tResult2.Get("mi"))
					Do NewFiled.%Set("TimeEnd",tResult2.Get("ma"))
	    			Do NewFiled.%Set("spaceType",1)
					Set max=$TRanslate(tResult2.Get("ma"),"-, ,:")
					Set min=$TRanslate(tResult2.Get("mi"),"-, ,:")
					Do NewFiled.%Set("costTime",max-min)
					Do dataArr.%Push(NewFiled)
				}
	    	}
			//序列化json
	    	Set Low=Size*(Number-1)
	    	Set High=Size*Number-1
	    	FOR i=Low:1:High{
		    	if dataArr.%Get(i)'=""{
		    		Do dataArrB.%Push(dataArr.%Get(i))
		   		}
			}
			Set jsonObject.rows=dataArrB
			Set jsonObject.total=countoto
			Set jsonString=jsonObject.%ToJSON()
	    	Set pResponse.StringValue=jsonString
		}ElseIF type = 2{
			//服务获取
			Set sqlCount = "SELECT COUNT(SessionId) As TOTAL From (SELECT SessionId FROM Ens.MessageHeader WHERE  SourceConfigName = '"_arName_"'"
	    	Set sql="SELECT %VID AS ContentID ,* FROM (SELECT SessionId, Status, SourceConfigName, TimeCreated as mi from Ens.MessageHeader where Ens.MessageHeader.ID in (SELECT ID FROM Ens.MessageHeader l where SourceConfigName = '"_arName_"' GROUP BY l.SessionId ))"
			IF startTime '= ""{
				Set sqlCount = sqlCount_"AND TimeCreated>='"_startTime_"' AND TimeCreated<='"_endTime_"'"
				Set sql = sql_"AND TimeCreated>='"_startTime_"' AND TimeCreated<='"_endTime_"'"
			}
			IF statusNumber '= ""{
				Set sqlCount = sqlCount_"AND Status='"_statusNumber_"'"
				Set sql = sql_"AND Status='"_statusNumber_"'"
			}
			IF serverName '= ""{
				Set sqlCount = sqlCount_"AND SourceConfigName='"_serverName_"'"
			}
			Set sqlCount =sqlCount_")"
			DO ..GetBySerName(sqlCount,Size,Number,.tResp,sql)
			Set jsonObject=tResp
		}ElseIF type = 8{
			Set mysql="SELECT Type,SessionId, Status, SourceConfigName,max(TimeCreated) as ma,TimeCreated as mi FROM Ens.MessageHeader Where SessionId ='"_arName_"'"
		 	DO ..GetBySessionID(mysql,Size,Number,.tResp)
		 	//序列化json
	    	Set jsonObject=tResp
	    }
		Set jsonObject.url="http://192.168.100.69:57772/SOAP/EnsPortal.VisualTrace.zen?SESSIONID="
		Set pResponse.StringValue=jsonObject.%ToJSON()
	}Catch(ex){
		Set pResponse="失败内容："_ex.DisplayString()
		Set tSC=ex.AsStatus()
			
	}
	Quit $$$OK
}

// 根据会话ID获取消息

Method GetBySessionID(pRequest As %String, Size As %String, Number As %String, Output pResponse As %RegisteredObject) As %Status
{
	$$$LOGINFO("mysql->"_pRequest)
	Set countoto=0
	set jsonObject = ##class(%DynamicObject).%New()
	set dataArr = ##class(%DynamicArray).%New()
	set dataArrB = ##class(%DynamicArray).%New()
	Set tSC=..Adapter.ExecuteQuery(.tResult2,pRequest)
	WHILE tResult2.Next(){
		Set countoto=countoto+1
	 	Set NewFiled = ##class(%DynamicObject).%New()
	 	Do NewFiled.%Set("ID",tResult2.Get("SessionId"))
	    Do NewFiled.%Set("Status",tResult2.Get("Status"))
	    Do NewFiled.%Set("SourceConfigName",tResult2.Get("SourceConfigName")_"_"_tResult2.Get("Type"))
	   	;Do NewFiled.%Set("sourceSys","-")
	    ;Do NewFiled.%Set("consumptionSys","-")
	    Do NewFiled.%Set("TimeCreated",tResult2.Get("mi"))
	    Do NewFiled.%Set("TimeEnd",tResult2.Get("ma"))
		Do NewFiled.%Set("spaceType",1)
	 	Set max=$TRanslate(tResult2.Get("ma"),"-, ,:")
		Set min=$TRanslate(tResult2.Get("mi"),"-, ,:")
		Do NewFiled.%Set("costTime",max-min)
		Do dataArr.%Push(NewFiled)
	}
	//序列化json
	Set Low=Size*(Number-1)
	Set High=Size*Number-1
	FOR i=Low:1:High{
	   	if dataArr.%Get(i)'=""{
	   		Do dataArrB.%Push(dataArr.%Get(i))
		}
	}
	Set jsonObject.rows=dataArrB
	Set jsonObject.total=countoto
	Set pResponse=jsonObject
	Quit $$$OK
}

// 根据服务名称获取消息

Method GetBySerName(pRequest As %String, Size As %String, Number As %String, Output pResponse As %DynamicObject, ByRef pHint As %String) As %Status
{
	//执行记总数SQL
	Set sql=pHint,total=0,count=0
	set jsonObject = ##class(%DynamicObject).%New()
	set dataArr = ##class(%DynamicArray).%New()
	Set tSC=..Adapter.ExecuteQuery(.tResultTotal,pRequest)
	WHILE tResultTotal.Next(){
	   	Set total = tResultTotal.Get("TOTAL")
	}
	$$$LOGINFO("total->"_total_":"_Size_":"_Number)
	Set count=total\Size+1
	Set PageTop = total-(Size * Number)+1
	Set PageButtom = total-(Size * (Number-1))
	Set sql = sql_" WHERE %VID BETWEEN "_PageTop_" AND "_PageButtom_""
	$$$LOGINFO(sql)
	Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	//遍历结果集并将分页查询显示SQL获取到的数据放至json
	WHILE tResult.Next(){
		Set NewFiled = ##class(%DynamicObject).%New()
	   	Do NewFiled.%Set("ID",tResult.Get("SessionId"))
	   	Do NewFiled.%Set("Status",tResult.Get("Status"))
	   	Do NewFiled.%Set("SourceConfigName",tResult.Get("SourceConfigName"))
	   	Do NewFiled.%Set("TimeCreated",tResult.Get("mi"))
	   	Set SessionIdR=tResult.Get("SessionId")
	    Set sqlr="SELECT  top 1 id ,TimeCreated as ma from Ens.MessageHeader where SessionId ='"_SessionIdR_"' order by id desc"
	    Set tSC=..Adapter.ExecuteQuery(.tResultr,sqlr)
	    WHILE tResultr.Next(){
		    Set max=$TRanslate(tResultr.%Get("ma"),"-, ,:")
	   		Set min=$TRanslate(tResult.%Get("mi"),"-, ,:")
	   		Do NewFiled.%Set("TimeEnd",tResultr.Get("ma"))
	   		Do NewFiled.%Set("costTime",max-min)
	   		Do NewFiled.%Set("spaceType",1)
	    	Do dataArr.%Push(NewFiled)
		}
	}
	Set jsonObject.rows=dataArr
	Set jsonObject.total=total
	Set pResponse=jsonObject
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>QueryMsg</Method>
	</MapItem>
</MapItems>
}

}
