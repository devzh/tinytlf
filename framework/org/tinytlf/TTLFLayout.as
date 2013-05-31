package org.tinytlf
{
	public interface TTLFLayout
	{
		function approximatePosition(container:TTLFBlockContainer, child:TTLFBlock):TTLFLayout;
		function approximateSize(container:TTLFBlockContainer, child:TTLFBlock):TTLFLayout;
		
		function finalizePosition(container:TTLFBlockContainer, child:TTLFBlock):TTLFLayout;
		function finalizeSize(container:TTLFBlockContainer, child:TTLFBlock):TTLFLayout;
		
		function finalize():TTLFLayout;
	}
}