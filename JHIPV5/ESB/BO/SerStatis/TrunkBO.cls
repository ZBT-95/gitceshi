Class JHIPV5.ESB.BO.SerStatis.TrunkBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SQL.OutboundAdapter";

Property Adapter As EnsLib.SQL.OutboundAdapter;

Parameter INVOCATION = "Queue";

// 第一个获取服务总线BO

Method InvokeHDR(pRequest As Ens.StringRequest, Output pOutput As Ens.StringResponse) As %Status
{
	try{
        set sunkeyObj = ##class(%DynamicObject).%New()
        set nadesarr = ##class(%DynamicArray).%New()
        set linksarr = ##class(%DynamicArray).%New()   
        Set rset = ##class(%SQL.StatementResult).%New()
        //获取来来来向信息
        set sql ="SELECT  Publish FROM HIPPSer_MSG.MtTableComplete group by Publish "
		Set tSC=..Adapter.ExecuteQuery(.rset,sql)          
        while rset.Next(){
	        set nodeobj = ##class(%DynamicObject).%New()
	        Set Publish = rset.%Get("Publish")
	        if Publish '=""{
		        Set Publish = Publish_"->"
	            set nodeobj.name=Publish
	            do nadesarr.%Push(nodeobj)
		        } 
	       
        }
        //获取所有相关的合作伙伴和去向信息
        set sql ="SELECT  Subscribe FROM HIPPSer_MSG.MtTableComplete group by Subscribe"
		Set tSC=..Adapter.ExecuteQuery(.rset,sql) 
		;$$$LOGINFO("rset.Next()"_rset.Next())         
        while rset.Next(){
	        set nodeobj = ##class(%DynamicObject).%New()
	        Set Subscribe = rset.%Get("Subscribe")
	        if Subscribe'=""{
		        Set Subscribe = "->"_Subscribe
	            set nodeobj.name=Subscribe
	            do nadesarr.%Push(nodeobj)
	        }
	       
        }
        //获取所有相关的合作伙伴和去向信息
        set sql ="SELECT  ServiceType FROM HIPPSer_MSG.MtTableComplete where  (Publish !='' or Subscribe !='')  group by ServiceType"
		Set tSC=..Adapter.ExecuteQuery(.rset,sql)          
        while rset.Next(){
	         set nodeobj = ##class(%DynamicObject).%New()
	         Set ServiceType = rset.%Get("ServiceType")
	         set nodeobj.name=ServiceType
	         do nadesarr.%Push(nodeobj)
		        
	        }
        //动态组件
        set sql ="SELECT distinct ServiceType,Publish,Subscribe FROM HIPPSer_MSG.MtTableComplete where (Publish !='' or Subscribe !='')"
		Set tSC=..Adapter.ExecuteQuery(.rset,sql)          
        while rset.Next(){
	        set linkobj = ##class(%DynamicObject).%New()
	        set linkobj2 = ##class(%DynamicObject).%New()
	        Set Publish = rset.%Get("Publish")
	        if Publish '=""{
		        Set ServiceType = rset.%Get("ServiceType")
	            set linkobj.source = Publish_"->"
		    	Set linkobj.target = ServiceType
		    	//set linkobj.value = rsetLink.%Get("num")
		    	set linkobj.value = 1
		    	do linksarr.%Push(linkobj)
		        }
	        Set Subscribe = rset.%Get("Subscribe")
	        if Subscribe '=""{
		        Set ServiceType = rset.%Get("ServiceType")
	            set linkobj2.source = ServiceType
		    	Set linkobj2.target = "->"_Subscribe
		    	//set linkobj.value = rsetLink.%Get("num")
		    	set linkobj2.value = 1
		    	do linksarr.%Push(linkobj2)
		        }
	        }
        
		set sunkeyObj.nodes=nadesarr              
        set sunkeyObj.links=linksarr
       	set sunkeyObj = sunkeyObj.%ToJSON()
       	set pOutput =##class(Ens.StringResponse).%New()
       	set pOutput.StringValue =$zcvt(sunkeyObj,"O","UTF8")
       //set pOutput.StringValue =sunkeyObj
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
