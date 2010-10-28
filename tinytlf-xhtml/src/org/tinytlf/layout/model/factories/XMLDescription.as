package org.tinytlf.layout.model.factories
{
	import flash.utils.flash_proxy;
	
	import org.tinytlf.styles.StyleAwareActor;
	import org.tinytlf.util.XMLUtil;
	
	use namespace flash_proxy;
	
	public dynamic final class XMLDescription extends StyleAwareActor
	{
		public function XMLDescription(node:XML)
		{
			name = node.localName();
			merge(XMLUtil.buildKeyValueAttributes(node.attributes()));
			propNames.push('style');
		}
		
		override public function set style(value:Object):void
		{
			inlineStyles = value.toString();
		}
		
		override public function get style():Object
		{
			return inlineStyles;
		}
		
		private var inlineStyles:String = '';
		
		public var name:String = '';
		public var styleString:String = '';
		
		public function doneProcessing():void
		{
			shouldReprocess = false;
		}
		
		public function reprocess():Boolean
		{
			return shouldReprocess;
		}
		
		private var shouldReprocess:Boolean = true;
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			super.setProperty(name, value);
			shouldReprocess = true;
		}
		
		override flash_proxy function deleteProperty(name:*):Boolean
		{
			return shouldReprocess = super.deleteProperty(name);
		}
	}
}
