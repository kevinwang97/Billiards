%Billiards by Kevin Wang
/*
 AI IDEAS:
 - generate random shots and pick the best
 */

include "modules.t"

%Ball information that is stored within a linked list
type Ball :
    record
	x, y : real
	colr : Color
	velocity : Vector
	prev, next : ^Ball
    end record
const BALLRADIUS := 10     %pixels
const HOLERADIUS := 18
const DRAGSCALE := 0.9985 %percentage kept
const MAXSPEED := 1.5 %pixels/ms
const SCALESPEED := 0.006 %pixels/ms
var shooting : boolean := false
var b : real
%Pointers to Ball information
var head : ^Ball := nil
var last : ^Ball := nil
var reference : ^Ball := nil
%Table color
var feltgreen : Color := saveColor (0.15, 0.45, 0.1)
var darkfeltgreen : Color := saveColor (0.075, 0.225, 0.05)
var Brown : Color := saveColor (0.35, 0.1, 0.1)

%Game Procedures
proc drawTable
    drawfillbox (75, 75, maxx - 75, maxy - 75, Brown.id)
    drawfillbox (100, 100, maxx - 100, maxy - 100, darkfeltgreen.id)
    drawfillbox (125, 125, maxx - 125, maxy - 125, feltgreen.id)
    drawfilloval (125, 125, HOLERADIUS, HOLERADIUS, Black.id)
    drawfilloval (maxx div 2, 125, HOLERADIUS, HOLERADIUS, Black.id)
    drawfilloval (maxx - 125, 125, HOLERADIUS, HOLERADIUS, Black.id)
    drawfilloval (maxx - 125, maxy - 125, HOLERADIUS, HOLERADIUS, Black.id)
    drawfilloval (maxx div 2, maxy - 125, HOLERADIUS, HOLERADIUS, Black.id)
    drawfilloval (125, maxy - 125, HOLERADIUS, HOLERADIUS, Black.id)
end drawTable

proc addBall (x, y : real, colr : Color)
    new last
    if head = nil then
	head := last
	last -> prev := nil
    else
	reference -> next := last
	last -> prev := reference
    end if
    last -> x := x
    last -> y := y
    last -> velocity.x := 0
    last -> velocity.y := 0
    last -> colr := colr
    last -> next := nil
    reference := last
end addBall

proc deleteBall (p : ^Ball)
    var ptr : ^Ball := p
    if ptr ~= head then
	ptr -> prev -> next := ptr -> next
    elsif ptr = head then
	head := ptr -> next
	head -> prev := nil
    end if
    if ptr ~= last then
	ptr -> next -> prev := ptr -> prev
    elsif ptr = last then
	last := ptr -> prev
	last -> next := nil
	reference := last
    end if
    free ptr
end deleteBall

proc collideBalls (pt1, pt2 : ^Ball)
    var normalunit : Vector := vectorUnit (vectorNew (pt1 -> x - pt2 -> x, pt1 -> y - pt2 -> y))
    var p1 : real := vectorDot (normalunit, pt1 -> velocity)
    var p2 : real := vectorDot (normalunit, pt2 -> velocity)
    var delta_p : real := p1 - p2
    pt1 -> velocity.x -= delta_p * normalunit.x
    pt1 -> velocity.y -= delta_p * normalunit.y
    pt2 -> velocity.x += delta_p * normalunit.x
    pt2 -> velocity.y += delta_p * normalunit.y
end collideBalls

proc collideBallSide (pt : ^Ball)
    var scaleback : real
    if pt -> x + BALLRADIUS >= maxx - 125 then
	scaleback := (pt -> x - (maxx - 125 - BALLRADIUS)) / pt -> velocity.x
	pt -> y := pt -> y + pt -> velocity.y * scaleback
	pt -> x := maxx - 125 - BALLRADIUS
	pt -> velocity.x *= -1
    elsif pt -> x - BALLRADIUS <= 125 then
	scaleback := (pt -> x - (125 + BALLRADIUS)) / pt -> velocity.x
	pt -> y := pt -> y + pt -> velocity.y * scaleback
	pt -> x := 125 + BALLRADIUS
	pt -> velocity.x *= -1
    end if
    if pt -> y + BALLRADIUS >= maxy - 125 then
	scaleback := (pt -> y - (maxy - 125 - BALLRADIUS)) / pt -> velocity.y
	pt -> x := pt -> x + pt -> velocity.x * scaleback
	pt -> y := maxy - 125 - BALLRADIUS
	pt -> velocity.y *= -1
    elsif pt -> y - BALLRADIUS <= 125 then
	scaleback := (pt -> y - (125 + BALLRADIUS)) / pt -> velocity.y
	pt -> x := pt -> x + pt -> velocity.x * scaleback
	pt -> y := 125 + BALLRADIUS
	pt -> velocity.y *= -1
    end if
