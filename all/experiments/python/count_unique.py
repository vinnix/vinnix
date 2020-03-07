#!/bin/env python

from pprint import pprint

# Python3 code to demonstrate 
# check for unique values 
# Using len() + set() + values() 
  
# initializing dictionary 
test_dict = {'Manjeet' : 1, 'Akash' : 2, 'Akshat' : 3, 'Nikhil' : 1} 
  
# printing original dictionary 
print("The original dictionary : " + str(test_dict)) 
  
# using len() + set() + values() 
# check for unique values 
flag = len(test_dict) != len(set(test_dict.values())) 

pprint(set(test_dict.values()))
  
# print result 
print("Does dictionary contain repetition : " + str(flag)) 

