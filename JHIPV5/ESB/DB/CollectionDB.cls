Class JHIPV5.ESB.DB.CollectionDB Extends %Persistent
{

/// 搜索内容
Property inputVal As %String;

/// 搜索名称
Property radioVal As %String;

/// 主键
Property FileBody As %String(MAXLEN = 256000);

/// 命名空间
Property spaceType As %String;

Storage Default
{
<Data name="CollectionDBDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>inputVal</Value>
</Value>
<Value name="3">
<Value>radioVal</Value>
</Value>
<Value name="4">
<Value>FileBody</Value>
</Value>
<Value name="5">
<Value>spaceType</Value>
</Value>
</Data>
<DataLocation>^JHIPV5.ESB.DB.CollectionDBD</DataLocation>
<DefaultData>CollectionDBDefaultData</DefaultData>
<IdLocation>^JHIPV5.ESB.DB.CollectionDBD</IdLocation>
<IndexLocation>^JHIPV5.ESB.DB.CollectionDBI</IndexLocation>
<StreamLocation>^JHIPV5.ESB.DB.CollectionDBS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
