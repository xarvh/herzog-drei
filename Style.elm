module Style exposing (..)


global =
    """
.flex { display: flex; }
.flex1 { flex: 1; }
.alignCenter { align-items: center; }
.alignEnd { align-items: flex-end; }
.justifyCenter { justify-content: center; }
.justifyBetween { justify-content: space-between; }

.relative { position: relative; }
.fullWindow { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }

.bgConfig { background-color: white; }
.borderConfig { border: 1px solid black; }

/* padding */
.p2 { padding: 2em; }
.pt2 { padding-top: 2em; }
.pr2 { padding-right: 2em; }
.pb2 { padding-bottom: 2em; }
.pl2 { padding-left: 2em; }


/* margin */
.m1 { margin: 1em; }
.mt1 { margin-top: 1em; }
.mr1 { margin-right: 1em; }
.mb1 { margin-bottom: 1em; }
.ml1 { margin-left: 1em; }

.m2 { margin: 2em; }
.mt2 { margin-top: 2em; }
.mr2 { margin-right: 2em; }
.mb2 { margin-bottom: 2em; }
.ml2 { margin-left: 2em; }
"""
