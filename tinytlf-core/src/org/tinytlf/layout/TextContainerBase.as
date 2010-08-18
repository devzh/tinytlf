/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.text.engine.LineJustification;
    import flash.text.engine.SpaceJustifier;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    import flash.text.engine.TextLineValidity;
    import flash.utils.Dictionary;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.descriptions.TextAlign;
    
    public class TextContainerBase implements ITextContainer
    {
        public function TextContainerBase(container:DisplayObjectContainer, 
										  explicitWidth:Number = NaN, 
										  explicitHeight:Number = NaN)
        {
            this.target = container;
            
            _explicitWidth = explicitWidth;
            _explicitHeight = explicitHeight;
        }
        
        protected var _target:DisplayObjectContainer;
        
        public function get target():DisplayObjectContainer
        {
            return _target;
        }
        
        public function set target(doc:DisplayObjectContainer):void
        {
            if(doc == _target)
                return;
            
            _target = doc;
            
            shapes = Sprite(target.addChild(new Sprite()));
        }
        
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
        
        private var _shapes:Sprite;
        
        public function get shapes():Sprite
        {
            return _shapes;
        }
        
        public function set shapes(shapesContainer:Sprite):void
        {
            if(shapesContainer === _shapes)
                return;
            
            var children:Array = [];
            if(shapes)
            {
                while(shapes.numChildren)
                    children.push(shapes.removeChildAt(0));
                if(shapes.parent && shapes.parent.contains(shapes))
                    shapes.parent.removeChild(shapes);
            }
            
            _shapes = shapesContainer;
            
            if(shapes)
                while(children.length)
                    shapes.addChild(children.shift());
        }
        
        protected var _explicitHeight:Number = NaN;
        
        public function get explicitHeight():Number
        {
            return _explicitHeight;
        }
        
        public function set explicitHeight(value:Number):void
        {
			if(value === _explicitHeight)
				return;
			
            _explicitHeight = value;
			engine.invalidate();
        }
        
        protected var _explicitWidth:Number = NaN;
        
        public function get explicitWidth():Number
        {
            return _explicitWidth;
        }
        
        public function set explicitWidth(value:Number):void
        {
			if(value === _explicitWidth)
				return;
			
            _explicitWidth = value;
			engine.invalidate();
        }
        
        protected var width:Number = 0;
        
        public function get measuredWidth():Number
        {
            return width;
        }
        
        protected var height:Number = 0;
        
        public function get measuredHeight():Number
        {
            return height;
        }
        
        protected var lines:Dictionary = new Dictionary(false);
        
        public function hasLine(line:TextLine):Boolean
        {
            if(line in lines)
                return true;
            
            return false;
        }
        
        public function clear():void
        {
            for(var line:* in lines)
			{
                removeLine(line);
				target.removeChild(line);
			}
            
			height = 0;
			width = 0;
        }
        
        public function resetShapes():void
        {
            if(!shapes)
                return;
            
            shapes.graphics.clear();
            
            while(shapes.numChildren)
                shapes.removeChildAt(0);
        }
        
        public function prepLayout():void
        {
			if(target.numChildren)
			{
				var child:DisplayObject = target.getChildAt(target.numChildren - 1);
	            height = child.y + child.height;
			}
			else
			{
				width = 0;
				height = 0;
			}
        }
		
		public function cleanupLines(fromBlock:TextBlock):void
		{
			var blockLines:Dictionary = new Dictionary(true);
			var line:TextLine = fromBlock.firstLine;
			while(line)
			{
				blockLines[line] = true;
				line = line.nextLine;
			}
			
			for(var obj:* in lines)
			{
				line = TextLine(obj);
				if(line.textBlock == fromBlock && !(line in blockLines))
				{
					target.removeChild(line);
					removeLine(line);
				}
			}
			
			blockLines = null;
		}
        
        public function layout(block:TextBlock, line:TextLine):TextLine
        {
            setupBlockJustifier(block);
            
            var props:LayoutProperties = getLayoutProperties(block);
			var y:Number = height + props.paddingTop;
			
            if(!isNaN(explicitHeight) && y > explicitHeight)
                return line;
            
            line = createLine(block, line);
            
            while(line)
            {
                y += line.ascent;
                line.y = y;
                y += line.descent + props.lineHeight;
				
				addLine(line)
                target.addChild(line);
                
                if(!isNaN(explicitHeight) && y > explicitHeight)
                    return line;
                
                line = createLine(block, line);
            }
            
			height = y + props.paddingBottom;
			
            return null;
        }
		
		public function recreateTextLine(line:TextLine):TextLine
		{
			var hasFocus:Boolean = line.stage.focus === line;
			
			var block:TextBlock = line.textBlock;
			
			var x:Number = line.x;
			var y:Number = line.y;
			var index:int = target.getChildIndex(line);
			
			target.removeChild(line);
			removeLine(line);
			
			line = block.createTextLine(line.previousLine, line.specifiedWidth, 0, true);
//			line = block.recreateTextLine(line, line.previousLine, line.specifiedWidth, 0, true);
			
			target.addChildAt(line, index);
			addLine(line);
			
			line.x = x;
			line.y = y;
			
			if(hasFocus)
				target.stage.focus = line;
			
			return line;
		}
        
        protected function createLine(block:TextBlock, line:TextLine = null):TextLine
        {
            line = block.createTextLine(line, getLineWidth(block, line), 0, true);
            
            if(!line)
                return null;
			
			layoutLine(block, line);
			
			return line;
		}
		
		protected function layoutLine(block:TextBlock, line:TextLine):void
		{
            var props:LayoutProperties = getLayoutProperties(block);
			var w:Number = isNaN(props.width) ? isNaN(explicitWidth) ? 1000000 : explicitWidth : props.width;
            var lineWidth:Number = line.width;
			if(lineWidth > width)
				width = lineWidth;
			
			var x:Number = 0;
			
			if(!line.previousLine)
				x += props.textIndent;
			
            switch(props.textAlign)
            {
                case TextAlign.LEFT:
                case TextAlign.JUSTIFY:
                    x += props.paddingLeft;
                    break;
                case TextAlign.CENTER:
                    x = (w - lineWidth) * 0.5;
                    break;
                case TextAlign.RIGHT:
                    x = w - lineWidth + props.paddingRight;
                    break;
            }
            
            line.x = x;
        }
		
		protected function getLineWidth(block:TextBlock, previousLine:TextLine):Number
		{
			var props:LayoutProperties = getLayoutProperties(block);
			var w:Number = isNaN(props.width) ? isNaN(explicitWidth) ? 1000000 : explicitWidth : props.width;
			var lineWidth:Number = w;
			
			if(previousLine == null)
			{
				lineWidth -= props.textIndent;
			}
			
			lineWidth -= props.paddingLeft;
			lineWidth -= props.paddingRight;
			return lineWidth;
		}
        
        protected function removeLine(line:TextLine):void
        {
			line.userData = null;
			
            delete lines[line];
        }
        
        protected function addLine(line:TextLine):void
        {
			lines[line] = true;
			line.userData = engine;
			line.doubleClickEnabled = true;
			engine.interactor.getMirror(line);
        }
        
        protected function setupBlockJustifier(block:TextBlock):void
        {
            var props:LayoutProperties = getLayoutProperties(block);
            var justification:String = LineJustification.UNJUSTIFIED;
            
            if(props.textAlign == TextAlign.JUSTIFY)
                justification = LineJustification.ALL_BUT_LAST;
            
            if(!block.textJustifier || block.textJustifier.lineJustification != justification)
            {
                block.textJustifier = new SpaceJustifier("en", justification, props.spaceJustify);
            }
        }
        
        protected function getLayoutProperties(block:TextBlock):LayoutProperties
        {
            return (block.userData as LayoutProperties) || new LayoutProperties();
        }
    }
}

