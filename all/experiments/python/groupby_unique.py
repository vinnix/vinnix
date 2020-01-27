#!/bin/env python

##
## CC-LA
## This script is provided as is, the author is just learning python and has no clue what he is doing.
##

import itertools
from operator import itemgetter
from pprint import pprint

#######################################################################################################
print("New approach as I need the full dict")

data = [ {'url':'http://www.test.com', 'title':'my Test', 'views':50 , 'pub':'AAC'    }
        ,{'url':'http://test.com',     'title':'my Test', 'views':100  , 'pub':'AAC'  }
        ,{'url':'http://www.test.com', 'title':'Another', 'views':1000 ,'pub': 'AAB'  }
        ,{'url':'http://test.como',    'title':'my Testx', 'views': 10, 'pub': 'BBC'  }
        ,{'url':'https://test.com',    'title':'my Test', 'views': 1, 'pub': 'AAD'    }
        ,{'url':'http://test.como',    'title':'Hoi Test', 'views': 30 , 'pub': 'BCC' }
         ]

data.sort(key=itemgetter("title"))
#pprint(data)

agg_data = []
i = 0
#for item_title, dataitem in itertools.groupby(data, lambda x: x['title'] ):
for item_title, dataitem in itertools.groupby(data, itemgetter('title') ):
    # print("Type   (item_title): %s" % type(item_title))
    # print("Length (item_title): %s" % len(item_title))
    # print("Type   (dataitem): %s" % type(dataitem))
    # print("Length (dataitem): %s" % len(dataitem))  #error
    agg_data.append(list(dataitem))
    # print("Aggregation:")
    # pprint(agg_data)
    # print("Type (agg_data[i][0]): %s " %  type(agg_data[i][0]))
    print("Unique Title: %s " % agg_data[i][0].get("title","No title found"))
    print("Unique URL: %s " % agg_data[i][0].get("url","No title found"))
    # print('%s: %s' % (item_title, [v for k, v in dataitem]))
    i += 1
    # for k,v in dataitem:
    #    print(">>> key: " + str((group,k)) + " / value: "+ str((group,v)) +" \n ")



