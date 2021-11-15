<<<<<<< HEAD
Class JHIPLIB.SOAP.BO.Test Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SOAP.OutboundAdapter";

Property Adapter As EnsLib.SOAP.OutboundAdapter;

Parameter INVOCATION = "Queue";

Method Send(pRequest As EnsLib.EDI.XML.Document, Output pResponse As Ens.StringResponse) As %Status
{
	;进行测试
	; 再次进行测试
	; 再次测试
<<<<<<< HEAD
=======
	; 第4次测试
>>>>>>> b5d7f06 (第4次修改测试类)
	Quit $$$ERROR($$$NotImplemented)
}

XData MessageMap
{
<MapItems>
	<MapItem MessageType="EnsLib.EDI.XML.Document"> 
		<Method>Send</Method>
	</MapItem>
</MapItems>
=======
Class JHIPLIB.SOAP.BS.Test Extends JHIPLIB.SOAP.AESCBC.AESCBCService
{

Parameter ADAPTER;

/// Name of the WebService
Parameter SERVICENAME = "Test";

/// TODO: Change this to actual network address
/// URL for invoking the WebService
/// Parameter LOCATION = "http://127.0.0.1:8972/csp/ensemble";
/// TODO: Change this to actual SOAP namespace
/// SOAP namespace for the WebService
Parameter NAMESPACE = "http://bjgoodwillcis.com";

Parameter SETTINGS = "TargetConfigNames:Basic:selector?multiSelect=0&context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId},IsSync:Basic,AsyReturnFormat:Basic,SearchTableClass:Basic:selector?context={Ens.ContextSearch/SearchTableClasses?host=JHIPLIB.SOAP.BS.XmlService},-Framing,EventMethod:Basic,DocTypeResolution";

Property Framing As %String [ InitialExpression = "AsciiLF" ];

Property EventMethod As %String(MAXLEN = 10000);

/// 选择对应的SearchTableClass，进行消息搜索
Property SearchTableClass As %String(MAXLEN = 128);

/// 接收消息的目标组件名称
Property TargetConfigNames As Ens.DataType.ConfigName;

/// 设置消息是否是同步发送。异步去勾，同步打勾，默认异步。
Property IsSync As %Boolean [ InitialExpression = 0 ];

/// 设置异步返回值格式,XML为自定义格式,String为字符串格式,JSON为JSON格式。
Property AsyReturnFormat As %String(DISPLAYLIST = ",XML,JSON,String", VALUELIST = ",XML,JSON,String") [ InitialExpression = "XML" ];

Method Sample(action As %String, msg As %String) As %String [ WebMethod ]
{
	If ""=..TargetConfigNames { $$$LOGWARNING("没有选择接收消息的目标名称，请查看BS前台设置属性!") }
	Set pInput = ##class(JHIPLIB.Util.MSG.TestMsg).%New()
	Set pInput.action = action
	Set pInput.msg = msg
	Set tResponse = ##class(EnsLib.EDI.XML.Document).%New()
	For iTarget=1:1:$L(..TargetConfigNames, ","){
			Set tSC=..ProcessInput(pInput,.tResponse,$P(..TargetConfigNames,",",iTarget))
		}
	If $$$ISERR(tSC) Do ..ReturnMethodStatusFault(tSC)
	;Set tResponse = ##class(EnsLib.EDI.XML.Document).ImportFromString("<RESPONSE><RESULT_CODE>true</RESULT_CODE><RESULT_CONTENT>调用BS成功</RESULT_CONTENT></RESPONSE>")
	;DO tResponse.XMLExportToString(.result)
	;"<RESPONSE><RESULT_CODE>true</RESULT_CODE><RESULT_CONTENT>成功</RESULT_CONTENT></RESPONSE>"
		Set:..IsSync=1 result=tResponse.XMLExportToString(.result)
	If ..IsSync=0{
		IF ..AsyReturnFormat="String"{
			Set result="平台"_..%ConfigName_"接收成功,调用时间为"_$ZDT($H,3)_"."
		}ELSEIF ..AsyReturnFormat="XML"{
			Set result="<RESPONSE><RESULT_CODE>true</RESULT_CODE><RESULT_CONTENT>平台接收"_..%ConfigName_"成功,调用时间为"_$ZDT($H,3)_"</RESULT_CONTENT></RESPONSE>"
		}ELSE{
			Set result="{""Code"":""200"",""Result"":""平台接收"_..%ConfigName_"成功,调用时间为"_$ZDT($H,3)_"""}"
		}
  	} 
	Quit result
}

Method OnProcessInput(pInput As %RegisteredObject, Output pOutput As %RegisteredObject, ByRef pHint As %String) As %Status
{
	//判断是否为同步发送
	 If ..IsSync=0{
	    Set tSC=..SendRequestAsync(pHint,pInput)
	    }else{
		Set tSC=..SendRequestSync(pHint,pInput,.pOutput)}
	;Set:$L(^Activity)>0 stuts=$zobjclassmethod("JHIPLIB.HIPP.SaveBase","Activity",..BusinessPartner,pInput.OriginalDocId,..%ConfigName,"I")
	If ""'=..SearchTableClass {
		TRY {		
			Set tSCStore=$zobjclassmethod(..SearchTableClass,"IndexDoc",pInput)
			If $$$ISERR(tSCStore) $$$LOGWARNING("无法为此消息构建SearchTable条目"_pInput_"/"_pInput.%Id()_" 类型为'"_pInput.%ClassName(1)_"' 使用的类为'"_..SearchTableClass_"' "_$$$StatusDisplayString(tSCStore))
			} CATCH errobj { $$$LOGWARNING("调用SearchTable方法失败"_..SearchTableClass_".IndexDoc() 输入为:"_pInput_"/"_pInput.%Id()_" 并且 DocType='"_pInput.%ClassName(1)_"' : "_errobj.AsSystemError()) 
		}
	}	
	
	Quit tSC
>>>>>>> 9cea8c1 (BS测试)
}

}
