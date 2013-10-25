'''
Created on Nov 6, 2011

@author: ppa
'''
from ultrafinance.dam.DAMFactory import DAMFactory
from ultrafinance.pyTaLib.indicator import mean

symbols = []
with open("/Users/ppa/workspace/ufweb/conf/crawler.spy_nasdaq.list", 'r') as f:
    for line in f.readlines():
        symbols.append(line.strip())

dam = DAMFactory.createDAM("sql", {'db': 'sqlite:////data/stock.sqlite'})
ticks = dam.readBatchTupleQuotes(symbols, 20130710, None)


d = {}
for symbol, ticks in ticks.items():
    if symbol in d:
        continue

    ticks = ticks[-60:]
    avgVolumn = mean([tick.volume for tick in ticks])
    avgClose = mean([tick.close for tick in ticks])

    if avgVolumn > 50000 and avgClose > 8 and avgClose < 50:
        d[symbol] = "good"
    else:
        d[symbol] = "bad"

s = ""
good = 0
b = ""
bad = 0
for symbol, state in d.items():
    if state == "good":
        s += " %s" % symbol
        good += 1
    else:
        b += " %s" % symbol
        bad += 1
print "====good %d====" % good
print s

print "====bad %d=====" % bad
print b