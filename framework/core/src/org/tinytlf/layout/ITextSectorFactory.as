package org.tinytlf.layout
{
	import org.tinytlf.html.IDOMNode;

	public interface ITextSectorFactory
	{
		function create(dom:IDOMNode):Array/*<TextSector>*/
	}
}