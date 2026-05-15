// qr.jsx — QR code SVG generator using qrcode-generator (loaded via CDN)
// Falls back to a deterministic styled pattern if the lib didn't load.

function makeQRMatrix(text, ecLevel = 'M', minTypeNumber = 4) {
  if (typeof qrcode === 'undefined') return null;
  // Try ascending type numbers until the data fits.
  for (let t = minTypeNumber; t <= 20; t++) {
    try {
      const q = qrcode(t, ecLevel);
      q.addData(text);
      q.make();
      const n = q.getModuleCount();
      const m = [];
      for (let r = 0; r < n; r++) {
        const row = [];
        for (let c = 0; c < n; c++) row.push(q.isDark(r, c));
        m.push(row);
      }
      return m;
    } catch (e) {
      // overflow — try larger version
      continue;
    }
  }
  return null;
}

function fakeMatrix(text, size = 33) {
  // deterministic pseudo-random fallback that still has finder squares
  let seed = 0;
  for (const ch of text) seed = (seed * 31 + ch.charCodeAt(0)) >>> 0;
  const rand = () => {
    seed = (seed * 1664525 + 1013904223) >>> 0;
    return (seed >>> 16) / 65536;
  };
  const m = Array.from({ length: size }, () =>
    Array.from({ length: size }, () => rand() > 0.55)
  );
  // finder pattern function
  const finder = (r0, c0) => {
    for (let i = 0; i < 7; i++) {
      for (let j = 0; j < 7; j++) {
        const edge = i === 0 || i === 6 || j === 0 || j === 6;
        const inner = i >= 2 && i <= 4 && j >= 2 && j <= 4;
        m[r0 + i][c0 + j] = edge || inner;
      }
    }
    // quiet ring around finder
    for (let i = -1; i <= 7; i++) {
      for (let j = -1; j <= 7; j++) {
        if (i === -1 || i === 7 || j === -1 || j === 7) {
          const rr = r0 + i, cc = c0 + j;
          if (rr >= 0 && rr < size && cc >= 0 && cc < size) m[rr][cc] = false;
        }
      }
    }
  };
  finder(0, 0);
  finder(0, size - 7);
  finder(size - 7, 0);
  return m;
}

function QRCode({ value, size = 240, padding = 12, fg = '#1a1815', bg = '#ffffff' }) {
  const matrix = React.useMemo(() => {
    return makeQRMatrix(value) || fakeMatrix(value);
  }, [value]);

  const n = matrix.length;
  const cell = (size - padding * 2) / n;

  // Render with rounded "dots" for a refined feel.
  // Finder squares get their own larger rounded treatment.
  const finderPositions = [[0, 0], [0, n - 7], [n - 7, 0]];
  const isFinderCell = (r, c) =>
    finderPositions.some(([fr, fc]) => r >= fr && r < fr + 7 && c >= fc && c < fc + 7);

  const dots = [];
  for (let r = 0; r < n; r++) {
    for (let c = 0; c < n; c++) {
      if (!matrix[r][c]) continue;
      if (isFinderCell(r, c)) continue;
      dots.push(
        <rect key={`${r}-${c}`}
              x={padding + c * cell + cell * 0.08}
              y={padding + r * cell + cell * 0.08}
              width={cell * 0.84}
              height={cell * 0.84}
              rx={cell * 0.25}
              fill={fg}/>
      );
    }
  }

  const finder = ([fr, fc]) => (
    <g key={`${fr}-${fc}`}>
      <rect
        x={padding + fc * cell}
        y={padding + fr * cell}
        width={cell * 7}
        height={cell * 7}
        rx={cell * 1.6}
        fill="none"
        stroke={fg}
        strokeWidth={cell}/>
      <rect
        x={padding + (fc + 2) * cell}
        y={padding + (fr + 2) * cell}
        width={cell * 3}
        height={cell * 3}
        rx={cell * 0.8}
        fill={fg}/>
    </g>
  );

  return (
    <svg viewBox={`0 0 ${size} ${size}`} width={size} height={size}>
      <rect width={size} height={size} fill={bg} rx={padding * 1.5}/>
      {dots}
      {finderPositions.map(finder)}
    </svg>
  );
}

Object.assign(window, { QRCode });
