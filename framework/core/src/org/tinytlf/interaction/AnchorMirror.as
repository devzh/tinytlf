package org.tinytlf.interaction
{
	import flash.events.*;
	import flash.net.*;
	import flash.text.engine.*;
	import flash.ui.*;
	
	import org.tinytlf.*;
	import org.tinytlf.decoration.*;
	import org.tinytlf.html.*;
	import org.tinytlf.style.*;
	import org.tinytlf.util.*;
	
	import raix.reactive.*;
	
	public class AnchorMirror extends EventBehavior
	{
		[Inject]
		public var css:CSS;
		
		[Inject]
		public var eff:IElementFormatFactory;
		
		[Inject]
		public var decorator:ITextDecorator;
		
		[Inject]
		public var ibeam:MouseSelectionBehavior;
		
		protected var downCancelable:ICancelable;
		protected var upCancelable:ICancelable;
		protected var moveOutCancelable:ICancelable;
		protected var moveInCancelable:ICancelable;
		
		protected var downHere:Boolean = false;
		protected var visited:Boolean = false;
		protected var active:Boolean = false;
		protected var over:Boolean = false;
		protected var originalMouseValue:String = '';
		
		override protected function subscribe():void
		{
			if(!downCancelable)
			{
				downCancelable = obs.down.
					merge(obs.doubleDown).
					merge(obs.tripleDown).
					filter(intersectionFilter).
					subscribe(onDown);
			}
			if(!upCancelable)
			{
				// Don't filter for intersection, the user could click down here
				// but release up somewhere else.
				upCancelable = obs.up.subscribe(onUp);
			}
		}
		
		override protected function cancel():void
		{
			if(downCancelable)
			{
				downCancelable.cancel();
				downCancelable = null;
			}
			if(upCancelable)
			{
				upCancelable.cancel();
				upCancelable = null;
			}
		}
		
		override protected function onRender(event:Event):void
		{
			over ? watchMoveOut() : watchMoveOver();
			
			super.onRender(event);
		}
		
		protected function onDown(me:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
			downHere = true;
			active = true;
			const activeStyle:Object = css.lookup(dom.cssInheritanceChain.split(' ').join(':active ') + ':active');
			dom.mergeWith(activeStyle);
			refreshDOM(dom);
			invalidate();
		}
		
		protected function onOver(me:MouseEvent):void
		{
			ibeam.enabled = false;
			over = true;
			originalMouseValue = Mouse.cursor;
			Mouse.cursor = MouseCursor.BUTTON;
			
			const hover:Object = css.lookup(dom.cssInheritanceChain + (active ? ':active' : visited ? ':visited' : ':hover'));
			dom.mergeWith(hover);
			refreshDOM(dom);
			invalidate();
		}
		
		protected function onOut(me:MouseEvent):void
		{
			ibeam.enabled = true;
			over = false;
			Mouse.cursor = originalMouseValue || MouseCursor.AUTO;
			const style:Object = css.lookup(dom.cssInheritanceChain + (visited || active ? ':visited' : ''));
			dom.mergeWith(style);
			refreshDOM(dom);
			
			invalidate();
		}
		
		protected function onUp(me:MouseEvent):void
		{
			if(!downHere)
				return;
			
			active = false;
			visited = true;
			
			if(invalidated)
				return;
			
			const visitedStyle:Object = css.lookup(dom.cssInheritanceChain + ':visited');
			dom.mergeWith(visitedStyle);
			refreshDOM(dom);
			invalidate();
			
			const href:String = dom.getStyle('href');
			if(!href)
				return;
			if(href.indexOf('#') == 0)
				return;
			
			navigateToURL(new URLRequest(href), '_blank');
		}
		
		protected function watchMoveOut():void
		{
			if(moveInCancelable)
			{
				moveInCancelable.cancel();
				moveInCancelable = null;
			}
			
			if(!moveOutCancelable)
			{
				moveOutCancelable = obs.move.
					filter(function(me:MouseEvent):Boolean {
						return !intersectionFilter(me);
					}).
					subscribe(function(me:MouseEvent):void {
						onOut(me);
					});
			}
		}
		
		protected function watchMoveOver():void
		{
			if(moveOutCancelable)
			{
				moveOutCancelable.cancel();
				moveOutCancelable = null;
			}
			
			if(!moveInCancelable)
			{
				moveInCancelable = obs.move.
					filter(function(me:MouseEvent):Boolean {
						return intersectionFilter(me);
					}).subscribe(function(me:MouseEvent):void {
						onOver(me);
					});
			}
		}
		
		protected function refreshDOM(dom:IDOMNode):void
		{
			const mirror:AnchorMirror = this;
			for(var i:int = 0, n:int = dom.numChildren; i < n; ++i)
			{
				const child:IDOMNode = dom.getChildAt(i);
				if(child.numChildren)
					refreshDOM(child);
				else if(child.content)
					child.content.elementFormat = eff.getElementFormat(dom);
			}
		}
	}
}
