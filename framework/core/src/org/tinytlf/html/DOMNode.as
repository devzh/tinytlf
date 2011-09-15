package org.tinytlf.html
{
	import flash.events.*;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.interaction.*;
	
	use namespace flash_proxy;
	
	public dynamic class DOMNode extends Styleable implements IDOMNode
	{
		[Inject]
		public var emm:IEventMirrorMap;
		
		[Inject]
		public var css:CSS;
		
		[Inject]
		public var injector:Injector;
		
		[Inject]
		public var reflector:Reflector;
		
		public function DOMNode(node:XML, parent:IDOMNode = null)
		{
			super();
			
			xml = node;
			
			// Apply the node's properties to this object
			for each(var attr:XML in xml.attributes())
			{
				this[attr.localName()] = attr.toString();
			}
			
			p = parent;
			
			inheritanceList = (p ? p.inheritance : '*');
			if(name)
			{
				inheritanceList += ' ' + name;
			}
			if(hasOwnProperty('class'))
			{
				const classes:String = this['class'];
				classes.
					split(' ').
					forEach(function(cls:String, ... args):void {
						inheritanceList += (' .' + cls);
					});
			}
			if(hasOwnProperty('id'))
			{
				inheritanceList += ' #' + this['id'];
			}
		}
		
		[PostConstruct]
		public function initialize():void
		{
			mergeWith(css.lookup(inheritance));
			
			// Build out the DOM
			for each(var child:XML in xml.*)
			{
				kids.push(new DOMNode(child, this));
			}
		}
		
		private var xml:XML = <_/>;
		
		private const kids:Array = [];
		public function get children():Array
		{
			return kids.concat();
		}
		
		private var element:ContentElement;
		public function get content():ContentElement
		{
			return element;
		}
		
		public function set content(ce:ContentElement):void
		{
			element = ce;
		}
		
		private var inheritanceList:String = '';
		public function get inheritance():String
		{
			return inheritanceList;
		}
		
		private var eventMirror:*;
		public function set mirror(value:*):void
		{
			eventMirror = value;
		}
		
		public function get name():String
		{
			return xml.localName();
		}
		
		public function set name(value:String):void
		{
		}
		
		private var p:IDOMNode;
		public function get parent():IDOMNode
		{
			return p;
		}
		
		public function get text():String
		{
			if(xml.nodeKind() == 'text')
				return xml.toString();
			
			return xml..text().toString();
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			if(name.toString() == "*")
				return children;
			
			return super.getProperty(name);
		}
		
		override flash_proxy function getDescendants(name:*):*
		{
			const all:Array = [];
			
			kids.forEach(function(child:IDOMNode, ... args):void {
				if(child.children.length)
					all.push.apply(null, child..name);
				else if(child.name == name || name == '*')
					all.push(child);
			});
			
			return all;
		}
	}
}
