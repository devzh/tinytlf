package org.tinytlf.conversion
{
	import flash.text.engine.*;
	
	import org.tinytlf.xml.TagSoup;

	public class HTMLBlockFactory extends TextBlockFactoryBase
	{
		public function HTMLBlockFactory()
		{
			super();
		}
		
		override public function getTextBlock(index:int):TextBlock
		{
			if(index >= numBlocks)
				return null;
			
			var block:TextBlock = contentVirtualizer.getItemFromIndex(index);
			
			if(!block)
			{
				var paragraph:IHTMLNode = new HTMLNode(paragraphs[index]);
				paragraph.mergeWith(engine.styler);
				paragraph.mergeWith(engine.styler.describeElement(paragraph.inheritanceList.split(' ')));
				block = textBlockGenerator.generate(paragraph, getElementFactory(paragraph.name));
			}
			
			if(!block)
				return null;
			
			contentVirtualizer.enqueueAt(block, index, block.content.rawText.length);
			
			return block;
		}
		
		private var paragraphs:XMLList = new XMLList();
		
		override public function set data(value:Object):void
		{
			if(value is String)
			{
				XML.prettyPrinting = false;
				XML.ignoreWhitespace = false;
				value = TagSoup.toXML(String(value), true);
			}
			
			if(value is XMLList)
				value = <root>{value}</root>
			
			if(value is XML)
				paragraphs = XML(value).*;
			
			super.data = value;
		}
		
		override public function get numBlocks():int
		{
			return paragraphs.length();
		}
		
		override public function getElementFactory(element:*):IContentElementFactory
		{
			if(!hasElementFactory(element))
			{
				var adapter:IContentElementFactory = new HTMLNodeElementFactory();
				IContentElementFactory(adapter).engine = engine;
				return adapter;
			}
			
			return super.getElementFactory(element);
		}
	}
}