package org.tinytlf.style
{
	import flash.text.engine.ElementFormat;

	public interface IElementFormatFactory
	{
		function getElementFormat(item:Object):ElementFormat;
	}
}