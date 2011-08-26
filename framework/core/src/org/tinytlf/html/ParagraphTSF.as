package org.tinytlf.html
{
	import flash.text.engine.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.content.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.sector.*;
	
	public class ParagraphTSF extends TSFactory
	{
		[Inject]
		public var cef:IContentElementFactoryMap;
		
		override public function create(dom:IDOMNode):Array
		{
			const sector:TextSector = injector.instantiate(TextSector);
			sector.textBlock = new TextBlock(cef.instantiate(dom.name).create(dom));
			sector.mergeWith(dom);
			sector.percentWidth = 100;
			return [sector];
		}
	}
}