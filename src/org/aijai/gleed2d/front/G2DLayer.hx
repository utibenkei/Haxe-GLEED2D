package org.aijai.gleed2d.front;

/**
 * Gleed2D layer element
 * @author Pekka Heikkinen
 */

interface G2DLayer extends G2DBasic
{
	
	/**
	 * Items within layer
	 */
	var items:Array<G2DItem>;
	
	/**
	 * Scrollspeed for layer
	 */
	var scroll:G2DPoint;

}