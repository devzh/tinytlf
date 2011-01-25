package org.tinytlf.layout.factories
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.model.*;
	import org.tinytlf.model.xml.TagSoup;
	import org.tinytlf.util.*;
	import org.tinytlf.util.fte.TextBlockUtil;
	
	/**
	 * EditableBlockFactory generates editable TextBlocks. wOOt.
	 */
	public class EditableBlockFactory extends TextBlockFactoryBase implements ITextBlockFactory
	{
		public function EditableBlockFactory()
		{
			super();
		}
		
		override public function getTextBlock(index:int):TextBlock
		{
			if(!root)
				return super.getTextBlock(index);
			
			if(index < root.numChildren)
				return super.getTextBlock(index);
			
			return null;
		}
		
		override public function endRender():void
		{
			super.endRender();
			
			//De-cache any blocks after the end index.
			var j:int = -1;
			var n:int = root.numChildren;
			for(var i:int = listIndex + 1; i < n; i += 1)
			{
				analytics.removeBlockAt(i);
			}
		}
		
		private var root:ITLFNodeParent = new TLFNode();
		
		override protected function generateTextBlock(index:int):TextBlock
		{
			var block:TextBlock = super.generateTextBlock(index);
			var lp:LayoutProperties;
			
			if(block && block.content)
			{
				lp = TinytlfUtil.getLP(block);
				lp.y = analytics.blockPixelStart(block);
				return block;
			}
			
			var node:ITLFNode = root.getChildAt(index);
			if(!node)
				return null;
			
			if(!node.contentElement)
				node.contentElement = getElementFactory(node.name).execute(node);
			
			lp = TinytlfUtil.getLP(node);
			lp.y = analytics.indexPixelStart(index);
			//Get a block from the pool.
			block ||= TextBlockUtil.checkOut();
			block.content = node.contentElement;
			// Apply the properties of this layout element to the TextBlock.
			// This also sets up the TextBlock justifier.
			lp.applyTo(block);
			block.userData = lp;
			
			return block;
		}
		
		override public function getElementFactory(element:*):IContentElementFactory
		{
			if(!(element in elementAdapterMap))
			{
				var adapter:IContentElementFactory = new TLFNodeElementFactory();
				IContentElementFactory(adapter).engine = engine;
				return adapter;
			}
			
			return super.getElementFactory(element);
		}
		
		override public function set data(value:Object):void
		{
			XML.prettyPrinting = false;
			XML.ignoreWhitespace = false;
			root = buildNode(TagSoup.toXML(value.toString(), true)) as ITLFNodeParent;
			super.data = root;
		}
		
		private function buildNode(child:XML):ITLFNode
		{
			var node:TLFNode;
			
			if(child..*.length() > 0)
			{
				node = new TLFNode();
				node.engine = engine;
				node.mergeWith(XMLUtil.buildKeyValueAttributes(child.attributes()));
				
				if(child..*.length() == 1)
				{
					node.addChild(new TLFNode(child.toString()));
					node.getChildAt(node.numChildren - 1).engine = engine;
				}
				else
				{
					for each(var x:XML in child.*)
					{
						node.addChild(buildNode(x));
					}
				}
				
				node.name = child.localName();
			}
			else if(child.nodeKind() == 'text')
			{
				node = new TLFNode(child.toString());
				node.engine = engine;
			}
			
			return node;
		}
	}
}