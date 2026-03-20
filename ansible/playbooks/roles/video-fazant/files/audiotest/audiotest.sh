#!/bin/bash

# no usb to usb

mixercli set-gain "USB L" "USB L" 0
mixercli set-gain "USB L" "USB R" 0
mixercli set-gain "USB R" "USB L" 0
mixercli set-gain "USB R" "USB R" 0

# no xlr to xlr

for inp in 1 2 3; do
	for out in 1 2; do
		mixercli set-gain "XLR $inp" "XLR $out" 0
	done
done

# no xlr to headphones

for inp in 1 2 3; do
	for out in R L; do
		mixercli set-gain "XLR $inp" "Headphone $out" 0
	done
done



level=0.1

# all xlr to usb

for inp in 1 2 3; do
	for out in R L; do
		mixercli set-gain "XLR $inp" "USB $out" $level
	done
done

# all usb to xlr and headphones

for inp in R L; do
	for out in 1 2; do
		mixercli set-gain "USB $inp" "XLR $out" $level
	done
done

for inp in R L; do
	for out in R L; do
		mixercli set-gain "USB $inp" "Headphone $out" $level
	done
done

# run the test

alsabat -P hw:0 -C hw:0 --saveplay=tmpf -F 18000 -c 2 -r 48000 -n 5s
