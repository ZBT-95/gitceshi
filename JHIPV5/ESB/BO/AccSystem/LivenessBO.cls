Class JHIPV5.ESB.BO.AccSystem.LivenessBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 第二个获取活跃度
Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		;Set time = $zdt($H,3)
		;Set day =$system.SQL.DATEADD("dd",-7,time) 
		Set day ="2019-07-25 17:26:04.500"
		Set time ="2021-07-25 17:26:04.500"
		set jsonObject = ##class(%DynamicObject).%New()
		set dataArr=##class(%DynamicArray).%New()
		set dataArrB=##class(%DynamicArray).%New()
		set dataArrC=##class(%DynamicArray).%New()
		set dataArrD=##class(%DynamicArray).%New()
		//系统数
		Set sql="select distinct Publish FROM HIPPSer_MSG.MtTable "
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
		    	Set Publish = tResult.Get("Publish")
		    	Set sql2="SELECT count(ID) as num FROM Ens.MessageHeader where TimeCreated >= '"_day_"' and TimeCreated <= '"_time_"' and SourceConfigName in(select distinct ServiceName FROM HIPPSer_MSG.MtTable where Publish='"_Publish_"')"
		   		Set tSC2=..Adapter.ExecuteQuery(.tResult2,sql2)
		   		if tResult2.Next(){
			   			Set NewFiled = ##class(%DynamicObject).%New()
						Do NewFiled.%Set("name",Publish)
						Do NewFiled.%Set("value",tResult2.Get("num"))
						if tResult2.Get("num")'=0{
								Do dataArr.%Push(NewFiled)
							}
			   		}
		    }
	  //冒泡排序，消息总量降序
	    	FOR i=0:1:dataArr.%Size()-2{
	      		FOR j=0:1:dataArr.%Size()-2-i{
	       			Set time1=dataArr.%Get(j).%Get("value")
	       			Set time2=dataArr.%Get(j+1).%Get("value")
	      			 IF time1<time2{
	       				 Set temp=dataArr.%Get(j)
	       				 Do dataArr.%Set(j,dataArr.%Get(j+1))
	       				 Do dataArr.%Set(j+1,temp)
	      				 }
	    		  }
	   		  }
	   	if dataArr.%Size()>5{
			   	FOR i=0:1:5{
			    	if dataArr.%Get(i)'=""{
			    		Do dataArrB.%Push(dataArr.%Get(i))
			    	}
			    }
		   	}else{
			   	FOR i=0:1:dataArr.%Size(){
			    	if dataArr.%Get(i)'=""{
			    		Do dataArrB.%Push(dataArr.%Get(i))
			    	}
			    }
			   	}
			//厂商数
		Set sql="SELECT distinct substring(Description,1,charindex(':',Description)-1) as ClassName FROM Ens_Config.BusinessPartner"
		Set tSC=..Adapter.ExecuteQuery(.tResult,sql)
		WHILE tResult.Next(){
				Set ClassName = tResult.Get("ClassName")
				Set sql2="SELECT count(ID) as num FROM Ens.MessageHeader where TimeCreated >= '"_day_"' and TimeCreated <= '"_time_"' and SourceConfigName in(select distinct ServiceName FROM HIPPSer_MSG.MtTable where Publish in(SELECT ID FROM Ens_Config.BusinessPartner where Description like '"_ClassName_"%'))"
				Set tSC2=..Adapter.ExecuteQuery(.tResult2,sql2)
		   		if tResult2.Next(){
			   			Set NewFiled = ##class(%DynamicObject).%New()
						Do NewFiled.%Set("name",ClassName)
						Do NewFiled.%Set("value",tResult2.Get("num"))
						if tResult2.Get("num")'=0{
								Do dataArrC.%Push(NewFiled)
							}
			   		}
			}
		  //冒泡排序，消息总量降序
	    	FOR i=0:1:dataArrC.%Size()-2{
	      		FOR j=0:1:dataArrC.%Size()-2-i{
	       			Set time1=dataArrC.%Get(j).%Get("value")
	       			Set time2=dataArrC.%Get(j+1).%Get("value")
	      			 IF time1<time2{
	       				 Set temp=dataArrC.%Get(j)
	       				 Do dataArrC.%Set(j,dataArrC.%Get(j+1))
	       				 Do dataArrC.%Set(j+1,temp)
	      				 }
	    		  }
	   		  }
	#;   	if dataArrC.%Size()>5{
	#;		   	FOR i=0:1:5{
	#;		    	if dataArrC.%Get(i)'=""{
	#;		    		Do dataArrD.%Push(dataArrC.%Get(i))
	#;		    	}
	#;		    }
	#;	   	}else{
	#;		   	FOR i=0:1:dataArrC.%Size(){
	#;		    	if dataArrC.%Get(i)'=""{
	#;		    		Do dataArrD.%Push(dataArrC.%Get(i))
	#;		    	}
	#;		    }
	#;		   	}
	   	Set jsonObject.manufacturerData=dataArrC 	
	   	Set jsonObject.sysData=dataArrB
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=$zcvt(jsonObject.%ToJSON(),"O","UTF8")
	}Catch(e){	
	  Set tSC=e.AsStatus()
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