end collideBallSide

proc checkCollision
    var ptr1 : ^Ball := head
    var ptr2 : ^Ball
    loop
	exit when ptr1 = nil
	ptr2 := ptr1 -> next
	loop
	    exit when ptr2 = nil
	    if ptr1 ~= ptr2 then
		if Math.Distance (ptr1 -> x, ptr1 -> y, ptr2 -> x, ptr2 -> y) <= BALLRADIUS * 2 then
		    collideBalls (ptr1, ptr2)
		    loop
			ptr1 -> x += ptr1 -> velocity.x
			ptr1 -> y += ptr1 -> velocity.y
			ptr2 -> x += ptr2 -> velocity.x
			ptr2 -> y += ptr2 -> velocity.y
			exit when Math.Distance (ptr1 -> x, ptr1 -> y, ptr2 -> x, ptr2 -> y) > BALLRADIUS * 2
		    end loop
		end if
	    end if
	    ptr2 := ptr2 -> next
	end loop
	collideBallSide (ptr1)
	ptr1 := ptr1 -> next
    end loop
end checkCollision

proc hitWhiteBall
    if vectorMagnitude (head -> velocity) = 0 then
	if mouseInCirc (head -> x, head -> y, BALLRADIUS) and leftClicked then
	    shooting := true
	end if
	if shooting then
	    var tempvelocity : Vector := vectorNew ((head -> x - mouseX) * SCALESPEED, (head -> y - mouseY) * SCALESPEED)
	    if vectorMagnitude (tempvelocity) > MAXSPEED then
		var unittempvelocity : Vector := vectorUnit (tempvelocity)
		tempvelocity := vectorMultiply (unittempvelocity, MAXSPEED)
	    end if
	    drawline (head -> x div 1, head -> y div 1, mouseX, mouseY, White.id)
	    if leftReleased then
		head -> velocity := tempvelocity
		shooting := false
	    end if
	end if
    end if
end hitWhiteBall

proc checkHoles
    var ptr : ^Ball := head
    var deleteptr : ^Ball := ptr
    loop
	exit when ptr = nil
	if Math.Distance (ptr -> x, ptr -> y, 125, 125) <= BALLRADIUS + HOLERADIUS / 2 or
		Math.Distance (ptr -> x, ptr -> y, maxx div 2, 125) <= BALLRADIUS + HOLERADIUS / 2 or
		Math.Distance (ptr -> x, ptr -> y, maxx - 125, 125) <= BALLRADIUS + HOLERADIUS / 2 or
		Math.Distance (ptr -> x, ptr -> y, maxx - 125, maxy - 125) <= BALLRADIUS + HOLERADIUS / 2 or
		Math.Distance (ptr -> x, ptr -> y, maxx div 2, maxy - 125) <= BALLRADIUS + HOLERADIUS / 2 or
		Math.Distance (ptr -> x, ptr -> y, 125, maxy - 125) <= BALLRADIUS + HOLERADIUS / 2 then
	    ptr := ptr -> next
	    deleteBall (deleteptr)
	else
	    ptr := ptr -> next
	    deleteptr := ptr
	end if
    end loop
end checkHoles

proc updateBalls
    var ptr : ^Ball := head
    loop
	exit when ptr = nil
	ptr -> x += ptr -> velocity.x * t
	ptr -> y += ptr -> velocity.y * t
	b := (1 - DRAGSCALE) %air resistance unit (drag scaled to be the same as when the game runs at 1000 FPS)
	ptr -> velocity.x := ptr -> velocity.x * (1 - b * t)
	ptr -> velocity.y := ptr -> velocity.y * (1 - b * t)
	if vectorMagnitude (ptr -> velocity) <= 0.001 then
	    ptr -> velocity.x := 0
	    ptr -> velocity.y := 0
	end if
	drawfilloval (ptr -> x div 1, ptr -> y div 1, BALLRADIUS, BALLRADIUS, ptr -> colr.id)
	ptr := ptr -> next
    end loop
end updateBalls

setScreen (1000, 600, "Billiards")
Mouse.ButtonChoose ("multibutton")

addBall (200, 300, White)
addBall (650, 300, Black)
addBall (674, 314, Red)
addBall (674, 286, Blue)
addBall (698, 328, Green)
addBall (698, 300, Orange)
addBall (698, 272, Yellow)

%Main Loop
loop
    t := timeDelay
    %put "FPS:", intstr (1000 div t)
    mouseUpdate
    checkCollision
    checkHoles
    drawTable
    updateBalls
    hitWhiteBall
    View.Update
    Time.DelaySinceLast (1000 div FPS)
    cls
end loop
