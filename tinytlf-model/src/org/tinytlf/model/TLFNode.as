package org.tinytlf.model
{
	import flash.text.engine.*;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.styles.StyleAwareActor;
	import org.tinytlf.util.fte.ContentElementUtil;
	
	public class TLFNode extends StyleAwareActor implements ITLFNode, ITLFNodeParent
	{
		public static var DEBUG_MODE:Boolean = false;
		
		public function TLFNode(text:String = '')
		{
			super(new InheritingStyleProxy(this));
			makeLeafImpl(text);
		}
		
		private var _parent:ITLFNodeParent;
		
		public function get parent():ITLFNodeParent
		{
			return _parent;
		}
		
		protected const children:Vector.<ITLFNode> = new <ITLFNode>[];
		
		public function get numChildren():int
		{
			return children.length;
		}
		
		public function addChild(node:ITLFNode):ITLFNode
		{
			return addChildAt(node, numChildren);
		}
		
		public function addChildAt(node:ITLFNode, index:int):ITLFNode
		{
			checkRange(index);
			
			if(node.parent)
				node.parent.removeChild(node);
			
			children.splice(index, 0, node);
			
			if(node is TLFNode)
				TLFNode(node)._parent = this;
			
			node.engine = engine;
			
			// attach the new node's contentElement as a child
			// of our GroupElement, assuming it has been generated.
			if((contentElement is GroupElement) && node.contentElement)
			{
				ContentElementUtil.addChildAt(contentElement, node.contentElement, index);
			}
			
			impl;
			
			return node;
		}
		
		public function addChildren(kids:Vector.<ITLFNode>):Vector.<ITLFNode>
		{
			for(var i:int = 0, n:int = kids.length; i < n; ++i)
				addChild(kids[i]);
			
			impl;
			
			return Vector.<ITLFNode>(kids);
		}
		
		public function removeChild(node:ITLFNode):ITLFNode
		{
			return removeChildAt(getChildIndex(node));
		}
		
		public function removeChildAt(index:int):ITLFNode
		{
			checkRange(index);
			
			const node:ITLFNode = getChildAt(index);
			children.splice(index, 1);
			
			if(node is TLFNode)
				TLFNode(node)._parent = null;
			
			node.engine = null;
			
			node.regenerateStyles();
			
			// remove the node's contentElement from 
			// the model if it's been generated yet.
			if(node.contentElement)
			{
				if(contentElement is GroupElement)
				{
					ContentElementUtil.removeChildAt(contentElement, index);
				}
				else
				{
					var ce:ContentElement = node.contentElement;
					var block:TextBlock = ce.textBlock;
					if(block.content == ce)
					{
						block.content = null;
					}
				}
			}
			
			// ensure the proper implementation exists.
			// if you add a child to a Leaf node, this 
			// changes the impl from LeafImpl to ContainerImpl.
			impl;
			
			return node;
		}
		
		public function removeChildren(kids:Vector.<ITLFNode>):Vector.<ITLFNode>
		{
			const newKids:Vector.<ITLFNode> = Vector.<ITLFNode>(kids);
			
			if(children.length == 0)
				return newKids;
			
			for each(var kid:ITLFNode in newKids)
				removeChild(kid);
			
			impl;
			
			return newKids;
		}
		
		public function getChildAt(index:int):ITLFNode
		{
			checkRange(index);
			
			return children[index];
		}
		
		public function getChildIndex(node:ITLFNode):int
		{
			return children.indexOf(node);
		}
		
		public function getChildPosition(index:int):int
		{
			var len:int = 0;
			for(var i:int = 0; i < index; i += 1)
				len += ITLFNode(getChildAt(i)).length;
			
			return len;
		}
		
		public function getChildIndexAtPosition(at:int):int
		{
			if(at == 0)
				return 0;
			
			if(at == length)
				return numChildren - 1;
			
			var k:int = 0;
			var child:ITLFNode;
			
			for(var i:int = 0, n:int = numChildren; i < n; i += 1)
			{
				child = ITLFNode(getChildAt(i));
				if(k + child.length > at)
					return i;
				k += child.length;
			}
			
			return -1;
		}
		
		public function swapChildren(child1:ITLFNode, child2:ITLFNode):void
		{
			var index1:int = getChildIndex(child1);
			var index2:int = getChildIndex(child2);
			
			children[index1] = child2;
			children[index2] = child1;
		}
		
		public function getLeaf(at:int):ITLFNode
		{
			return impl.getLeaf(at);
		}
		
		private function checkRange(index:int):void
		{
			if(index < 0 || index > numChildren)
				throw new RangeError('Index ' + index + ' is out of bounds.');
		}
		
		public function get type():String
		{
			return numChildren > 0 ? TLFNodeType.CONTAINER : TLFNodeType.LEAF;
		}
		
		public function get contentElement():ContentElement
		{
			return impl.contentElement;
		}
		
		public function set contentElement(value:ContentElement):void
		{
			impl.contentElement = value;
		}
		
		private var _engine:ITextEngine;
		
		public function get engine():ITextEngine
		{
			return _engine;
		}
		
		public function set engine(textEngine:ITextEngine):void
		{
			if(textEngine == _engine)
				return;
			
			_engine = textEngine;
		}
		
		public function get length():int
		{
			return impl.length;
		}
		
		public function get name():String
		{
			return impl.name;
		}
		
		public function set name(value:String):void
		{
			impl.name = value;
		}
		
		public function regenerateStyles():void
		{
			InheritingStyleProxy(style).regenerateStyles();
		}
		
		public function get text():String
		{
			return impl.text;
		}
		
		public function insert(value:Object, at:int):ITLFNode
		{
			return impl.insert(value, at);
		}
		
		public function remove(start:int, end:int = int.MAX_VALUE):ITLFNode
		{
			return impl.remove(start, end);
		}
		
		public function split(at:int):ITLFNode
		{
			return impl.split(at);
		}
		
		public function merge(start:int, end:int):ITLFNode
		{
			return impl.merge(start, end);
		}
		
		public function clone(start:int = 0, end:int = int.MAX_VALUE):ITLFNode
		{
			return impl.clone(start, end);
		}
		
		override public function toString():String
		{
			return impl.toString();
		}
		
		private var _ITLFNodeImpl:ITLFNode;
		
		private function get impl():ITLFNode
		{
			switch(type)
			{
				case TLFNodeType.LEAF:
					return makeLeafImpl();
					break;
				case TLFNodeType.CONTAINER:
					return makeContainerImpl();
					break;
			}
			
			return _ITLFNodeImpl;
		}
		
		private function makeLeafImpl(text:String = ''):ITLFNode
		{
			if(_ITLFNodeImpl is LeafImpl)
				return _ITLFNodeImpl;
			
			var _impl:ITLFNode = new LeafImpl(this, text);
			
			if(_ITLFNodeImpl)
			{
				_ITLFNodeImpl.contentElement = null;
				removeChildren(children);
			}
			
			return _ITLFNodeImpl = _impl;
		}
		
		private function makeContainerImpl():ITLFNode
		{
			if(_ITLFNodeImpl is ContainerImpl)
				return _ITLFNodeImpl;
			
			if(_ITLFNodeImpl)
			{
				_ITLFNodeImpl.contentElement = null;
			}
			
			return _ITLFNodeImpl = new ContainerImpl(this);
		}
	}
}
import flash.text.engine.*;

