/// Classname:	JHIPV5.MesRretr.BO.GetMessageBodyBO
/// Summary:	集成引擎监管消息检索模块——消息内容获取;
/// TODO:		消息内容获取;
/// WebMethod:	ResendMessage
/// Parameters:	参数:Ens.StringRequest消息类型;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.MesRretr.BO.GetMessageBodyBO Extends Ens.BusinessOperation
{

Parameter ADAPTER = "EnsLib.SOAP.OutboundAdapter";

Property Adapter As EnsLib.SOAP.OutboundAdapter;

Parameter INVOCATION = "Queue";

/// 获取消息内容的的方法;
Method GetMessageBodyBO(pInput As Ens.StringRequest, Output pResponse As Ens.StringResponse) As %Status
{
	Set Util=##class(JHIPLIB.Util.ClassAndXML).%New()
	set jsonObject = ##class(%DynamicObject).%New()
	set DataArr=##class(%DynamicArray).%New()
	set DataArrA=##class(%DynamicArray).%New()
	set tResult=##class(%SQL.StatementResult).%New()
	Try{
		Set SessionID=pInput.StringValue
		Set sql="SELECT Type,SessionID, MessageBodyClassName,MessageBodyId,Type FROM Ens.MessageHeader  Where SessionID='"_SessionID_"' Group by Type"
		Set statement = ##class(%SQL.Statement).%New()
		Set qStatus = statement.%Prepare(sql)
		Set tResult = statement.%Execute()
		//遍历结果集并将分页查询显示SQL获取到的数据放至json
		WHILE tResult.%Next(){
		    Set NewFiled = ##class(%DynamicObject).%New()
			set MessageBodyId=tResult.%Get("MessageBodyId")
			Set MessageBodyClassName=tResult.%Get("MessageBodyClassName")
			Set tType=tResult.%Get("Type")
			Set RawContent=""
			IF MessageBodyClassName="EnsLib.EDI.XML.Document"{
				Set doc = ##class(EnsLib.EDI.XML.Document).%New()
				set doc = ##class(EnsLib.EDI.XML.Document).%OpenId(MessageBodyId)
				if $IsObject(doc){
		        	set stream2 = ##class(%Stream.GlobalCharacter).%New()
					DO doc.OutputToIOStream(.stream2)
					set content = ""
					while 'stream2.AtEnd {set content = content _ stream2.Read()}
					Set RawContent=content
				}
			}ElseIF MessageBodyClassName="JHIPLIB.Util.MSG.JHRequestMsg"{
				set doc = ##class(JHIPLIB.Util.MSG.JHRequestMsg).%OpenId(MessageBodyId)
				Set RawContent=doc.pArg.GetAt(1)
			}ElseIF MessageBodyClassName="JHIPLIB.Util.MSG.JHResposeMsg"{
				set doc = ##class(JHIPLIB.Util.MSG.JHResposeMsg).%OpenId(MessageBodyId)
				Set RawContent=doc.pArg.GetAt(1)
			}ElseIF MessageBodyClassName="Ens.StringResponse"{
				set doc = ##class(Ens.StringResponse).%OpenId(MessageBodyId)
				Set RawContent=doc.StringValue
			}ElseIF MessageBodyClassName="Ens.Response"{
				set doc = ##class(Ens.Response).%OpenId(MessageBodyId)
				Set RawContent="<RESPONSE><RESULT_CODE>true</RESULT_CODE><RESULT_CONTENT>成功</RESULT_CONTENT></RESPONSE>"
			}ElseIF MessageBodyClassName="JHIPLIB.Util.MSG.PatientInfoMSG"{
				Set doc = ##class(JHIPLIB.Util.MSG.PatientInfoMSG).%OpenId(MessageBodyId)
				Set stc=Util.Object2Xml(doc,"PATIENT_INFO",.str)
				Set RawContent=str
			}
			if RawContent'=""{
				DO NewFiled.%Set("RawContent",RawContent)
				DO NewFiled.%Set("MessageBodyId",MessageBodyId)
				If tType=1 {
					Set DataArrA."0"=NewFiled	
				}ElseIf tType=2 {
					Set DataArrA."1"=NewFiled
				}	
			}Else{
				DO NewFiled.%Set("RawContent","<Message><RESULT_CODE>500</RESULT_CODE><RESULT_CONTENT>会话ID："_SessionID_" -——未获取到数据，请前往引擎具体查看服务接口</RESULT_CONTENT></Message>")
				DO NewFiled.%Set("MessageBodyId",MessageBodyId)
				Do DataArrA.%Push(NewFiled)
			}
		}
		Set jsonObject.rows=DataArrA
		Set pResponse=##class(Ens.StringResponse).%New()
		Set pResponse.StringValue=$zcvt(jsonObject.%ToJSON(),"O","UTF8")
	}catch(ex){
		$$$LOGERROR(ex.DisplayString())				
	}		
	Quit $$$OK
}

XData MessageMap
{
<MapItems>
	
	<MapItem MessageType="Ens.StringRequest"> 
		<Method>GetMessageBodyBO</Method>
	</MapItem>
	
</MapItems>
}

}
