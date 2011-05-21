package org.tinytlf.conversion
{
	import flash.utils.flash_proxy;
	
	import org.tinytlf.styles.StyleAwareActor;
	import org.tinytlf.util.XMLUtil;
	
	use namespace flash_proxy;
	
	public dynamic class HTMLNode extends StyleAwareActor implements IHTMLNode
	{
		public function HTMLNode(node:XML, parent:IHTMLNode = null)
		{
			super(XMLUtil.buildKeyValueAttributes(node.attributes()));
			
			xml = node;
			
			this.parent = parent;
			
			inheritance = (parent ? parent.inheritanceList : '* body') + ' ' + describeInheritance(node);
		}
		
		override flash_proxy function getDescendants(name:*):*
		{
			return xml..*;
		}
		
		private var xml:XML = <_/>;
		
		override flash_proxy function getProperty(name:*):*
		{
			if(name.toString() == "*")
				return children;
			
			return super.getProperty(name);
		}
		
		public function get children():XMLList
		{
			return xml.*;
		}
		
		private var inheritance:String = '';
		
		public function get inheritanceList():String
		{
			return inheritance;
		}
		
		private function describeInheritance(node:XML):String
		{
			var str:String = node.localName();
			
			if(node.attribute('class').length())
				str += ' .' + node.attribute('class');
			if(node.attribute('id').length())
				str += ' #' + node.@id;
			
			return str;
		}
		
		public function get name():String
		{
			return xml.localName();
		}
		
		public function get text():String
		{
			if(xml.nodeKind() == 'text')
				return xml.toString();
			
			return xml.text().toString();
		}
		
		private var p:IHTMLNode;
		
		public function get parent():IHTMLNode
		{
			return p;
		}
		
		public function set parent(value:IHTMLNode):void
		{
			p = value;
		}
	}
}