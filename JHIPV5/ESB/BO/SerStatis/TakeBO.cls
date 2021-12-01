Class JHIPV5.ESB.BO.SerStatis.TakeBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 第五个，服务订阅

Method InvokeHDR(pRequest As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	try{
		Set name=pRequest.StringValue
		set jsonObject = ##class(%DynamicObject).%New()
		set totalArr=##class(%DynamicArray).%New()
		set nameArr=##class(%DynamicArray).%New()
		set tStatement = ##class(%SQL.Statement).%New()
		//查询所有服务
		Set sqlName="SELECT distinct ServiceName, Publish, Subscribe  FROM HIPPSer_MSG.MtTable where ServiceName='"_name_"'"
		$$$LOGINFO("sql:"_sqlName)
		Set tSC=..Adapter.ExecuteQuery(.tResult,sqlName)
		Set Publish=""
	 	WHILE tResult.Next(){
		 	    Set NewFiled = ##class(%DynamicObject).%New()
		 	    if (tResult.Get("Subscribe")'=""){
			 	    Do NewFiled.%Set("Subscribe",tResult.Get("Subscribe"))
			 	   Do totalArr.%Push(NewFiled)
			 	    }
		    	
		 		 Set Publish=tResult.Get("Publish")
		    	
		}	
	    set ceshi=..businesspartner(name)
	    $$$LOGINFO("ceshi"_ceshi)
	    Set jsonObject.release=Publish
	    Set jsonObject.subscribe=totalArr
	    
	   ///判断是否为查询
		
	  
	    if ( $l(name,"查询")>1){
		   Set jsonObject.flag=0     
		 }
		 else{
			  Set jsonObject.flag=1 
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

XData MessageMap
{
<MapItems>
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>InvokeHDR</Method>
	</MapItem>
</MapItems>
}

}
