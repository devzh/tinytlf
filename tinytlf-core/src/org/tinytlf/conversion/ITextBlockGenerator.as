package org.tinytlf.conversion
{
	import flash.text.engine.TextBlock;

	public interface ITextBlockGenerator
	{
		function generate(data:*, factory:IContentElementFactory):TextBlock;
	}
}