import org.tinytlf.ITextEngine;
import org.tinytlf.model.*;
import org.tinytlf.styles.*;

internal class NodeImpl extends StyleAwareActor implements ITLFNodeParent
{
	public function NodeImpl(owner:ITLFNodeParent)
	{
		super();
		this.owner = owner;
	}
	
	protected var owner:ITLFNodeParent;
	
	private var cElement:ContentElement;
	
	public function get contentElement():ContentElement
	{
		return cElement;
	}
	
	public function set contentElement(value:ContentElement):void
	{
		cElement = value;
	}
	
	public function get engine():ITextEngine
	{
		return owner.engine;
	}
	
	public function set engine(textEngine:ITextEngine):void
	{
		owner.engine = textEngine;
	}
	
	public function get length():int
	{
		return 0;
	}
	
	public function get name():String
	{
		return null;
	}
	
	public function set name(value:String):void
	{
	}
	
	public function get text():String
	{
		return null;
	}
	
	public function get type():String
	{
		return null;
	}
	
	public function get parent():ITLFNodeParent
	{
		return null;
	}
	
	public function insert(value:Object, at:int):ITLFNode
	{
		return null;
	}
	
	public function remove(start:int, end:int = int.MAX_VALUE):ITLFNode
	{
		return null;
	}
	
	public function split(at:int):ITLFNode
	{
		return null;
	}
	
	public function merge(start:int, end:int):ITLFNode
	{
		return null;
	}
	
