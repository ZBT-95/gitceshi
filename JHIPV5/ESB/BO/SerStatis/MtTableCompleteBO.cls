Class JHIPV5.ESB.BO.SerStatis.MtTableCompleteBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 创建表MtTableComplete的BO

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
	Set MyString=pRequest.StringValue
	set jsonObject = ##class(%DynamicObject).%New()
	set totalArr=##class(%DynamicArray).%New()
	set nameArr=##class(%DynamicArray).%New()
	set tStatement = ##class(%SQL.Statement).%New()
	//查询所有服务
	Set sqlName="SELECT Name,Category,Settings,ClassName FROM Ens_Config.Item where Name in(SELECT Name FROM Ens_Config.Item where ClassName in(SELECT ID FROM %Dictionary.CompiledClass where PrimarySuper like '%Ens.BusinessService%'))"
	Set tSC=..Adapter.ExecuteQuery(.tResult,sqlName)
	Set name=""
	WHILE tResult.Next(){
          Set ServiceName=tResult.Get("Name")
          Set Category=tResult.Get("Category")
          Set ServiceType= $PIECE(Category,",",1)
          Set Scope= $PIECE(Category,",",2)
          if Scope'="PX"{
          Set ClassName=tResult.Get("ClassName")
          Set AccessWay= $PIECE(ClassName,".",2)
          if AccessWay'="SOAP"{
	          if AccessWay'="HTTP"{
	          	Set AccessWay= $PIECE(ClassName,".",3)
	          }
	          }
          set Publish=..businesspartner(ServiceName)
          Set sqlName2="SELECT  Name FROM Ens_Config.Item where Category like '%"_ServiceType_"%' and Name like '%BO%'"
		  Set tSC2=..Adapter.ExecuteQuery(.tResult2,sqlName2)
		  Set sqlName4="SELECT  count(Name) as num FROM Ens_Config.Item where Category like '%"_ServiceType_"%' and Name like '%BO%'"
		  Set tSC4=..Adapter.ExecuteQuery(.tResult4,sqlName4)
		  Set num=0
		  WHILE tResult4.Next(){
			  	Set num=tResult4.Get("num")
			  }
		  if num'=0{
			  WHILE tResult2.Next(){
			    $$$LOGINFO("1111="_tResult2.Get("Name"))
			    Set Settings=tResult2.Get("Name")
			    $$$LOGINFO("2222="_Settings)
			    set Subscribe=..businesspartner(Settings)
			    if Subscribe=" "{
				    set Subscribe=""
				    }
			    if Publish'=""{
				    if Scope'="PX"{
					    if Subscribe'=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,Publish,ServiceName,ServiceType,Subscribe,AccessWay,Scope) values('"_Settings_"','"_Publish_"','"_ServiceName_"','"_ServiceType_"','"_Subscribe_"','"_AccessWay_"','"_Scope_"')"
					    	}
					    }
					if Scope'="PX"{
					    if Subscribe=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,Publish,ServiceName,ServiceType,AccessWay,Scope) values('"_Settings_"','"_Publish_"','"_ServiceName_"','"_ServiceType_"','"_AccessWay_"','"_Scope_"')"
					    	}
					    }
				}
				if Publish=""{
				    if Scope'="PX"{
					    if Subscribe'=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,ServiceName,ServiceType,Subscribe,AccessWay,Scope) values('"_Settings_"','"_ServiceName_"','"_ServiceType_"','"_Subscribe_"','"_AccessWay_"','"_Scope_"')"
					    	}
					    }
					if Scope'="PX"{
					    if Subscribe=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,ServiceName,ServiceType,AccessWay,Scope) values('"_Settings_"','"_ServiceName_"','"_ServiceType_"','"_AccessWay_"','"_Scope_"')"
					    	}
					    }
				}
				
			    Set tSC3=..Adapter.ExecuteQuery(.tResult3,sqlName3)
			  }
		  }
			  if num=0{
			    Set Settings=tResult2.Get("Name")
			    set Subscribe=..businesspartner(Settings)
			    if Subscribe=" "{
				    set Subscribe=""
				    }
			    if Publish'=""{
				    if Scope'=""{
					    if Subscribe'=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,Publish,ServiceName,ServiceType,Subscribe,AccessWay,Scope) values('"_Settings_"','"_Publish_"','"_ServiceName_"','"_ServiceType_"','"_Subscribe_"','"_AccessWay_"','"_Scope_"')"
					    	}
					    }
					if Scope'=""{
					    if Subscribe=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,Publish,ServiceName,ServiceType,AccessWay,Scope) values('"_Settings_"','"_Publish_"','"_ServiceName_"','"_ServiceType_"','"_AccessWay_"','"_Scope_"')"
					    	}
					    }
					if Scope=""{
					    if Subscribe'=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,Publish,ServiceName,ServiceType,Subscribe,AccessWay) values('"_Settings_"','"_Publish_"','"_ServiceName_"','"_ServiceType_"','"_Subscribe_"','"_AccessWay_"')"
					    	}
					    }
					if Scope=""{
					    if Subscribe=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,Publish,ServiceName,ServiceType,AccessWay) values('"_Settings_"','"_Publish_"','"_ServiceName_"','"_ServiceType_"','"_AccessWay_"')"
					    	}
					    }
				}
				if Publish=""{
				    if Scope'=""{
					    if Subscribe'=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,ServiceName,ServiceType,Subscribe,AccessWay,Scope) values('"_Settings_"','"_ServiceName_"','"_ServiceType_"','"_Subscribe_"','"_AccessWay_"','"_Scope_"')"
					    	}
					    }
					if Scope'=""{
					    if Subscribe=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,ServiceName,ServiceType,AccessWay,Scope) values('"_Settings_"','"_ServiceName_"','"_ServiceType_"','"_AccessWay_"','"_Scope_"')"
					    	}
					    }
					if Scope=""{
					    if Subscribe'=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,ServiceName,ServiceType,Subscribe,AccessWay) values('"_Settings_"','"_ServiceName_"','"_ServiceType_"','"_Subscribe_"','"_AccessWay_"')"
					    	}
					    }
					if Scope=""{
					    if Subscribe=""{
					   		 Set sqlName3="insert into HIPPSer_MSG.MtTableComplete(TargetName,ServiceName,ServiceType,AccessWay) values('"_Settings_"','"_ServiceName_"','"_ServiceType_"','"_AccessWay_"')"
					    	}
					    }
			  	}
			  	Set tSC3=..Adapter.ExecuteQuery(.tResult3,sqlName3)
			  }
			  }
          }
		
	Set pResponse=##class(Ens.StringResponse).%New()
	Set pResponse.StringValue=$zcvt(jsonObject.%ToJSON(),"O","UTF8")
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
	Set pSettingName = "BusinessPartner"
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
	
	quit outPut
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
