

/**
 * General math-related helper functions
 * @author Oliver Salzburg
 */
public class plexNMT.as2.substrate.MathHelper {
	
	/**
	 * Returns a random value within a given range
	 * @param	min The lower bound of the random range
	 * @param	max The upper bound of the random range
	 * @return A random value within the given range
	 */
	public static function randomRange( min:Number, max:Number ):Number {
		return Math.random() * ( max - min ) + min;
	}
	
}

