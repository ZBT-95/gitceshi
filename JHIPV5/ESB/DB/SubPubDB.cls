/// Classname:	JHIPV5.ESB.DB.SubPubDB
/// Summary:	集成引擎监管订阅发布模块——订阅系统数据库;
/// TODO:		重发消息;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.DB.SubPubDB Extends %Persistent
{

/// 命名空间
Property spaceType As %String;

/// 服务名称
Property serName As %String;

/// 服务入口
Property bsName As %String;

/// 入口标准
Property inStandard As %String;

/// 发布系统
Property pubSys As %String;

/// 服务出口
Property boName As %String;

/// 出口标准
Property outStandard As %String;

/// 订阅系统
Property subSys As %String;

Storage Default
{
<Data name="SubPubDBDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>space</Value>
</Value>
<Value name="3">
<Value>serName</Value>
</Value>
<Value name="4">
<Value>bsName</Value>
</Value>
<Value name="5">
<Value>PubSys</Value>
</Value>
<Value name="6">
<Value>boName</Value>
</Value>
<Value name="7">
<Value>inStandard</Value>
</Value>
<Value name="8">
<Value>outStandard</Value>
</Value>
<Value name="9">
<Value>serBO</Value>
</Value>
<Value name="10">
<Value>spaceType</Value>
</Value>
<Value name="11">
<Value>pubSys</Value>
</Value>
<Value name="12">
<Value>subSys</Value>
</Value>
</Data>
<DataLocation>^JHIPV5.ESB.DB.SubPubDBD</DataLocation>
<DefaultData>SubPubDBDefaultData</DefaultData>
<IdLocation>^JHIPV5.ESB.DB.SubPubDBD</IdLocation>
<IndexLocation>^JHIPV5.ESB.DB.SubPubDBI</IndexLocation>
<StreamLocation>^JHIPV5.ESB.DB.SubPubDBS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
