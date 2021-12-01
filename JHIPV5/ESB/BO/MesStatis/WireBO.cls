/// Classname:	JHIPV5.ESB.BO.MesStatis.WireBO
/// Summary:	集成引擎监管消息统计模块——获取吞吐量折线图数据获取;
/// TODO:		获取输入消息、输出消息、消息总数等数据;
/// WebMethod:	统一对外方法InvokeHDR;
/// Parameters:	参数:Ens.StringRequest消息类型（startTime：开始时间、endTime：结束时间、choseTime、当日/七天）;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		李健、马家齐、李建波;
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.BO.MesStatis.WireBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 获取折线图的BO

Method QueryData(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	set returnOb=##class(%DynamicObject).%New()
	set resulttotalArr=##class(%DynamicArray).%New()
	set resultInArr=##class(%DynamicArray).%New()
	set resultOutArr=##class(%DynamicArray).%New()
	set chazhiArr=##class(%DynamicArray).%New()
	set resultTime=##class(%DynamicArray).%New()
	#Dim jsonObject As %DynamicObject =##class(%DynamicObject).%FromJSON(pRequest.StringValue)
	Set startTime = jsonObject.%Get("startTime")
	Set endTime = jsonObject.%Get("endTime")
	Set choseTime = jsonObject.%Get("choseTime")
	if choseTime ="当日"{
			Set endTime = $zdt($H,3)        
			Set startTime = $zd($HOROLOG,3)_" 00:00:00"
		}ElseIF choseTime ="近七天"{
		   	Set endTime = $zdt($H,3)        
			Set startTime =$system.SQL.DATEADD("dd",-7,endTime)
		}
	//查询当日平台内部生成消息数量
	IF startTime '= ""{//添加时间作为筛选条件时
		Set startday1 = $P(startTime," ",1)
		Set startday = $P(startday1,"-",2)_"/"_$P(startday1,"-",3)_"/"_$P(startday1,"-",1)
		Set endday1 = $P(endTime," ",1)
		Set endday = $P(endday1,"-",2)_"/"_$P(endday1,"-",3)_"/"_$P(endday1,"-",1)
		set datelength=$ZDATEH(endday)-$ZDATEH(startday)+2	   	
		$$$TRACE(datelength)	
		if datelength=2{// 判断选中的开始时间与结束时间为一天时，返回选中当日的所有数据
			Set day = startday1
			Set time = day_" 23:59:59" 
			set day=day_" 00:00:00"
			Set time = startday1
			set a(1)=time_" 00:00:00"
			set a(2)=time_" 04:00:00"
			set a(3)=time_" 08:00:00"
			set a(4)=time_" 12:00:00"
			set a(5)=time_" 16:00:00"
			set a(6)=time_" 20:00:00"
			set a(7)=time_" 23:59:59"
			$$$TRACE(a(7))
			set datelength=7
			Do resultTime.%Push(a(1))
	     	Do resultTime.%Push(a(2))
	    	Do resultTime.%Push(a(3))
	   		Do resultTime.%Push(a(4))
	    	Do resultTime.%Push(a(5))
	   		Do resultTime.%Push(a(6))
	   		Do resultTime.%Push(a(7))
		}else{
			for i=0:1:datelength-1{
				set a(i+1)=$system.SQL.DATEADD("dd",+i,startday) 
			}
			for i=0:1:datelength-2{
				Do resultTime.%Push($p(a(i+1)," ",1))	   		
			}
			set day =startday1
			set time =endday1
		}
				
	}else{//进入页面初始化时默认返回当日数据
		Set day = $zd($H,3) 
		Set time = day_" 23:59:59" 
		set day=day_" 00:00:00"
		Set time = $zd($H,3) 
		set a(1)=time_" 00:00:00"
		set a(2)=time_" 04:00:00"
		set a(3)=time_" 08:00:00"
		set a(4)=time_" 12:00:00"
		set a(5)=time_" 16:00:00"
		set a(6)=time_" 20:00:00"
		set a(7)=time_" 23:59:59"
		Do resultTime.%Push(a(1))
		Do resultTime.%Push(a(2))
		Do resultTime.%Push(a(3))
		Do resultTime.%Push(a(4))
	 	Do resultTime.%Push(a(5))
		Do resultTime.%Push(a(6))
		Do resultTime.%Push(a(7))
		set datelength=7
	}
	//确定要返回的数据时间段后，开始为每个时间段进行数据补充
	set returnArr=##class(%DynamicArray).%New()
	$$$TRACE(datelength)
	if ( startTime = "")||(datelength=2){
		Do resulttotalArr.%Push(0)
		Do resultInArr.%Push(0)
		Do resultOutArr.%Push(0)
	}
	for i=1:1:datelength-1{
		Set Time = a(i) 
		Set Timeend = a(i+1) 
		//查询时间段内吞量
		set queryIn="SELECT sum(TotalCount) as inNum FROM Ens_Activity_Data.Seconds where HostType = '1' and TimeSlot>'"_Time_"' and TimeSlot<'"_Timeend_"'"
#;		$$$LOGINFO("sql:"_queryIn)
		Set tSC = ..Adapter.ExecuteQuery(.tResult,queryIn)
	 
  	 	set in(i)=0 
		if (tResult.Next()){
			set in(i)=tResult.Get("inNum")
		}
		if in(i)+0=0 {
			Do resultInArr.%Push("0")
		}else{
			Do resultInArr.%Push(in(i)+0)
		}
		//根据id查询消息量
     	set OutNum(i)=0
		Set SqlGetOutMessageNum = "SELECT sum(TotalCount) AS NUM FROM Ens_Activity_Data.Seconds where HostType = '3' and TimeSlot>'"_Time_"' and TimeSlot<'"_Timeend_"'"
#;		$$$LOGINFO("id查询消息量sql:"_SqlGetOutMessageNum)
		Set tSCGetOutMessageNum = ..Adapter.ExecuteQuery(.tResultGetOutMessageNum,SqlGetOutMessageNum)
		if tSCGetOutMessageNum{
			if tResultGetOutMessageNum.Next(){
				set OutNum(i)=tResultGetOutMessageNum.Get("NUM")+0
			 	;set OutNum(i)=$P(OutNum(i)/2,".",1)+0
	    	}
		}
		if OutNum(i)=0 {
			Do resultOutArr.%Push("0")
		}else{
			Do resultOutArr.%Push(OutNum(i))
		}
		if in(i)+OutNum(i)+0=0 {
			Do resulttotalArr.%Push("0")
		}else{
			Do resulttotalArr.%Push(in(i)+OutNum(i)+0)
		}
	}
	set returnOb.Xdata=resultTime
	;Set resulttotalArr=["10000", "24323", "254448", "220675", "208283", "34237","15654"]
	;Set resultInArr=["5000", "12111", "122244", "100032", "104141", "12113","7125"]
	;Set resultOutArr=["5800", "18111", "162244", "120332", "114141", "17113","8825"]
	
	set returnOb.totalData=resulttotalArr
	set returnOb.inputData=resultInArr
 	set returnOb.outputData=resultOutArr
	Set pResponse=##class(Ens.StringResponse).%New()
	Set pResponse.StringValue=$zcvt(returnOb.%ToJSON(),"O","UTF8")
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
