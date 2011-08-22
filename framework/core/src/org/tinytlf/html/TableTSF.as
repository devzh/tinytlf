package org.tinytlf.html
{
	import org.tinytlf.content.*;
	import org.tinytlf.layout.*;
	
	public class TableTSF extends TSFactory
	{
		[Inject]
		public var cef:IContentElementFactoryMap;
		
		override public function create(dom:IDOMNode):Array
		{
			return [];
		}
	}
}