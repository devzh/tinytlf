/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.text.engine.*;
    import flash.utils.*;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.core.StyleAwareActor;
    import org.tinytlf.layout.ITextContainer;

    public class TextDecoration extends StyleAwareActor implements ITextDecoration
    {
        public function TextDecoration(styleObject:Object = null)
        {
            super(styleObject);
        }

        private var _containers:Vector.<ITextContainer>;
        public function get containers():Vector.<ITextContainer>
        {
            return _containers;
        }

        public function set containers(textContainers:Vector.<ITextContainer>):void
        {
            if (textContainers === _containers)
                return;

            _containers = textContainers;
        }

        protected var _engine:ITextEngine;

        public function get engine():ITextEngine
        {
            return _engine;
        }

        public function set engine(textEngine:ITextEngine):void
        {
            if (textEngine == _engine)
                return;

            _engine = textEngine;
        }

        public function setup(layer:int = 0, ...args):Vector.<Rectangle>
        {
            var bounds:Vector.<Rectangle> = new <Rectangle>[];

            if (args.length <= 0)
                return bounds;

            var arg:* = args[0];

            if (arg is ContentElement)
            {
                bounds = getBoundsForContentElement(arg);

                ////
                //  When you decorate a ContentElement, there's no way to 
                //  associate it with the ITextContainer[s] that it renders in. 
                //  Here we grab every container that holds TextLines for the 
                //  element.
                //  
                //  @TODO
                //  It might be better if this exists somewhere else.
                //  Theoretically the ITextLayout's layout routine could update 
                //  ITextDecor's decorations that are keyed off ContentElements
                //  as the lines are rendering, but I'm almost certain this would
                //  require special API to stay efficient.
                ////
                
                var lines:Vector.<TextLine> = getTextLines(arg);
                var temp:Dictionary = new Dictionary(true);
                while (lines.length)
                    temp[engine.layout.getContainerForLine(lines.shift())] = true;

                for (var c:* in temp)
                    containers.push(c);

                temp = null;
            }
            else if (arg is TextLine)
            {
                var tl:TextLine = arg as TextLine;
                bounds.push(tl.getBounds(tl.parent));
            }
            else if (arg is Rectangle)
            {
                bounds.push(arg);
            }
            else if (arg is Vector.<Rectangle>)
            {
                bounds = bounds.concat(arg);
            }
            
            associateBoundsWithContainers(bounds, layer);

            return bounds;
        }

        public function draw(bounds:Vector.<Rectangle>):void
        {
        }

        public function destroy():void
        {
            rectToSpriteMap = null;
            _containers = null;
            _engine = null;
        }

        private var rectToSpriteMap:Dictionary;

        protected function associateBoundsWithContainers(bounds:Vector.<Rectangle>, layer:int = 0):void
        {
            ////
            //  Since decorations can render across multiple containers,
            //  associate each bounds rectangle with the shapes sprite that
            //  belongs to the container which this decoration renders into.
            ////

            var copy:Vector.<Rectangle> = bounds.concat();
            var rect:Rectangle;
            var container:ITextContainer;
            var doc:DisplayObjectContainer;

            rectToSpriteMap = new Dictionary(true);

            while (copy.length)
            {
                rect = copy.pop();
                rect.inflate(1, 1);
                for each(container in containers)
                {
                    doc = container.target;
                    if (rect.intersects(doc.getBounds(doc.parent)))
                    {
                        rect.inflate(-1, -1);
                        rectToSpriteMap[rect] = resolveLayer(container.shapes, layer);
                        break;
                    }
                }

                if (!(rect in rectToSpriteMap))
                {
                    throw new Error('Couldn\'t match the Rectangle ' + rect.toString() + ' to any ITextContainer instances. Break and figure out why, thx.');
                }
            }
        }

        private function resolveLayer(shapes:Sprite, layer:int):Sprite
        {
            if (shapes.numChildren > layer)
                return Sprite(shapes.getChildAt(layer));

            var sprite:Sprite;
            var i:int = shapes.numChildren - 1;
            while (++i <= layer)
                sprite = Sprite(shapes.addChildAt(new Sprite(), i));

            return sprite;
        }

        private function roundValues(rect:Rectangle):void
        {
            rect.bottom = Math.round(rect.bottom);
            rect.height = Math.round(rect.height);
            rect.left = Math.round(rect.left);
            rect.right = Math.round(rect.right);
            rect.top = Math.round(rect.top);
            rect.width = Math.round(rect.width);
            rect.x = Math.round(rect.x);
            rect.y = Math.round(rect.y);
        }

        protected function getShapeForRectangle(rect:Rectangle):Sprite
        {
            return rectToSpriteMap[rect];
        }

        protected function getBoundsForContentElement(element:ContentElement):Vector.<Rectangle>
        {
            var bounds:Vector.<Rectangle> = new <Rectangle>[];
            var regions:Vector.<TextLineMirrorRegion> = getMirrorRegions(element);
            if (regions.length <= 0)
                return bounds;

            var region:TextLineMirrorRegion;
            var rect:Rectangle;
            var line:DisplayObjectContainer;

            while (regions.length > 0)
            {
                region = regions.pop();
                rect = region.bounds.clone();

                line = region.textLine;

                rect.x += line.x;
                rect.y += line.y;

                bounds.push(rect);
            }

            return bounds;
        }

        protected function getTextBlock(element:ContentElement):TextBlock
        {
            if (!element)
                return null;

            return element.textBlock;
        }

        protected function getTextLines(element:ContentElement):Vector.<TextLine>
        {
            var lines:Vector.<TextLine> = new <TextLine>[];
            var block:TextBlock = getTextBlock(element);
            if (!block)
                return lines;

            var firstLine:TextLine = block.getTextLineAtCharIndex(element.textBlockBeginIndex);
            var lastLine:TextLine = block.getTextLineAtCharIndex(element.textBlockBeginIndex + element.rawText.length - 1);

            do
            {
                lines.push(firstLine);
                firstLine = firstLine == lastLine ?
                        lastLine :
                        firstLine.nextLine;
            }
            while (firstLine && firstLine != lastLine);

            if (lines.indexOf(lastLine) == -1)
                lines.push(lastLine)

            return lines;
        }

        protected function getMirrorRegions(element:ContentElement):Vector.<TextLineMirrorRegion>
        {
            var regions:Vector.<TextLineMirrorRegion> = new <TextLineMirrorRegion>[];
            var lines:Vector.<TextLine> = getTextLines(element);
            var region:TextLineMirrorRegion;

            if (element is GroupElement)
            {
                var elem:ContentElement;
                var n:int = GroupElement(element).elementCount;
                for (var i:int = 0; i < n; i++)
                {
                    elem = GroupElement(element).getElementAt(i);
                    regions = regions.concat(getMirrorRegions(elem));
                }
            }

            var line:TextLine;

            while (lines.length > 0)
            {
                line = lines.pop();
                if (line.validity != TextLineValidity.VALID)
                    continue;

                region = line.getMirrorRegion(element.eventMirror);
                if (region)
                    regions.push(region);
            }

            return regions;
        }

        private var dispatcher:EventDispatcher = new EventDispatcher();

        public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void
        {
            dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }

        public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
        {
            dispatcher.removeEventListener(type, listener, useCapture);
        }

        public function dispatchEvent(event:Event):Boolean
        {
            return dispatcher.dispatchEvent(event);
        }

        public function hasEventListener(type:String):Boolean
        {
            return dispatcher.hasEventListener(type);
        }

        public function willTrigger(type:String):Boolean
        {
            return dispatcher.willTrigger(type);
        }

        //Statically generate a map of the properties in this object
        generatePropertiesMap(new TextDecoration());
    }
}

