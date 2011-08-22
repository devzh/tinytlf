package org.tinytlf
{
	public interface IFactoryMap
	{
		function get defaultFactory():*;
		function set defaultFactory(value:*):void;
		
		function hasMapping(value:*):Boolean;
		
		function mapFactory(value:*, factory:*):void;
		
		function unmapFactory(value:*):Boolean;
		
		function instantiate(value:*):*;
	}
}