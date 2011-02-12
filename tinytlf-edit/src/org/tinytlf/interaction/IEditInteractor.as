package org.tinytlf.interaction
{
	import org.tinytlf.operations.ITextOperation;

	public interface IEditInteractor extends ITextInteractor
	{
		/**
		 * Pushes an operation onto the operation stack. Does not execute the
		 * operation.
		 * 
		 * @returns The ITextOperation that was passed in.
		 */
		function push(op:ITextOperation):ITextOperation;
		
		/**
		 * Decrements the operation stack iterator to the previous operation, 
		 * if it exists. This does not execute the operation.
		 * 
		 * @returns The previous operation in the operation stack, or a
		 * NullOperation implementation if there is no previous operation.
		 */
		function undo():ITextOperation;
		
		/**
		 * Increments the operation stack pointer to the next operation, if it
		 * exists. This does not execute the operation.
		 * 
		 * @returns The next operation in the operation stack, or a 
		 * NullOperation implementation if there is no next operation.
		 */
		function redo():ITextOperation;
		
		/**
		 * Clears operations off the stack, starting with the most recently
		 * added.
		 */
		function clearOperations(num:int = -1):void;
	}
}