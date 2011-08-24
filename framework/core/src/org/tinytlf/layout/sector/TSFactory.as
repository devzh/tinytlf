package org.tinytlf.layout.sector
{
	import org.tinytlf.html.*;
	import org.tinytlf.layout.ITextSectorFactory;
	import org.tinytlf.layout.ITextSectorFactoryMap;

	public class TSFactory implements ITextSectorFactory
	{
		[Inject]
		public var tsfm:ITextSectorFactoryMap;
		
		public function create(dom:IDOMNode):Array/*<TextSector>*/
		{
			const sectors:Array = [];
			
			dom.
				children.
				forEach(function(child:IDOMNode, ...args):void{
					sectors.push.apply(null, tsfm.instantiate(child.name).create(child));
				});
			
			return sectors;
		}
	}
}