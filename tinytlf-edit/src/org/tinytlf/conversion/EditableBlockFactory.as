package org.tinytlf.conversion
{
	import flash.text.engine.*;
	
	import org.tinytlf.analytics.IVirtualizer;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.model.*;
	import org.tinytlf.model.xml.TagSoup;
	import org.tinytlf.util.*;
	import org.tinytlf.util.fte.TextBlockUtil;
	
	/**
	 * EditableBlockFactory keeps track of TextBlocks with an eye towards an on
	 * the editable model.
	 */
	public class EditableBlockFactory extends TextBlockFactoryBase implements ITextBlockFactory
	{
		public function EditableBlockFactory()
		{
			virtualizer = new EditableVirtualizer();
		}
		
		override public function preRender():void
		{
			var textBlockVirtualizer:IVirtualizer = engine.layout.textBlockVirtualizer;
			var contentVirtualizer:IVirtualizer = engine.blockFactory.contentVirtualizer;
			
			if(root.numChildren <= 0)
			{
				textBlockVirtualizer.clear();
				contentVirtualizer.clear();
				root.addChild(new TLFNode());
				return;
			}
			
			var n:int = textBlockVirtualizer.length;
			var node:ITLFNode;
			var element:ContentElement;
			var block:TextBlock;
			var lp:LayoutProperties;
			
			for(var i:int = 0; i < n; i += 1)
			{
				block = textBlockVirtualizer.getItemFromIndex(i);
				lp = TinytlfUtil.getLP(block);
				
				if(i >= root.numChildren)
				{
					lp.model = null;
					TextBlockUtil.checkIn(block);
					textBlockVirtualizer.dequeueAt(i);
					continue;
				}
				
				node = root.getChildAt(i);
				
				if(lp.model == node)
				{
					element = getElementFactory(node.name).execute(node);
					if(block.content != element)
						block.content = element;
				}
				else
				{
					TextBlockUtil.checkIn(block);
					textBlockVirtualizer.dequeueAt(i);
					block = textBlockGenerator.generate(node, getElementFactory(node.name));
					lp.model = node;
					textBlockVirtualizer.enqueueAt(block, i, 1);
				}
			}
		}
		
		override public function getTextBlock(index:int):TextBlock
		{
			if(index >= numBlocks)
				return null;
			
			var textBlockVirtualizer:IVirtualizer = engine.layout.textBlockVirtualizer;
			var block:TextBlock = textBlockVirtualizer.getItemFromIndex(index);
			
			var node:ITLFNode = root.getChildAt(index);
			
			if(!block)
				block = textBlockGenerator.generate(node, getElementFactory(node.name));
			
			TinytlfUtil.getLP(block).model = node;
			
			return block;
		}
		
		override public function getElementFactory(element:*):IContentElementFactory
		{
			if(hasElementFactory(element))
				return super.getElementFactory(element);
			
			var adapter:IContentElementFactory = new TLFNodeElementFactory();
			IContentElementFactory(adapter).engine = engine;
			return adapter;
		}
		
		override public function get numBlocks():int
		{
			return root.numChildren;
		}
		
		private var root:ITLFNodeParent = new TLFNode();
		
		override public function set data(value:Object):void
		{
			if((value is String) || (value is XML) || (value is XMLList))
			{
				XML.prettyPrinting = false;
				XML.ignoreWhitespace = false;
				
				root = buildNode(TagSoup.toXML(value.toString(), true)) as ITLFNodeParent;
				value = root;
				
				var textBlockVirtualizer:IVirtualizer = engine.layout.textBlockVirtualizer;
				var contentVirtualizer:IVirtualizer = engine.blockFactory.contentVirtualizer;
				
				textBlockVirtualizer.clear();
				contentVirtualizer.clear();
				
			}
			
			super.data = value;
		}
		
		private function buildNode(child:XML):ITLFNode
		{
			var node:TLFNode = new TLFNode(	child.nodeKind() != 'element' ?
											child.toString() :
											null);
			node.engine = engine;
			node.name = child.localName();
			node.mergeWith(XMLUtil.buildKeyValueAttributes(child.attributes()));
			
			for each(var x:XML in child.*)
			{
			    node.addChild(buildNode(x));
			}
			
			return node;
		}
	}
}
import org.tinytlf.analytics.Virtualizer;
import org.tinytlf.model.ITLFNode;

internal class EditableVirtualizer extends Virtualizer
{
	override public function get size():int
	{
		var root:ITLFNode = engine.blockFactory.data as ITLFNode;
		return root ? root.length : super.size;
	}
}