'''
Created on Nov 6, 2011

@author: ppa
'''
from ultrafinance.dam.DAMFactory import DAMFactory
from ultrafinance.pyTaLib.indicator import mean, stddev

symbols = []
with open("/Users/ppa/workspace/ufweb/conf/crawler.dev.list", 'r') as f:
    for line in f.readlines():
        symbols.append(line.strip())

dam = DAMFactory.createDAM("sql", {'db': 'sqlite:////data/stock.sqlite'})
dateTicks = dam.readBatchTupleQuotes(symbols, 20121010, None)


symbolTicks = {}
for timeStamp in sorted(dateTicks.iterkeys()):
    for symbol, tick in dateTicks[timeStamp].iteritems():
        if symbol not in symbolTicks:
            symbolTicks[symbol] = []

        symbolTicks[symbol].append(tick)

d = {}
for symbol, ticks in symbolTicks.iteritems():
    if symbol in d:
        continue

    avgClose = mean([tick.close for tick in ticks])
    std = 100 * stddev([tick.close for tick in ticks])/avgClose
    print "std for %s is %f" % (symbol, std)

    ticks = ticks[-30:]
    avgVolumnDollar = mean([tick.volume * tick.close for tick in ticks])

    if avgVolumnDollar > 1000000 and avgClose > 8 and avgClose < 50 and std > 10:
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