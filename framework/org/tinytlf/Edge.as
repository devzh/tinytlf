package org.tinytlf
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public final class Edge
	{
		public static const empty:Edge = new Edge();
		
		public function Edge(top:Number = 0, right:Number = 0, bottom:Number = 0, left:Number = 0)
		{
			setTo(top, right, bottom, left);
		}
		
		public const topLeft:Point = new Point();
		public const bottomRight:Point = new Point();
		
		public function get top():Number {
			return topLeft.y;
		}
		
		public function get right():Number {
			return bottomRight.x;
		}
		
		public function get bottom():Number {
			return bottomRight.y;
		}
		
		public function get left():Number {
			return topLeft.x;
		}
		
		public function get width():Number {
			return bottomRight.x - topLeft.x;
		}
		
		public function get height():Number {
			return bottomRight.y - topLeft.y;
		}
		
		public function setTo(t:Number, r:Number, b:Number, l:Number):Edge {
			topLeft.y = t == t ? t : topLeft.y;
			bottomRight.x = r == r ? r : bottomRight.x;
			bottomRight.y = b == b ? b : bottomRight.y;
			topLeft.x = l == l ? l : topLeft.x;
			
			return this;
		}
		
		public function addTo(edge:Edge):Edge {
			return new Edge(
				top + edge.top,
				right + edge.right,
				bottom + edge.bottom,
				left + edge.left
			);
		}
		
		public function subtractFrom(edge:Edge):Edge {
			return new Edge(
				top - edge.top,
				right - edge.right,
				bottom - edge.bottom,
				left - edge.left
			);
		}
		
		public function compareTo(edge:Edge):Boolean {
			return (
				edge.top == top &&
				edge.right == right &&
				edge.bottom == bottom &&
				edge.left == left
			);
		}
		
		public function clone():Edge {
			return new Edge(top, right, bottom, left);
		}
		
		public function isEmpty():Boolean {
			return (
				top == 0 &&
				right == 0 &&
				bottom == 0 &&
				left == 0
			);
		}
		
		public function toRectangle():Rectangle {
			return new Rectangle(left, top, width, height);
		}
		
		public function toString():String {
			return '(w: ' + width + ', h: ' + height + ', t: ' + top + ', r: ' + right + ', b: ' + bottom + ', l: ' + left + ')';
		}
	}
}