/*
 * TNCategories.j
 *
 * Copyright (C) 2010  Antoine Mercadal <antoine.mercadal@inframonde.eu>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3.0 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

@import <AppKit/AppKit.j>
@import "TNToolTip.j";

var currentToolTip,
    currentToolTipTimer,
    currentFocusToolTip,
    currentFocusToolTipTimer;

@implementation CPControl (tooltip)

- (void)setToolTip:(CPString)aToolTip
{
    if (_toolTip == aToolTip)
        return;

    _toolTip = aToolTip;

    if (!_DOMElement)
        return;

    var fIn = function(e){
            [self fireToolTip];
        };
        fOut = function(e){
            [self invalidateToolTip];
        };


    if (_toolTip)
    {
        if (_DOMElement.addEventListener)
        {
            _DOMElement.addEventListener("mouseover", fIn, NO);
            _DOMElement.addEventListener("keypress", fOut, NO);
            _DOMElement.addEventListener("mouseout", fOut, NO);
        }
        else if (_DOMElement.attachEvent)
        {
            _DOMElement.attachEvent("onmouseover", fIn);
            _DOMElement.attachEvent("onkeypress", fOut);
            _DOMElement.attachEvent("onmouseout", fOut);
        }
    }
    else
    {
        if (_DOMElement.removeEventListener)
        {
            _DOMElement.removeEventListener("mouseover", fIn, NO);
            _DOMElement.removeEventListener("keypress", fOut, NO);
            _DOMElement.removeEventListener("mouseout", fOut, NO);
        }
        else if (_DOMElement.detachEvent)
        {
            _DOMElement.detachEvent("onmouseover", fIn);
            _DOMElement.detachEvent("onkeypress", fOut);
            _DOMElement.detachEvent("onmouseout", fOut);
        }
    }
}

- (CPString)toolTip
{
    return _toolTip;
}

- (void)fireToolTip
{
    if (currentToolTipTimer)
    {
        [currentToolTipTimer invalidate];
        if (currentToolTip)
            [currentToolTip close:nil];
        currentToolTip = nil;
    }

    if ( _toolTip )
        currentToolTipTimer = [CPTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector(showToolTip:) userInfo:nil repeats:NO];
}

- (void)invalidateToolTip
{
    if (currentToolTipTimer)
    {
        [currentToolTipTimer invalidate];
        currentToolTipTimer = nil;
    }

    if (currentToolTip)
    {
        [currentToolTip close:nil];
        currentToolTip = nil;
    }

}

- (void)showToolTip:(CPTimer)aTimer
{
    if (currentToolTip)
        [currentToolTip close:nil];

    currentToolTip = [TNToolTip toolTipWithString:_toolTip forView:self];
}

@end

@implementation CPTextField (tooltip)

- (void)setFocusToolTip:(CPString)aToolTip
{
	if( typeof( _focusToolTip ) == @"undefined" )
		_focusToolTip = @"";
		
    if (_focusToolTip == aToolTip)
        return;

    _focusToolTip = aToolTip;

    if (!_DOMElement)
        return;

    if (_focusToolTip)
    {
    	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(fireFocusToolTip) name:CPTextFieldDidFocusNotification object:self];
    	[[CPNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateFocusToolTip) name:CPTextFieldDidBlurNotification object:self];
    }
    else
    {
        [[CPNotificationCenter defaultCenter] removeObserver:self name:CPTextFieldDidFocusNotification object:self];
		[[CPNotificationCenter defaultCenter] removeObserver:self name:CPTextFieldDidBlurNotification object:self];
    }
}

- (CPString)focusToolTip
{
    return _focusToolTip;
}

- (void)fireFocusToolTip
{
	console.log('fireFocusToolTip');
	[self showFocusToolTip:nil];
}

- (void)invalidateFocusToolTip
{
	[currentFocusToolTip close:nil];
	currentFocusToolTip = nil;
}

- (void)showFocusToolTip:(CPTimer)aTimer
{
    currentFocusToolTip = [TNToolTip toolTipWithString:_focusToolTip forView:self];
}
