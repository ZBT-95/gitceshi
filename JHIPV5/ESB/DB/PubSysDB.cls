/// Classname:	JHIPV5.ESB.DB.PubSysDB
/// Summary:	集成引擎监管订阅发布模块——发布系统数据库;
/// TODO:		重发消息;
/// Version:	1.0;
/// Date:		2021年07月01号16:31;
/// Author:		马家齐
/// Copyright:	北京嘉和美康信息技术有限公司;
Class JHIPV5.ESB.DB.PubSysDB Extends %Persistent
{

/// 命名空间
Property spaceType As %String;

/// 服务名称
Property serName As %String;

/// 服务入口
Property bsName As %String;

/// 发布系统
Property pubSys As %String;

Storage Default
{
<Data name="PubSysDBDefaultData">
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
<Value>pubSys</Value>
</Value>
<Value name="6">
<Value>spaceType</Value>
</Value>
</Data>
<DataLocation>^JHIPV5.ESB.DB.PubSysDBD</DataLocation>
<DefaultData>PubSysDBDefaultData</DefaultData>
<IdLocation>^JHIPV5.ESB.DB.PubSysDBD</IdLocation>
<IndexLocation>^JHIPV5.ESB.DB.PubSysDBI</IndexLocation>
<StreamLocation>^JHIPV5.ESB.DB.PubSysDBS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
