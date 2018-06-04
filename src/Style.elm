module Style exposing (..)


global =
    """
/* From: https://fontlibrary.org/en/font/xolonium */
@font-face {
  font-family: 'XoloniumBold';
  src: url('static/XoloniumBold.ttf') format('truetype');
  font-weight: bold;
  font-style: normal;
}

@font-face {
  font-family: 'XoloniumRegular';
  src: url('static/XoloniumRegular.ttf') format('truetype');
  font-weight: normal;
  font-style: normal;
}

body {
  margin: 0;
  font-family: 'XoloniumRegular', sans-serif;
}

.game-area {
  cursor: url(static/crosshair.png) 64 64, crosshair;
}

.flex { display: flex; }
.flex1 { flex: 1; }
.alignCenter { align-items: center; }
.alignEnd { align-items: flex-end; }
.justifyCenter { justify-content: center; }
.justifyBetween { justify-content: space-between; }

.relative { position: relative; }
.fullWindow { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }
.invisible { visibility: hidden; }

/* padding */
.p2 { padding: 2em; }
.pt2 { padding-top: 2em; }
.pr2 { padding-right: 2em; }
.pb2 { padding-bottom: 2em; }
.pl2 { padding-left: 2em; }


/* margin */
.m1 { margin: 0.5em; }
.mt1 { margin-top: 0.5em; }
.mr1 { margin-right: 0.5em; }
.mb1 { margin-bottom: 0.5em; }
.ml1 { margin-left: 0.5em; }

.m2 { margin: 1em; }
.mt2 { margin-top: 1em; }
.mr2 { margin-right: 1em; }
.mb2 { margin-bottom: 1em; }
.ml2 { margin-left: 1em; }


/* colors */
.gray { color: gray; }


/* menu */
.menu {
  background-color: white;
  border: 1px solid black;
}

.menu * + section {
  margin-top: 2em;
}
"""
