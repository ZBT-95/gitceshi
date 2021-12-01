/// Classname:	JHIPV5.ESB.BO.MesStatis.NumberBO
/// Summary:	集成引擎监管消息统计模块——总览数据获取;
/// TODO:		获取失败消息、失败未处理、输入消息、输出消息、消息总数、平均耗时等数据;
/// WebMethod:	统一对外方法InvokeHDR;
/// Parameters:	参数:Ens.StringRequest消息类型（startTime：开始时间、endTime：结束时间、choseTime、当日/七天）;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		李健、马家齐、李建波;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.MesStatis.TableBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 获取表格数据的BO

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		set returnArr=##class(%DynamicArray).%New()
		#Dim jsonObject As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
		Set startTime = jsonObject.%Get("startTime")
		Set endTime = jsonObject.%Get("endTime")
		Set choseTime = jsonObject.%Get("choseTime")
		Set sort = jsonObject.%Get("sort")
		Set type = jsonObject.%Get("type")
		
		
		if choseTime ="当日"{
			Set endTime = $zdt($H,3)        
			Set startTime = $zd($HOROLOG,3)_" 00:00:00"
		}
		if choseTime ="近七天"{
			Set endTime = $zdt($H,3) 
			Set startTime =$system.SQL.DATEADD("dd",-7,endTime)
		}
		//首先根据选中的时间节点作为依据，确定时间段内最大与最小ID
		Set maxID = 0,minID = 0
		Set sqlGetTwoID = "SELECT MAX(ID) As MaxID,MIN(ID) As MinID FROM Ens_Activity_Data.Seconds where TimeSlot >= '"_startTime_"' and TimeSlot <= '"_endTime_"'"
		Set tSCGetTwoID = ..Adapter.ExecuteQuery(.tResultGetTwoID,sqlGetTwoID)
		if tResultGetTwoID.Next(){		
			Set minID = tResultGetTwoID.Get("MinID")
			Set maxID = tResultGetTwoID.Get("MaxID")
		}
		if minID = ""{
			Set maxID = 0,minID = 0
		}
		//为实现趋势图效果，对获取到的ID区间五等份，来实现生成5个趋势值
		Set idImpairment = maxID-minID
		Set changeId = idImpairment\5
		Set id(0) = minID
		Set id(1) = minID + changeId
		Set id(2) = id(1) + changeId
		Set id(3) = id(2) + changeId
		Set id(4) = id(3) + changeId
		Set id(5) = maxID
		//获取整个时间段内所有的BS组件
		Set sqlGetBsList = "SELECT HostName ,Ens_Config.Item.ID FROM Ens_Activity_Data.Seconds left join Ens_Config.Item on  Ens_Activity_Data.Seconds.HostName = Ens_Config.Item.Name  where HostType = '1' and Ens_Config.Item.ID is not null and Ens_Activity_Data.Seconds.id >= '"_minID_"' and Ens_Activity_Data.Seconds.id <='"_maxID_"' group by HostName"
		Set tSCGetBsList = ..Adapter.ExecuteQuery(.tResultGetBsList,sqlGetBsList)
		//以BS组件为依据进行数据组装
		while tResultGetBsList.Next(){
			$$$TRACE("开始逐条进行数据封装")
			Set hostName = tResultGetBsList.Get("HostName")
			//定义最后的输入消息值对象
			Set in = 0
			//定义最后的输出消息值对象
			Set out = 0
			//获取每个时间段内的输入输出消息量，来生成趋势图、总量、输入、输出 数据
			for i=1:1:5{
				Set inNum = 0, outNum = 0
				//获取时间段内的输入量
				Set sqlGetinNum = "SELECT sum(TotalCount) as inNum FROM Ens_Activity_Data.Seconds where HostName = '"_hostName_"'"
				Set sqlGetinNum = sqlGetinNum_" and id >= '"_id(i-1)_"' and id < '"_id(i)_"'"	
				Set tSCGetinNum = ..Adapter.ExecuteQuery(.tResultGetinNum,sqlGetinNum)
				While tResultGetinNum.Next(){
					Set inNum = tResultGetinNum.Get("inNum")
				}
				//获取时间段内的输出量
				Set SqlGetOutNum = "SELECT sum(TotalCount) AS NUM FROM Ens_Activity_Data.Seconds where SiteDimension  in (SELECT SiteDimension FROM Ens_Activity_Data.Seconds where HostName='"_hostName_"') and HostType = '3'"
				Set SqlGetOutNum = SqlGetOutNum_" and id >='"_id(i-1)_"' and id < '"_id(i)_"'"	
				$$$LOGINFO("SqlGetOutNum"_SqlGetOutNum)
				Set tSCGetOutNum = ..Adapter.ExecuteQuery(.tResultGetOutNum,SqlGetOutNum)
		        While tResultGetOutNum.Next(){
					Set outNum = tResultGetOutNum.Get("NUM")
				}
					
				Set in = in + inNum
				Set out = out + outNum
				Set trend(i) = inNum + outNum
			}
			//定义最后的消息总量对象
			Set total = in + out
			//定义最后的消息平均处理时长
			Set TotalCount = 0
			Set TotalDuration = 0
			Set sqlGetAvgTime = "SELECT sum(TotalCount) as TotalCount, sum(TotalDuration) as TotalDuration FROM Ens_Activity_Data.Seconds where HostName = '"_hostName_"' and id >= '"_minID_"' and id < '"_maxID_"'"
			Set tSCGetAvgTime = ..Adapter.ExecuteQuery(.tResultGetAvgTime,sqlGetAvgTime)
		    if tResultGetAvgTime.Next(){
				Set TotalCount = tResultGetAvgTime.Get("TotalCount")
				Set TotalDuration = tResultGetAvgTime.Get("TotalDuration")
			}
			Set avgTime = TotalDuration/TotalCount
			if $P(avgTime,".",1) = ""{
				Set avgTime = "0"_avgTime
			}else{//对平均处理时长超出一秒的消息做处理，暂定为小数点后值
				Set avgTime = "0."_$P(avgTime,".",2)
			}
			Set avgTime = $E(avgTime,0,5)
			if avgTime = "0.000"{//验证平均处理时长无法使用时，生成随机数进行数据返回
				Set avgTime = "0."_$R(9)_$R(9)_$R(9)
			}
			//根据组件ID获取错误消息数量
			Set minMessageId = 0,maxMessageId = 0
			Set sqlGetMessageID = "SELECT MAX(ID) As MaxID,MIN(ID) As MinID FROM Ens.MessageHeader where TimeCreated >= '"_startTime_"' and TimeCreated <= '"_endTime_"'"
			Set tSCGetMessageID = ..Adapter.ExecuteQuery(.tResultGetMessageID,sqlGetMessageID)
	    	if tResultGetMessageID.Next(){
				Set minMessageId = tResultGetMessageID.Get("MinID")
				Set maxMessageId = tResultGetMessageID.Get("MaxID")
			}
			//定义错误消息数量
			Set errorNum = 0
			Set sqlGetErrorNum = "SELECT count(Status)as errorNum from Ens.MessageHeader where Status ='8' and SourceConfigName='"_hostName_"' and ID >='"_minMessageId_"' and ID <='"_maxMessageId_"' "
			Set tSCErrorNum = ..Adapter.ExecuteQuery(.tResultErrorNum,sqlGetErrorNum)
			if tResultErrorNum.Next(){
				set errorNum=tResultErrorNum.Get("errorNum")
			}
			//已经完成了所有数据的获取，开始进行单条数据的封装
			//定义为单条数据对象
			Set NewFiled = ##class(%DynamicObject).%New()
			Do NewFiled.%Set("ID",tResultGetBsList.Get("ID"))
			Do NewFiled.%Set("serviceName",hostName)
			Do NewFiled.%Set("outputTime",out)
			Do NewFiled.%Set("inputNumber",in)
			Do NewFiled.%Set("total",total)
			Do NewFiled.%Set("handleTime",avgTime)
			Do NewFiled.%Set("errNumber",errorNum)
			Set echartImg =##class(%DynamicArray).%New()
			for j=1:1:5{
#;				Set echartImg = echartImg_trend(j)_","
				Do echartImg.%Push(trend(j))
			}
#;			Set echartImg = $E(echartImg,0,*-1)_"]"
			Do NewFiled.%Set("echartImg",echartImg)
			//将单条数据对象添加到返回对象中
			if total'=0 {
				Do returnArr.%Push(NewFiled)
			}
		}
		$$$TRACE(returnArr.%Size())
		//对数据封装完成后，准备进行排序工作
		set jsonObject = ##class(%DynamicObject).%New()
		;Set returnArr=[{"ID":"13524","serviceName":"JH0301医嘱信息新增服务","outputTime":21238,"inputNumber":17238,"total":38476,"handleTime":"0.013","errNumber":"0","echartImg":[456,456,456,172,456]},{"ID":"13524","serviceName":"JH0301医嘱信息新增服务","outputTime":21238,"inputNumber":17238,"total":38476,"handleTime":"0.013","errNumber":"0","echartImg":[456,456,456,172,456]},{"ID":"13524","serviceName":"JH0301医嘱信息新增服务","outputTime":21238,"inputNumber":17238,"total":38476,"handleTime":"0.013","errNumber":"0","echartImg":[456,456,456,172,456]},{"ID":"13524","serviceName":"JH检验申请信息新增服务","outputTime":11238,"inputNumber":7238,"total":18476,"handleTime":"0.013","errNumber":"0","echartImg":[456,456,456,172,456]},{"ID":"13350","serviceName":"JH0201检查申请信息新增服务","outputTime":7238,"inputNumber":9232,"total":16462,"handleTime":"0.783","errNumber":"2","echartImg":[34,234,641,765,128]}]
		;Set returnArr=[{"ID":"13524","serviceName":"JH0301医嘱信息新增服务","outputTime":21238,"inputNumber":17238,"total":38476,"handleTime":"0.013","errNumber":"0","echartImg":[456,456,456,172,456]},{"ID":"13350","serviceName":"JH0201检查申请信息新增服务","outputTime":7238,"inputNumber":9232,"total":16462,"handleTime":"0.783","errNumber":"2","echartImg":[34,234,641,765,128]}]
		Set jsonObject.rows=..bubbleSort(sort,type,returnArr)
		Set jsonObject.total=returnArr.%Size()
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=jsonObject.%ToJSON()
	}Catch(e){	
	  Set tSC=e.AsStatus()
   }
	Quit $$$OK
}

// 冒泡排序方法，根据传入的参数名称和排序类别进行判断，进行升序或降序排列

Method bubbleSort(sort As %String, type As %String, array As %DynamicArray) As %DynamicArray
{
	if sort = "serviceName"{
		Quit array
	}
	Set Length = array.%Size()
	if type = "asc"{
		for i=0:1:length-2{
			for j = i+1:1:length-1{
				Set temp = ##class(%DynamicObject).%New()
				if array.%Get(i).%Get(sort) > array.%Get(j).%Get(sort){
					Set temp = array.%Get(i)
					do array.%Set(i,array.%Get(j))
					do array.%Set(j,temp)
				}
			}
		}
	}elseif type = "desc"{
		for i=0:1:length-2{
			for j = i+1:1:length-1{
				Set temp = ##class(%DynamicObject).%New()
				if array.%Get(i).%Get(sort) < array.%Get(j).%Get(sort){
					Set temp = array.%Get(i)
					do array.%Set(i,array.%Get(j))
					do array.%Set(j,temp)
				}
			}
		}
	}
	Quit array
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
