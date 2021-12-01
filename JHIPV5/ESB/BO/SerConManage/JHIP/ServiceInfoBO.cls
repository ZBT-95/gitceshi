Class JHIPV5.ESB.BO.SerConManage.JHIP.ServiceInfoBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第七个接口/// Summary:	获取表格内容
/// TODO:		将交互服务中的服务，按照不同属性，显示在表格中;	同时实现分页、模糊查询
/// Parameters:		参数1：number 页面显示的页数，默认1
/// 				参数2：size 每个页面显示的行数，默认20
/// 				参数3：service 集成场景选项搜索，默认0
/// 				参数4：name 服务名称搜索，默认空
/// 				参数5：release 发布状态选项搜索，默认100
/// 				参数6：custom 内外置服务选项搜索，默认0
/// Response:	json对象：{"rows":[{"Name":"","Category":"","PoolSize":"","Enabled":"","LogTraceEvents":"","Comment":"","id":"","新加属性":""...},...], "total": ""}; 
/// 				rows:json数组;Name:服务名称;Category:集成场景;PoolSize:运行池;Enabled:启用状态;LogTraceEvents:日志开启状态;Comment:内外置;id:数据库中的服务编号id;total: 所有页面共展示的服务总数
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set MyString=pRequest.StringValue
		Set Number= $PIECE(MyString,"@",1)
		Set Size= $PIECE(MyString,"@",2)
		Set Service = $PIECE(MyString,"@",3)
		Set arName = $PIECE(MyString,"@",4)
		Set Release = $PIECE(MyString,"@",5)
		Set Custom = $PIECE(MyString,"@",6)
		
		Set PageTop = Size*(Number-1)+ 1
		Set PageButtom = Size * Number
		IF Custom = 1{
			Set Custom = "内置"
		}ELSEIF Custom = 2{
			Set Custom = "外置"
		}
			Set tSC=$$$OK
			set jsonObject = ##class(%DynamicObject).%New()
			set dataArr = ##class(%DynamicArray).%New()
			set dataArrB = ##class(%DynamicArray).%New()
			set tStatement = ##class(%SQL.Statement).%New()
			//分页查询SQL
			Set sql = "SELECT DISTINCT  TOP ALL Ens_Config.Item.ID, Name, ClassName, Category, PoolSize, Enabled, LogTraceEvents, Comment FROM Ens_Config.Item LEFT JOIN HII_ALL_DB.TableFieldDB ON Ens_Config.Item.NAME = HII_ALL_DB.TableFieldDB.SerName WHERE ClassName LIKE '%BS%'  "		
			//根据输入的json动态拼接SQL语句的WHERE条件
			IF Service '= 0{
				Set sql = sql_"AND Category LIKE '%"_Service_".%'"
				}
			IF $L(arName) '= 0 {
				Set sql = sql_" AND Name LIKE "_"'%"_arName_"%'"
				}
			IF Release '= 100{
				Set sql = sql_" AND Enabled = "_"'"_Release_"'"
				}
			IF Custom '= 0{
				Set sql = sql_" AND Comment = "_"'"_Custom_"'"
				}	
			Set sql = sql_"ORDER BY Name "
			$$$TRACE(sql)
			//记总数SQL
			Set sqlCount = "SELECT COUNT(*) As TOTAL FROM (SELECT %VID AS ContentID ,* FROM(SELECT DISTINCT Ens_Config.Item.ID, Name, ClassName, Category, PoolSize, Enabled, LogTraceEvents, Comment FROM Ens_Config.Item LEFT JOIN HII_ALL_DB.TableFieldDB ON Ens_Config.Item.NAME = HII_ALL_DB.TableFieldDB.SerName WHERE ClassName LIKE '%BS%' "	
			//根据输入的json动态拼接SQL语句的WHERE条件
			IF Service '= 0{
				Set sqlCount = sqlCount_"AND Category LIKE '%"_Service_".%'"
				}
			IF $L(arName) '= 0 {
				Set sqlCount = sqlCount_" AND Name LIKE "_"'%"_arName_"%'"
				}
			IF Release '= 100{
				Set sqlCount = sqlCount_" AND Enabled = "_"'"_Release_"'"
				}
			IF Custom '= 0{
				Set sqlCount = sqlCount_" AND Comment = "_"'"_Custom_"'"
				}	
			Set sqlCount = sqlCount_"))"
			//执行分页查询显示SQL
			;set tSC = tStatement.%Prepare(sql)
	 		;set tResult = tStatement.%Execute()
	 		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
	 		//遍历结果集并将分页查询显示SQL获取到的数据放至json
	 		$$$LOGINFO("sql"_sql)
	 		$$$LOGINFO("tResult"_tResult)
	 		Set ClassName=""
	 		WHILE tResult.Next(){
		    	Set NewFiled = ##class(%DynamicObject).%New()
		    	Set ServiceName=tResult.%Get("Name")
		    	set ceshi=..businesspartner(ServiceName)
		    	Set sql2 ="SELECT ClassName from Ens_Config.Item where name='"_ceshi_"'"
		    	Set tSC2=..Adapter.ExecuteQuery(.tResult2,sql2)
		    	WHILE tResult2.Next(){
			    	Set ClassName=tResult2.%Get("ClassName")
			    	}
		    	Do NewFiled.%Set("Name",ServiceName)
		    	Do NewFiled.%Set("ClassName",ClassName)
	    		Do NewFiled.%Set("Category",tResult.%Get("Category"))
	    		Do NewFiled.%Set("PoolSize",tResult.%Get("PoolSize"))
	    		Do NewFiled.%Set("Enabled",tResult.%Get("Enabled"))
	    		Do NewFiled.%Set("LogTraceEvents",tResult.%Get("LogTraceEvents"))
	    		Do NewFiled.%Set("Comment",tResult.%Get("Comment"))
	    		Do NewFiled.%Set("id",tResult.%Get("ID"))
	    		Do NewFiled.%Set("spaceType",1)
	    		Do NewFiled.%Set("isSync",..getSync(tResult.%Get("ID"),ServiceName))
	    		//在每条结果中单独查询新加属性的数据
	    		Set SqlField = "SELECT DISTINCT CodeValue,(%EXACT(FieldCode))FieldCode FROM HII_ALL_DB.TableFieldDB  WHERE SerName = '"_ServiceName_"'"
	    		;Set tSC = tStatement.%Prepare(SqlField)
		    	;Set tResultField = tStatement.%Execute()
		    	Set tSC=..Adapter.ExecuteQuery(.tResultField,SqlField)
		    	WHILE tResultField.Next(){
		    		Do NewFiled.%Set(tResultField.%Get("FieldCode"),tResultField.%Get("CodeValue"))
		   		}
		   		Do dataArr.%Push(NewFiled)
	    	}
	    	//执行记总数SQL
	    	;set tSC = tStatement.%Prepare(sqlCount)
	 		;set tResultTotal = tStatement.%Execute()
	 		Set tSC=..Adapter.ExecuteQuery(.tResultTotal,sqlCount)
	    	WHILE tResultTotal.Next(){
		    	Set total = tResultTotal.%Get("TOTAL")
		    }
		    //序列化json
		    //序列化json
	    	Set Low=Size*(Number-1)
	    	Set High=Size*Number-1
	    	FOR i=Low:1:High{
		    	if dataArr.%Get(i)'=""{
		    		Do dataArrB.%Push(dataArr.%Get(i))
		    	}
		    }
		    Set jsonObject.rows=dataArrB
		    Set jsonObject.total=total_""
	    	Set jsonString=jsonObject.%ToJSON()
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=$zcvt(jsonString,"O","UTF8")
	}Catch(e){	
	  Set tSC=e.AsStatus()
   }
	Quit $$$OK
}

