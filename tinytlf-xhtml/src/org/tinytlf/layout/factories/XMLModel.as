package org.tinytlf.layout.factories
{
	import flash.text.engine.ContentElement;
	import flash.utils.flash_proxy;
	
	import org.tinytlf.styles.StyleAwareActor;
	import org.tinytlf.util.XMLUtil;
	
	use namespace flash_proxy;
	
	public dynamic final class XMLModel extends StyleAwareActor
	{
		public function XMLModel(node:XML)
		{
			name = node.localName();
			mergeWith(XMLUtil.buildKeyValueAttributes(node.attributes()));
			propNames.push('style');
		}
		
		private var inlineStyles:String = '';
		
		override public function set style(value:Object):void
		{
			inlineStyles = value.toString();
		}
		
		override public function get style():Object
		{
			return inlineStyles;
		}
		
		public var name:String = '';
		
		public var styleString:String = '';
		
		private var _contentDirty:Boolean = true;
		
		public function get contentDirty():Boolean
		{
			return _contentDirty;
		}
		
		public function set contentDirty(value:Boolean):void
		{
			_contentDirty = value;
		}
		
		private var _stylesDirty:Boolean = true;
		
		public function get stylesDirty():Boolean
		{
			return _stylesDirty;
		}
		
		public function set stylesDirty(value:Boolean):void
		{
			_stylesDirty = value;
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			super.setProperty(name, value);
			_stylesDirty = true;
		}
		
		override flash_proxy function deleteProperty(name:*):Boolean
		{
			return _stylesDirty = super.deleteProperty(name);
		}
		
		private var kids:Vector.<XMLModel> = new <XMLModel>[];
		public function addChild(child:XMLModel):void
		{
			kids.push(child);
		}
		
		public function removeChild(child:XMLModel):void
		{
			var i:int = kids.indexOf(child);
			if(i != -1)
				kids.splice(i, 1);
		}
	}
}
