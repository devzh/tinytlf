package org.tinytlf.html
{
	import org.tinytlf.content.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.sector.*;
	
	public class LineBreakTSF extends TSFactory
	{
		[Inject]
		public var cef:IContentElementFactoryMap;
		
		override public function create(dom:IDOMNode):Array
		{
			const sector:TextSector = injector.instantiate(TextSector);
			sector.paddingBottom = dom['height'];
			return [sector];
		}
	}
}
