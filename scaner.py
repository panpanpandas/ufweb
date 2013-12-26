'''
Created on Nov 6, 2011

@author: ppa
'''
from ultrafinance.dam.DAMFactory import DAMFactory
from ultrafinance.pyTaLib.indicator import mean, stddev

symbols = []
with open("/Users/ppa/workspace/ufweb/conf/crawler.spy_nasdaq.list", 'r') as f:
    for line in f.readlines():
        symbols.append(line.strip())

dam = DAMFactory.createDAM("sql", {'db': 'sqlite:////data/stock.sqlite'})
dateTicks = dam.readBatchTupleQuotes(symbols, 20031210, 20131210)


symbolTicks = {}
for timeStamp in sorted(dateTicks.iterkeys()):
    for symbol, tick in dateTicks[timeStamp].iteritems():
        if symbol not in symbolTicks:
            symbolTicks[symbol] = []

        symbolTicks[symbol].append(tick)

bads = []
goods = {} # symbol as key, std as value
for symbol, ticks in symbolTicks.iteritems():
    avgClose = mean([tick.close for tick in ticks])
    std = 100 * stddev([tick.close for tick in ticks])/avgClose
    print "std for %s is %f" % (symbol, std)

    ticks = ticks[-30:]
    avgVolumnDollar = mean([tick.volume * tick.close for tick in ticks])

    if avgVolumnDollar > 1000000 and avgClose > 6 and avgClose < 100:
        goods[symbol] = std
    else:
        bads.append(symbol)

print "=========bad %s==============" % len(bads)
print bads

sortedList = sorted(goods.iteritems(), key=lambda x: x[1])
print "=========good %s==============" % len(sortedList)
print [symbolStd[0] for symbolStd in sortedList]