Method businesspartner(ConfigNames As %String) As %String
{
	Set outPut = ""
	Set xSettings =""
	Set tFoundItems(1)=""
	set sqlStrOne = "Select $List(Settings,1,20) as xSettings from Ens_Config.Item where Name = '"_ConfigNames_"' and Production ='JHIP.Production.JHIPV3'"
	Set tSC = ..Adapter.ExecuteQuery(.tResult,sqlStrOne)
	//Set tProductionName = "JHIP.Production.JHIPV3"
	Set pSettingName = "TargetConfigNames"
	if tResult.Next(){
		Set xSettings = tResult.Get("xSettings")
		Set tFoundItems(1)=xSettings
	}
	Set tPref=$O(tFoundItems(""),1,tFoundSettings) 
	Set pSettingsList = tFoundSettings
	$$$LOGINFO("pSettingsList"_pSettingsList)
	For i=$LL(pSettingsList):-1:1{
		Set tSetting=$LG($LI(pSettingsList,i))
		$$$LOGINFO("tSetting"_tSetting)
		if ($LI(tSetting,1) = pSettingName){
			Set outPut = $LI(tSetting,3)
			quit
		}
	}
	quit outPut
}

Method getSync(id As %String, name As %String) As %String
{
	Set outPut = ""
	Set xSettings =""
	Set tFoundItems(1)=""
	set sqlStrOne = "Select $List(Settings,1,20) as xSettings from Ens_Config.Item where ID = '"_id_"'"
	Set tSC = ..Adapter.ExecuteQuery(.tResult,sqlStrOne)
	//Set tProductionName = "JHIP.Production.JHIPV3"
	Set pSettingName = "IsSync"
	if tResult.Next(){
		Set xSettings = tResult.Get("xSettings")
		Set tFoundItems(1)=xSettings
	}
	Set tPref=$O(tFoundItems(""),1,tFoundSettings) 
	Set pSettingsList = tFoundSettings
	For i=$LL(pSettingsList):-1:1{
		Set tSetting=$LG($LI(pSettingsList,i))
		if ($LI(tSetting,1) = pSettingName){
			Set outPut = $LI(tSetting,3)
			quit
		}
	}
	if outPut = ""{
		if $L(name,"查询")>1{
			Set outPut = 1
		}else{
			Set outPut = 0
		}
	}
	if outPut = 1
	{
		Quit "同步"
	}else{
		Quit "异步"
	}
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
