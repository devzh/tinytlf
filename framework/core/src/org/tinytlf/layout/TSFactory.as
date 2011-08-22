package org.tinytlf.layout
{
	import org.tinytlf.html.*;

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