	public function clone(start:int = 0, end:int = int.MAX_VALUE):ITLFNode
	{
		return null;
	}
	
	public function getLeaf(at:int):ITLFNode
	{
		return null;
	}
	
	public function regenerateStyles():void
	{
		owner.regenerateStyles();
	}
	
	public function get numChildren():int
	{
		return owner.numChildren;
	}
	
	public function addChild(node:ITLFNode):ITLFNode
	{
		return owner.addChild(node);
	}
	
	public function addChildAt(node:ITLFNode, index:int):ITLFNode
	{
		return owner.addChildAt(node, index);
	}
	
	public function addChildren(kids:Vector.<ITLFNode>):Vector.<ITLFNode>
	{
		return owner.addChildren(kids);
	}
	
	public function removeChild(node:ITLFNode):ITLFNode
	{
		return owner.removeChild(node);
	}
	
	public function removeChildAt(index:int):ITLFNode
	{
		return owner.removeChildAt(index);
	}
	
	public function removeChildren(kids:Vector.<ITLFNode>):Vector.<ITLFNode>
	{
		return owner.removeChildren(kids);
	}
	
	public function getChildAt(index:int):ITLFNode
	{
		return owner.getChildAt(index);
	}
	
	public function getChildIndex(node:ITLFNode):int
	{
		return owner.getChildIndex(node);
	}
	
	public function getChildPosition(index:int):int
	{
		return owner.getChildPosition(index);
	}
	
	public function getChildIndexAtPosition(at:int):int
	{
		return owner.getChildIndexAtPosition(at);
	}
	
	public function swapChildren(child1:ITLFNode, child2:ITLFNode):void
	{
		owner.swapChildren(child1, child2);
	}
}

internal class ContainerImpl extends NodeImpl implements ITLFNode
{
	public function ContainerImpl(owner:ITLFNodeParent)
	{
		super(owner);
		
		name = 'container';
	}
	
	override public function toString():String
	{
		var s:String = '<' + owner.name + owner.style.toString() + '>';
		for(var i:int = 0, n:int = numChildren; i < n; i += 1)
			s += getChildAt(i).toString();
		
		s += '</' + owner.name + '>';
		
		return s;
	}
	
	override public function get length():int
	{
		return text.length;
	}
	
	private var _name:String = '';
	
	override public function get name():String
	{
		return _name;
	}
	
	override public function set name(value:String):void
	{
		if(value == _name)
			return;
		
		_name = value;
	}
	
	override public function get text():String
	{
		var s:String = '';
		for(var i:int = 0, n:int = numChildren; i < n; i += 1)
			s += ITLFNode(getChildAt(i)).text;
		
		return s;
	}
	
	override public function get type():String
	{
		return TLFNodeType.CONTAINER;
	}
	
	override public function get parent():ITLFNodeParent
	{
		return owner.parent;
	}
	
	override public function set contentElement(value:ContentElement):void
	{
		if(!value || (value is GroupElement))
			super.contentElement = value;
	}
	
	override public function insert(value:Object, at:int):ITLFNode
	{
		var index:int = getChildIndexAtPosition(at);
		var child:ITLFNode = ITLFNode(getChildAt(index));
		return child.insert(value, at - getChildPosition(index));
	}
	
	override public function remove(start:int, end:int = int.MAX_VALUE):ITLFNode
	{
		if(start < 0)
			start = 0;
		
		var len:int = length;
		if(end > len)
			end = len;
		
		if(start == 0 && end == len)
		{
			parent.removeChild(owner);
			contentElement = null;
			
			return parent;
		}
		
		//start
		var index:int = getChildIndexAtPosition(start);
		var endIndex:int = getChildIndexAtPosition(end);
		var position:int = getChildPosition(index);
		var child:ITLFNode = ITLFNode(getChildAt(index));
		var tmp:int = child.length;
		child.remove(start - position, end - position);
		
		if(child.parent == null)
			--endIndex;
		
		position += tmp;
		
		//all the nodes between and including the end
		while(++index <= endIndex)
		{
			child = getChildAt(index);
			tmp = child.length;
			child.remove(0, end - position);
			position += tmp;
		}
		
		return this;
	}
	
	override public function split(at:int):ITLFNode
	{
		if(at == 0 || at == length)
			return this;
		
		var index:int = getChildIndexAtPosition(at);
		return getChildAt(index).split(at - getChildPosition(index));
	}
	
