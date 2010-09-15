package org.tinytlf.layout.model.factories
{
	public final class XMLDescription
	{
		public function XMLDescription(node:XML)
		{
			name = node.localName();
			attributes = new Attributes(node.attributes());
		}
		
		public var name:String = '';
		public var attributes:Object = new Attributes();
		public var styleString:String = '';
		
		public function doneProcessing():void
		{
			attributes.doneProcessing();
		}
		
		public function reprocess():Boolean
		{
			return attributes.reprocess;
		}
	}
}
import com.flashartofwar.fcss.objects.AbstractOrderedObject;

import org.tinytlf.util.XMLUtil;

internal dynamic class Attributes extends AbstractOrderedObject
{
	public function Attributes(attributes:XMLList = null)
	{
		super(this);
		
		if(attributes)
			merge(XMLUtil.buildKeyValueAttributes(attributes));
	}
	
	override protected function registerClass():void
	{
	}
	
	override protected function $setProperty(name:*, value:*):void
	{
		super.$setProperty(name, value);
		shouldReprocess = true;
	}
	
	override protected function $deleteProperty(name:*):Boolean
	{
		shouldReprocess = true;
		return super.$deleteProperty(name);
	}
	
	private var shouldReprocess:Boolean = true;
	public function get reprocess():Boolean
	{
		return shouldReprocess;
	}
	
	public function doneProcessing():void
	{
		shouldReprocess = false;
	}
}