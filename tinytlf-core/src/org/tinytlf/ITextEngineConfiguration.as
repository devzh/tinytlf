package org.tinytlf
{
	/**
	 * An interface that defines a method for configuring the default
	 * mappings for ITextEngine's member maps. You can pass an instance
	 * of a class which implements this interface to the ITextEngine's
	 * <code>configuration</code> property, and ITextEngine calls
	 * <code>configure</code>.
	 * 
	 * @see org.tinytlf.ITextEngine
	 */
	public interface ITextEngineConfiguration
	{
		function configure(engine:ITextEngine):void;
	}
}