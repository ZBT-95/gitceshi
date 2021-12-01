Class JHIPV5.ESB.BO.AccSystem.SingleSignOnBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method OnMessage(pInput As Ens.StringRequest, Output pOutput As Ens.StringResponse) As %Status
{
	try{
	   set dataArr = ##class(%DynamicArray).%New()
       //获取单点登录系统()
#;       Set sqlSYS = "select count(*)AS num from register_system_info where is_singlesystem='1'"
#;	   Set tSCSYS = ..Adapter.ExecuteQuery(.tResultSYS,sqlSYS)
#;	   if tSCSYS{
#;			if tResultSYS.Next(){
						//单点登录
				Set NewFiled = ##class(%DynamicObject).%New()
				Do NewFiled.%Set("name","单点登录")
#;				Do NewFiled.%Set("value",tResultSYS.Get("num")+0)
				Do NewFiled.%Set("value",26)
				Do NewFiled.%Set("max",26)
				Do dataArr.%Push(NewFiled)
#;				}
#;		}
	    Set pOutput = ##class(Ens.StringResponse).%New()
	    Set pOutput.StringValue=$zcvt(dataArr.%ToJSON(),"O","UTF8")
	 }Catch(e){	
	  Set tSC=e.AsStatus()
   }
	Quit $$$OK
}

}
