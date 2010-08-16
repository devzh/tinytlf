/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor
{
    import flash.utils.Dictionary;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.ITextContainer;
	
	////
	//  I have some major problems with this implementation:
	//  
	//  1. There's a bug where the decorations' layers are exactly backwards.
	//  2. I don't like how it stores the decorations. Maps of maps of maps is
	//     not cool.
	//  3. It renders every decoration again every time the decorations are 
	//     invalidated. Isn't there a way to know which decorations changed and
	//     only clear/render those? I mean without creating separate
	//     Shapes/Sprites per decoration (ick!).
	//  4. Right now the TextDecoration base class is resolving multi-container
	//     issues, but I feel that should be done here, individual TextDecorations
	//     shouldn't give a shit about which containers they're rendering into.
	//     This also makes it very very hard to write an ITextDecoration that
	//     doesn't extend TextDecoration. 
	//  
	//  Eff.
	////
    
	/**
	 * The decoration actor for tinytlf.
	 * 
	 * @see org.tinytlf.decor.ITextDecoration
	 */
    public class TextDecor implements ITextDecor
    {
        public static const CARET_LAYER:int = 0;
        public static const SELECTION_LAYER:int = 1;
        
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
        
        public function render():void
        {
            var n:int = layers.length;
            var layer:Dictionary;
            var element:*;
            var decorationProp:String;
            var decoration:ITextDecoration;
            
            for(var i:int = 0; i < n; ++i)
            {
                layer = layers[i];
                for(element in layer)
                    for each(decoration in layer[element])
                        if(decoration)
                            decoration.draw(decoration.setup(i, element));
            }
        }
        
        public function removeAll():void
        {
            for(var layer:* in layers)
            {
                for(var element:* in layers[layer])
                {
                    for(var decoration:String in layers[layer][element])
                    {
                        ITextDecoration(layers[layer][element][decoration]).destroy();
                        delete layers[layer][element][decoration];
                    }
                    delete layers[layer][element];
                }
                delete layers[layer];
            }
            
            engine.invalidateDecorations();
        }
        
        protected var layers:Array = [];
        
        public function decorate(element:*, styleObj:Object, layer:int = 2, containers:Vector.<ITextContainer> = null):void
        {
            if(!element || !styleObj)
                return;
            
            //  Resolve the layer business first
            var theLayer:Dictionary = resolveLayer(layer);
            if(!(element in theLayer) || theLayer[element] == null)
            {
                theLayer[element] = new Dictionary(false);
            }
            
            var decoration:ITextDecoration;
            var styleProp:String;
            
            if(styleObj is String && hasDecoration(String(styleObj)))
            {
                theLayer[element][styleObj] = getDecoration(String(styleObj), containers);
            }
            else
            {
                for(styleProp in styleObj)
                {
					//Jesus how many ways do you have to check for not-null?
                    if(hasDecoration(styleProp) && 
						styleObj[styleProp] != null && 
						styleObj[styleProp] !== false && 
						styleObj[styleProp] !== 'false')
                    {
                        decoration = ITextDecoration(theLayer[element][styleProp] = getDecoration(styleProp, containers));
						decoration.style = styleObj;
                    }
                    else if(hasDecoration(styleProp) && styleProp in theLayer[element])
                    {
                        delete theLayer[element][styleProp];
                    }
                }
            }
            
            engine.invalidateDecorations();
        }
        
        /**
         * Undecorate can completely dress down the element passed in, or it can strip
         * out the decoration for a particular property, leaving the others intact.
         */
        public function undecorate(element:* = null, decorationProp:String = null):void
        {
            var i:int = layers.length - 1;
            var layer:Dictionary;
            
            for(; i >= 0; i--)
            {
                layer = Dictionary(layers[i]);
                
                if(!layer)
                    continue;
                
                if(element)
                {
                    if(!(element in layer) || layer[element] == null)
                        continue;
                    
                    if(!decorationProp)
                    {
                        for(var dec:String in layer[element])
                        {
                            ITextDecoration(layer[element][dec]).destroy();
                            delete layer[element][dec];
                        }
                    }
                    else if(decorationProp in layer[element])
                    {
                        ITextDecoration(layer[element][decorationProp]).destroy();
                        delete layer[element][decorationProp];
                    }
                    
                    if(isEmpty(layer[element]))
                    {
                        delete layer[element];
                    }
                }
                else if(decorationProp)
                {
                    for(var e:* in layer)
                    {
                        if(layer[e] == null)
                            continue;
                        
                        if(decorationProp in layer[e])
                        {
                            ITextDecoration(layer[e][decorationProp]).destroy();
                            delete layer[e][decorationProp];
                        }
                        
                        if(isEmpty(layer[e]))
                        {
                            delete layer[e];
                        }
                    }
                }
            }
            
            engine.invalidateDecorations();
        }
        
        private var decorationsMap:Object = {};
        
        public function mapDecoration(styleProp:String, decorationClassOrFactory:Object):void
        {
			if(decorationClassOrFactory)
	            decorationsMap[styleProp] = decorationClassOrFactory;
			else
				unMapDecoration(styleProp);
        }
        
        public function unMapDecoration(styleProp:String):Boolean
        {
            if(!hasDecoration(styleProp))
                return false;
            
            return delete decorationsMap[styleProp];
        }
        
        public function hasDecoration(decorationProp:String):Boolean
        {
            return Boolean(decorationProp in decorationsMap);
        }
        
        public function getDecoration(styleProp:String, containers:Vector.<ITextContainer> = null):ITextDecoration
        {
            if(!hasDecoration(styleProp))
                return null;
            
            var decoration:* = decorationsMap[styleProp];
            if(decoration is Class)
                decoration = ITextDecoration(new decoration());
            else if(decoration is Function)
                decoration = ITextDecoration((decoration as Function)());
            
            if(!decoration)
                return null;
            
            var vec:Vector.<ITextContainer> = new Vector.<ITextContainer>();
            if(containers)
                vec = vec.concat(containers);
            
            ITextDecoration(decoration).containers = vec;
            
            ITextDecoration(decoration).engine = engine;
            
            return ITextDecoration(decoration);
        }
        
        protected function resolveLayer(layer:int):Dictionary
        {
            if(layer < 0)
                layer = 0;
            
            //  Allow a larger layer than we've created so far, but keep the 
            //  Array densly populated. This helps with performance, but also 
            //  allows a developer to specify a deeper level than has been 
            //  created so far. Originally I kept the layers within the bounds 
            //  of the array, but that introduced race condition-y scenarios.
            else if(layer > layers.length)
            {
                var i:int = layers.length - 1;
                while(++i < layer)
                    layers[i] = (i in layers) ? layers[i] : null;
            }
            
            if(!(layers[layer]))
                layers[layer] = new Dictionary(false);
            
            return Dictionary(layers[layer]);
        }
        
        private function isEmpty(dict:Object):Boolean
        {
            if(!dict)
                return true;
            
            for(var prop:* in dict)
                if(dict[prop])
                    return false;
            
            return true;
        }
    }
}
