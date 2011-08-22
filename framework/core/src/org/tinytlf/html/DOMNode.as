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
					forEach(function(cls:String, ...args):void{
						inheritanceList += (' .' + cls);
					});
			}
			if(hasOwnProperty('id'))
			{
				inheritanceList += ' #' + this['id'];
			}
		}
		
		[PostConstruct]
		public function finalizeCreation():void
		{
			eventMirror = emm.instantiate(name);
			
			if(parent && reflector.getClass(parent.mirror) != emm.defaultFactory)
			{
				eventMirror = new Link(eventMirror, parent.mirror);
			}
			
			mergeWith(css.lookup(inheritance));
			
			// Build out the DOM
			for each(var child:XML in xml.*)
			{
				const kid:IDOMNode = new DOMNode(child, this);
				injector.injectInto(kid);
				kids.push(kid);
			}
		}
		
		private var xml:XML = <_/>;
		
		private const kids:Vector.<IDOMNode> = new <IDOMNode>[];
		public function get children():Vector.<IDOMNode>
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
		
		private var eventMirror:EventDispatcher;
		public function get mirror():EventDispatcher
		{
			return eventMirror;
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
			const all:Vector.<IDOMNode> = new <IDOMNode>[];
			
			kids.forEach(function(child:IDOMNode, ... args):void{
				
				if(child.children.length)
					all.push.apply(null, child..name);
				else if(child.name == name || name == '*')
					all.push(child);
			});
			
			return all;
		}
	}
}

import flash.events.*;

internal class Link extends EventDispatcher
{
	private var target:EventDispatcher;
	
	public function Link(dispatcher:EventDispatcher, parent:EventDispatcher = null)
	{
		target = dispatcher;
		p = parent;
	}
	
	private var p:EventDispatcher;
	
	override public function dispatchEvent(event:Event):Boolean
	{
		var success:Boolean = true;
		// Targeting phase
		if(target.hasEventListener(event.type))
		{
			success = target.dispatchEvent(event.clone());
		}
		
		// Bubbling phase
		if(p)
		{
			p.dispatchEvent(event.clone());
		}
		
		return success;
	}
	
	override public function hasEventListener(type:String):Boolean
	{
		return true;
	}
	
	override public function willTrigger(type:String):Boolean
	{
		return true;
	}
}