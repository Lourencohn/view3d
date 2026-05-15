// icons.jsx — Stroke-style icons. Inherits `currentColor`.

const Icon = ({ d, size = 20, strokeWidth = 1.6, fill = "none", children }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill}
       stroke="currentColor" strokeWidth={strokeWidth}
       strokeLinecap="round" strokeLinejoin="round">
    {children || <path d={d} />}
  </svg>
);

const IconBack    = (p) => <Icon {...p}><path d="M15 18l-6-6 6-6"/></Icon>;
const IconClose   = (p) => <Icon {...p}><path d="M6 6l12 12M18 6l-12 12"/></Icon>;
const IconShare   = (p) => <Icon {...p}><path d="M12 3v13M12 3l-4 4M12 3l4 4"/><path d="M5 15v3a2 2 0 002 2h10a2 2 0 002-2v-3"/></Icon>;
const IconQR      = (p) => <Icon {...p}><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><path d="M14 14h3v3h-3zM20 14h1v1h-1zM14 20h1v1h-1zM18 18h3v3h-3z"/></Icon>;
const IconAR      = (p) => <Icon {...p}><path d="M12 2L4 6v12l8 4 8-4V6l-8-4z"/><path d="M4 6l8 4 8-4M12 10v12"/></Icon>;
const IconRotate  = (p) => <Icon {...p}><path d="M3 12a9 9 0 0115.5-6.4M21 4v5h-5"/><path d="M21 12a9 9 0 01-15.5 6.4M3 20v-5h5"/></Icon>;
const IconHeart   = (p) => <Icon {...p}><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78L12 21.23l8.84-8.84a5.5 5.5 0 000-7.78z"/></Icon>;
const IconMore    = (p) => <Icon {...p}><circle cx="5" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="12" cy="12" r="1.4" fill="currentColor" stroke="none"/><circle cx="19" cy="12" r="1.4" fill="currentColor" stroke="none"/></Icon>;
const IconHome    = (p) => <Icon {...p}><path d="M3 11l9-8 9 8v9a2 2 0 01-2 2H5a2 2 0 01-2-2v-9z"/></Icon>;
const IconGrid    = (p) => <Icon {...p}><rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><rect x="14" y="14" width="7" height="7" rx="1"/></Icon>;
const IconList    = (p) => <Icon {...p}><path d="M8 6h12M8 12h12M8 18h12"/><circle cx="4" cy="6" r="1" fill="currentColor" stroke="none"/><circle cx="4" cy="12" r="1" fill="currentColor" stroke="none"/><circle cx="4" cy="18" r="1" fill="currentColor" stroke="none"/></Icon>;
const IconChart   = (p) => <Icon {...p}><path d="M3 20h18M6 17V10M11 17V6M16 17v-7M21 17v-3"/></Icon>;
const IconUser    = (p) => <Icon {...p}><circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-7 8-7s8 3 8 7"/></Icon>;
const IconSearch  = (p) => <Icon {...p}><circle cx="11" cy="11" r="7"/><path d="M21 21l-4.3-4.3"/></Icon>;
const IconCheck   = (p) => <Icon {...p}><path d="M4 12l5 5 11-12"/></Icon>;
const IconCopy    = (p) => <Icon {...p}><rect x="9" y="9" width="11" height="11" rx="2"/><path d="M5 15V5a2 2 0 012-2h10"/></Icon>;
const IconLink    = (p) => <Icon {...p}><path d="M10 13a5 5 0 007.5.5l3-3a5 5 0 00-7-7l-1.7 1.7"/><path d="M14 11a5 5 0 00-7.5-.5l-3 3a5 5 0 007 7l1.7-1.7"/></Icon>;
const IconMail    = (p) => <Icon {...p}><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M3 7l9 6 9-6"/></Icon>;
const IconMsg     = (p) => <Icon {...p}><path d="M21 12a8 8 0 11-3.6-6.7L21 4l-1.3 3.7A8 8 0 0121 12z"/></Icon>;
const IconDownload= (p) => <Icon {...p}><path d="M12 4v12M12 16l-5-5M12 16l5-5"/><path d="M4 20h16"/></Icon>;
const IconCube    = (p) => <Icon {...p}><path d="M12 2L3 7v10l9 5 9-5V7l-9-5z"/><path d="M3 7l9 5 9-5M12 12v10"/></Icon>;
const IconSparkle = (p) => <Icon {...p}><path d="M12 2v6M12 16v6M2 12h6M16 12h6M5 5l4 4M15 15l4 4M19 5l-4 4M9 15l-4 4"/></Icon>;
const IconExpand  = (p) => <Icon {...p}><path d="M4 4h6M4 4v6M20 20h-6M20 20v-6"/></Icon>;
const IconChevron = (p) => <Icon {...p}><path d="M9 6l6 6-6 6"/></Icon>;
const IconEye     = (p) => <Icon {...p}><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle cx="12" cy="12" r="3"/></Icon>;
const IconRuler   = (p) => <Icon {...p}><path d="M3 17L17 3l4 4L7 21l-4-4z"/><path d="M7 11l2 2M10 8l2 2M13 5l2 2M5 14l2 2"/></Icon>;
const IconLock    = (p) => <Icon {...p}><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 018 0v4"/></Icon>;

Object.assign(window, {
  Icon,
  IconBack, IconClose, IconShare, IconQR, IconAR, IconRotate,
  IconHeart, IconMore, IconHome, IconGrid, IconList, IconChart, IconUser,
  IconSearch, IconCheck, IconCopy, IconLink, IconMail, IconMsg,
  IconDownload, IconCube, IconSparkle, IconExpand, IconChevron, IconEye,
  IconRuler, IconLock,
});
