package org.tinytlf
{
	import flash.geom.Rectangle;

	public interface TTLFSkin
	{
		function update(block:TTLFBlock, size:Rectangle, fullyRendered:Boolean):Boolean;
	}
}