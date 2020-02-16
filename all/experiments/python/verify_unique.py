#!/bin/env python

# Python3 code to demonstrate working of
# Get Unique values from list of dictionary
# Using set() + values() + from_iterable()

from itertools import chain
from pprint import pprint

# Initialize list
test_list = [{'gfg' : 1, 'is' : 2}, {'best' : 1, 'for' : 3}, {'for': 3}  ,{'CS' : 2}]

# printing original list
print("The original list : " +  str(test_list))

# Using set() + values() + from_iterable()
# Get Unique values from list of dictionary
res = list(set(chain.from_iterable(sub.values() for sub in test_list)))

# printing result
print("The unique values in list are : " + str(res))


lis = [{"abc":"movies"}, {"abc": "sports"}, {"abc": "music"}, {"xyz": "music"}, {"pqr":"music"}, {"pqr":"movies"},{"pqr":"sports"}, {"pqr":"news"}, {"pqr":"sports"}]
uni_lis = set( val for dic in lis for val in dic.values())
print("The unique values in list dict:" + str(uni_lis))

#####################################################################################
print("New approach as I need the full dict")

data = [ {'url':'http://www.test.com', 'title':'my Test'}
        ,{'url':'http://test.com', 'title':'my Test'}
        ,{'url':'http://www.test.com', 'title':'Another'}
        ,{'url':'http://test.como', 'title':'my Testo'}
        ]

a_data_unique = dict(chain.from_iterable(d.items() for d in data))
pprint(a_data_unique)

n_data_unique = dict((d['title'],d['url']) for d in data )
pprint(n_data_unique)