	override public function merge(start:int, end:int):ITLFNode
	{
		if(start < 0)
			start = 0;
		
		var len:int = length;
		if(end > len)
			end = len;
		
		split(start);
		split(end);
		
		var index:int = getChildIndexAtPosition(start);
		var node:ITLFNode = getLeaf(index);
		node.merge(start, end);
		
		var endIndex:int = getChildIndexAtPosition(end);
		++index;
		
		while(index < endIndex)
		{
			node.insert(getChildAt(index).text, node.length);
			removeChildAt(index);
			--endIndex;
		}
		
		return this;
	}
	
	override public function clone(start:int = 0, end:int = int.MAX_VALUE):ITLFNode
	{
		if(start < 0)
			start = 0;
		
		var len:int = length;
		if(end > len)
			end = len;
		
		var node:TLFNode = new TLFNode();
		node.name = owner.name;
		applyTo(node);
		
		var index:int = getChildIndexAtPosition(start);
		var pos:int = getChildPosition(index);
		
		while(end > pos && index < numChildren)
		{
			node.addChild(getChildAt(index).clone(start - pos, end - pos));
			pos = getChildPosition(++index);
		}
		
		return node;
	}
	
	override public function getLeaf(at:int):ITLFNode
	{
		var index:int = getChildIndexAtPosition(at);
		return getChildAt(index).getLeaf(at - getChildPosition(index));
	}
	
	private function prune():void
	{
		for(var i:int = 0, n:int = numChildren; i < n; i += 1)
		{
			if(getChildAt(i).length > 0)
				continue;
			
			removeChildAt(i);
			--n;
			--i;
		}
	}
}

internal class LeafImpl extends NodeImpl implements ITLFNode
{
	public function LeafImpl(owner:ITLFNodeParent, text:String)
	{
		super(owner);
		
		name = 'leaf';
		
		_text = text;
	}
	
	override public function toString():String
	{
		if(TLFNode.DEBUG_MODE)
			return '<' + name + '>' + text + '</' + name + '>';
		
		return text ? text : XML(<{name}/>).toXMLString();
	}
	
	override public function get length():int
	{
		return text.length;
	}
	
	override public function get name():String
	{
		return TLFNodeType.LEAF;
	}
	
	override public function set name(value:String):void
	{
	}
	
	private var _text:String = '';
	
	override public function get text():String
	{
		return _text;
	}
	
	override public function get type():String
	{
		return TLFNodeType.LEAF;
	}
	
	override public function get parent():ITLFNodeParent
	{
		return owner.parent;
	}
	
	override public function set contentElement(value:ContentElement):void
	{
		if(!value || !(value is GroupElement))
			super.contentElement = value;
	}
	
	override public function insert(value:Object, at:int):ITLFNode
	{
		if(value is String)
		{
			if(contentElement)
				TextElement(contentElement).replaceText(at, at, String(value));
			
			_text = text.substring(0, at) + String(value) + text.substring(at);
			
			return owner;
		}
		else if(value is ITLFNode)
		{
			owner.split(at);
			owner.addChildAt(value as ITLFNode, 1);
			return owner;
		}
		
		return owner;
	}
	
	override public function remove(start:int, end:int = int.MAX_VALUE):ITLFNode
	{
		if(start < 0)
			start = 0;
		
		if(end > length)
			end = length;
		
		if(start == 0 && end == length)
		{
			_text = '';
			parent.removeChild(owner);
			contentElement = null;
			return parent;
		}
		
		_text = text.substring(0, start) + text.substring(end);
		
		if(contentElement is TextElement)
			TextElement(contentElement).text = _text;
		
		return owner;
	}
	
	override public function split(at:int):ITLFNode
	{
		if(parent)
		{
			var index:int = parent.getChildIndex(owner);
			_text = text.substring(0, at);
			parent.addChildAt(clone(at), index + 1);
			return parent;
		}
		else
		{
			owner.addChildren(new <ITLFNode>[owner.clone(0, at), owner.clone(at)]);
			return owner;
		}
		
		return null;
	}
	
	override public function merge(start:int, end:int):ITLFNode
	{
		return parent;
	}
	
	override public function clone(start:int = 0, end:int = int.MAX_VALUE):ITLFNode
	{
		var node:TLFNode = new TLFNode(text.substring(start, end));
		node.name = owner.name;
		applyTo(node);
		
		return node;
	}
	
	override public function getLeaf(at:int):ITLFNode
	{
		return owner;
	}
}