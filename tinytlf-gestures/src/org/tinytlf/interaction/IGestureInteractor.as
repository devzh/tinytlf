/*
* Copyright (c) 2010 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf.interaction
{
	import org.tinytlf.gestures.IGesture;

    public interface IGestureInteractor extends ITextInteractor
    {
        function addGesture(gesture:IGesture, ...behaviors):IGesture;
        function removeGesture(gesture:IGesture):IGesture;
		
		function removeAllGestures():void;
        
        function get gestures():Vector.<IGesture>;
    }
}