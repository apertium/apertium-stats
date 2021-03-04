# Apertium Statistics Helpers
Very much work-in-progress. Everything subject to change.

## How to use
* `cd apertium-cat-ita`
* `../path/to/apertium-stats/tally-source.pl`

which will yield JSON akin to
```json
{
   "apertium-cat-ita.cat-ita.dix" : {
      "kind" : "dix",
      "size" : {
         "bytes" : 4770505,
         "lines" : 46442
      },
      "stems" : 46066
   },
   "apertium-cat-ita.cat-ita.t1x" : {
      "kind" : "transfer",
      "macros" : 17,
      "rules" : 116,
      "size" : {
         "bytes" : 378149,
         "lines" : 11251
      }
   }
}
```

### See also
* https://wiki.apertium.org/wiki/The_Right_Way_to_count_dix_stems
* https://wiki.apertium.org/wiki/The_Right_Way_to_count_lexc_stems

### Imported from
* https://svn.code.sf.net/p/apertium/svn/trunk/apertium-tools/dixcounter.py
* https://svn.code.sf.net/p/apertium/svn/trunk/apertium-tools/lexccounter.py
