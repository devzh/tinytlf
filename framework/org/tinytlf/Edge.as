package org.tinytlf
{
	public final class Edge
	{
		public function Edge(top:Number = 0, right:Number = 0, bottom:Number = 0, left:Number = 0)
		{
			setTo(top, right, bottom, left);
		}
		
		private var t:Number = 0;
		private var r:Number = 0;
		private var b:Number = 0;
		private var l:Number = 0;
		
		public function get top():Number {
			return t;
		}
		
		public function get right():Number {
			return r;
		}
		
		public function get bottom():Number {
			return b;
		}
		
		public function get left():Number {
			return l;
		}
		
		public function setTo(top:Number, right:Number, bottom:Number, left:Number):Edge {
			t = top;
			r = right;
			b = bottom;
			l = left;
			return this;
		}
		
		public function clone():Edge {
			return new Edge(t, r, b, l);
		}
	}
}