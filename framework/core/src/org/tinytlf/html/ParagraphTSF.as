package org.tinytlf.html
{
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.content.IContentElementFactoryMap;
	import org.tinytlf.layout.*;
	
	public class ParagraphTSF extends TSFactory
	{
		[Inject]
		public var cef:IContentElementFactoryMap;
		
		override public function create(dom:IDOMNode):Array
		{
			const sector:TextSector = new TextSector();
			sector.textBlock = new TextBlock(cef.instantiate(dom.name).create(dom));
			return [sector];
		}
	}
}