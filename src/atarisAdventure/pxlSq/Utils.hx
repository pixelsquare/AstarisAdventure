package atarisAdventure.pxlSq;

#if flash
import flash.external.ExternalInterface;
#end

/**
 * ...
 * @author Anthony Ganzon
 * Console logger for debugging purposes.
 * NOTE: Works only with flash build
 */
class Utils
{
	public static function ConsoleLog(str: String) {
		#if flash
		ExternalInterface.call("console.log", str);
		#end
	}
}
