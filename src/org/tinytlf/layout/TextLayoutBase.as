/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.extensions.layout.factory.xml.XMLBlockFactory;
    import org.tinytlf.layout.factory.ILayoutModelFactory;

    public class TextLayoutBase implements ITextLayout
    {
        protected var _engine:ITextEngine;
        
        public function get engine():ITextEngine
        {
            return _engine;
        }
        
        public function set engine(textEngine:ITextEngine):void
        {
            if(textEngine == _engine)
                return;
            
            _engine = textEngine;
        }

        protected var _textBlockFactory:ILayoutModelFactory;

        public function get textBlockFactory():ILayoutModelFactory
        {
            if(!_textBlockFactory)
                textBlockFactory = new XMLBlockFactory();

            return _textBlockFactory;
        }

        public function set textBlockFactory(value:ILayoutModelFactory):void
        {
            if(value === _textBlockFactory)
                return;

            _textBlockFactory = value;

            _textBlockFactory.engine = engine;
        }

        public function clear():void
        {
            for (var i:int = 0; i < containers.length; i++)
            {
                containers[i].clear();
            }
        }

        public function resetShapes():void
        {
            for (var i:int = 0; i < containers.length; i++)
            {
                containers[i].resetShapes();
            }
        }

        public function render(blocks:Vector.<TextBlock>):void
        {
            if(!containers || !containers.length || !blocks || !blocks.length)
                return;
            
            var blockIndex:int = 0;
            var containerIndex:int = 0;
            
            var block:TextBlock = blocks[0];
            var container:ITextContainer = containers[0];
            container.prepLayout();
            
            var line:TextLine;
            if(block.firstInvalidLine)
                line = block.firstInvalidLine.previousLine;
            
            while(blockIndex < blocks.length)
            {
                block = blocks[blockIndex];
                container = containers[containerIndex];
                
                line = container.layout(block, line);
                
                if(line && ++containerIndex < containers.length)
                {
                    container = containers[containerIndex];
                    container.prepLayout();
                }
                else if(++blockIndex < blocks.length)
                {
                    block = blocks[blockIndex];
                    
                    if(block.firstInvalidLine)
                    {
                        line = block.firstInvalidLine.previousLine;
                    }
                }
                else
                    return;
            }
        }
        
        protected var _containers:Vector.<ITextContainer> = new Vector.<ITextContainer>;
        
        public function get containers():Vector.<ITextContainer>
        {
            return _containers ? _containers.concat() : new Vector.<ITextContainer>;
        }
        
        public function addContainer(container:ITextContainer):void
        {
            if(containers.indexOf(container) != -1)
                return;
            
            _containers.push(container);
            container.engine = engine;
        }
        
        public function removeContainer(container:ITextContainer):void
        {
            var i:int = containers.indexOf(container);
            if(i == -1)
                return;
            
            _containers.splice(i, 1);
            container.engine = null;
        }
        
        public function getContainerForLine(line:TextLine):ITextContainer
        {
            var n:int = containers.length;
            
            for(var i:int = 0; i < n; i++)
            {
                if(containers[i].hasLine(line))
                    return containers[i];
            }
            
            return null;
        }
    }
}

