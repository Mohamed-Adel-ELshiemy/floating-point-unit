●Floating Point Unit (FPU):	
» In a modern society, monitoring and controlling the environment is becoming increasingly important. So, We need to implement a floating point unit in our design for measurement accuracy.
Floating-point arithmetics:
Floating-point is the name of a formulaic representation for real numbers that can be used to achieve a good trade-off between dynamic range and precision. Working with floating-point 
numbers is somewhat different than working with integers, and the following sections will try to explain why.
![image](https://github.com/Mohamed-Adel-ELshiemy/floating-point-unit/assets/156431969/93104674-7d04-4b3f-9662-dd23f517c67d)
●Number representation:
According to the IEEE-754 standard [1], floating-point numbers in compliant implementations have a binary representation as seen in Figure 2.1, which consists of a sign bit, an exponent and a fraction. 
 	
The radix is normally 2 (binary).
The bias is used for representing a wide dynamic range without needing to use 2's complement that can be calculated using the formula 2^(n-1)-1, where n is the number of bits in the exponent.
The example shown in Figure 2.1 is computed like this, using Equation with exponent 01111100 = 124 and bias from Table 2.1:
 
In addition to representing regular positive and negative numbers, the standard has special representations for ±∞ and NaN (Not a Number), used to represent the result of various illegal operations, such as 0/0  or  ∞/∞ .
