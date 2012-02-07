dynamic class plexNMT.as2.common.ExtArray extends Array {

	var ExtArray:Array=new Array;

	public function RotateRight():Void {
		this.unshift(this.pop());
	}

	public function RotateRightBy(n:Number):Void {
		for (var i=0; i<n; I++) {
			this.RotateRight();
		}
	}

	public function RotateLeft():Void {
		this.push(this.pop());
	}

	public function RotateLefttBy(n:Number):Void {
		for (var i=0; i<n; I++) {
			this.RotateLeft();
		}
	}
}