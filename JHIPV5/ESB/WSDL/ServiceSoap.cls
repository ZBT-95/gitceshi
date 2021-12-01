Class JHIPV5.ESB.WSDL.ServiceSoap Extends %SOAP.WebClient [ ProcedureBlock ]
{

/// This is the URL used to access the web service.
/// Parameter LOCATION = "http://192.168.100.69:57772/soap/JHIPLIB.SOAP.BS.Service.cls";
/// This is the namespace used by the Service
Parameter NAMESPACE = "http://bjgoodwillcis.com";

/// Use xsi:type attribute for literal types.
Parameter OUTPUTTYPEATTRIBUTE = 1;

/// Determines handling of Security header.
Parameter SECURITYIN = "ALLOW";

/// This is the name of the Service
Parameter SERVICENAME = "Service";

/// This is the SOAP version supported by the service.
Parameter SOAPVERSION = 1.1;

Method Send(pInput As %String) As %String [ Final, ProcedureBlock = 1, SoapBindingStyle = document, SoapBodyUse = literal, WebMethod ]
{
 Quit ..WebMethod("Send").Invoke($this,"http://bjgoodwillcis.com/JHIPLIB.SOAP.BS.Service.Send",.pInput)
}

XData parameters
{
<parameters xmlns="http://www.intersystems.com/configuration" xmlns:cfg="http://www.intersystems.com/configuration">
  <method name="Send">
    <request>
      <header name="JiaheSecurity" class="JHIPV5.ESB.WSDL.ns2.JiaheSecurity"/>
    </request>
  </method>
</parameters>
}

}
