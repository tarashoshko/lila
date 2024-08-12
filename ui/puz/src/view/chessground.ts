import resizeHandle from 'common/resize';
import { Config as CgConfig } from 'chessground/config';
import { PuzPrefs, UserMove } from '../interfaces';
import * as Prefs from 'common/prefs';

export function makeConfig(opts: CgConfig, pref: PuzPrefs, userMove: UserMove): CgConfig {
  return {
    fen: opts.fen,
    orientation: opts.orientation,
    turnColor: opts.turnColor,
    check: opts.check,
    lastMove: opts.lastMove,
    coordinates: pref.coords !== Prefs.Coords.Hidden,
    coordinatesOnSquares: pref.coords === Prefs.Coords.All,
    addPieceZIndex: pref.is3d,
    addDimensionsCssVarsTo: document.body,
    movable: {
      free: false,
      color: opts.movable!.color,
      dests: opts.movable!.dests,
      showDests: pref.destination,
      rookCastle: pref.rookCastle,
    },
    draggable: {
      enabled: pref.moveEvent > 0,
      showGhost: pref.highlight,
    },
    selectable: {
      enabled: pref.moveEvent !== 1,
    },
    events: {
      move: userMove,
      insert(elements) {
        resizeHandle(elements, Prefs.ShowResizeHandle.OnlyAtStart, 0, p => p == 0);
      },
    },
    premovable: {
      enabled: false,
    },
    drawable: {
      enabled: true,
      defaultSnapToValidMove: site.storage.boolean('arrow.snap').getOrDefault(true),
    },
    highlight: {
      lastMove: pref.highlight,
      check: pref.highlight,
    },
    animation: {
      duration: pref.animation,
    },
    disableContextMenu: true,
  };
}
